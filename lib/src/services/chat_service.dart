import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hitch/src/models/chat_model.dart';
import 'package:hitch/src/models/group_chat_model.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/models/messages_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/auth_service.dart';

import '../models/chat_user_model.dart';
import '../utils/utils.dart';

class ChatService {
  static final CollectionReference _chatsColRef =   FirebaseFirestore.instance.collection(chatsCollection);
  static final CollectionReference _groupChatsColRef =
      FirebaseFirestore.instance.collection(groupChatsCollection);

  static Future<ChatModel?> createGetChatRoomID({required String userID})async{
    //First verify if chat is already created or not
    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    String roomID = '${currentUID}_$userID';
    try{
     DocumentSnapshot documentSnapshot = await _chatsColRef.doc(roomID).get();
     if(documentSnapshot.exists){
       final map = documentSnapshot.data() as Map<String, dynamic>;
       ChatModel chat = ChatModel(roomID: roomID, remoteUser: ChatUserModel.fromMap(map[userID]), dateTimeCreated: map['dateTimeCreated']);
       return chat;
     }else {
       //Check for reverse roomID
       String reverseRoomID = '${userID}_$currentUID';
       DocumentSnapshot documentSnapshot = await _chatsColRef.doc(reverseRoomID).get();
       if(documentSnapshot.exists){
         final map = documentSnapshot.data() as Map<String, dynamic>;
         ChatModel chat = ChatModel(roomID: reverseRoomID, remoteUser: ChatUserModel.fromMap(map[userID]), dateTimeCreated: map['dateTimeCreated']);
         return chat;
       }
     }
     //No Chat exists between these users, So creating one
     ChatUserModel? remoteChatUser = await _getChatUserModel(userID: userID);
     ChatUserModel? currentChatUser = await _getChatUserModel(userID: currentUID);

     await _chatsColRef.doc(roomID).set({
       'roomID' : roomID,
       userID : remoteChatUser!.toMap(),
       currentUID : currentChatUser!.toMap(),
       'dateTimeCreated' : Timestamp.now()
     });

     ChatModel chatModel = ChatModel(roomID: roomID, remoteUser: remoteChatUser, dateTimeCreated: Timestamp.now());
     return chatModel;
    }catch(e){
      String errorMessage = e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }

      debugPrint("Error message is: $errorMessage");
    }
    return null;
  }

  static Future<ChatUserModel?> _getChatUserModel({required String userID})async{
    try{
      DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection(userCollection).doc(userID).get();
      if(docSnap.exists){
        final map = docSnap.data() as Map<String, dynamic>;

        ChatUserModel chatUserModel = ChatUserModel(userID: userID,
            userName: map['userName'],
            profilePicture: map['profilePicture']);

        return chatUserModel;
      }
    }catch(e){
      String errorMessage = e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }

      debugPrint("Error message is: $errorMessage");
    }

    return null;
  }

  static Stream<List<MessagesModel>> getChatMessagesByRoomID({required String roomID}){
    return _chatsColRef.doc(roomID).collection(messagesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc)=> MessagesModel.fromMap(doc.data())).toList()..sort((a, b)=> a.timestamp.compareTo(b.timestamp));
    });
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String roomID,
    required String messageText,
    String type = 'text',
    String fileUrl = ''
  })async {
     bool messageSent = false;
     String errorMessage = '';

     String messageID = DateTime.now().microsecondsSinceEpoch.toString();
     String senderID = FirebaseAuth.instance.currentUser!.uid;

     MessagesModel message = MessagesModel(messageID: messageID,
        senderID: senderID,
        type: type,
        fileUrl: fileUrl,
        messageText: messageText,
        timestamp: Timestamp.now(),);

    try{
     await _chatsColRef.doc(roomID).collection(messagesCollection).doc(messageID).set(message.toMap());
     messageSent = true;
     _chatsColRef.doc(roomID).update({
       'lastMessage': message.toMap()
     });
    }catch(e){
       errorMessage = e.toString();

      if(e is PlatformException){
        errorMessage = e.message!;
      }
      debugPrint("Error while sending message: $errorMessage");
    }

    return {
      'status' : messageSent,
      'responseMsg' : messageSent ? 'Success' : errorMessage
    };
  }

  static Future<Map<String, dynamic>> sendMessageInGroup({
    required String roomID,
    required String messageText,
    String type = 'text',
    String fileUrl = ''
  })async {
    bool messageSent = false;
    String errorMessage = '';

    String messageID = DateTime.now().microsecondsSinceEpoch.toString();
    String senderID = FirebaseAuth.instance.currentUser!.uid;

    MessagesModel message = MessagesModel(messageID: messageID,
      senderID: senderID,
      type: type,
      fileUrl: fileUrl,
      messageText: messageText,
      timestamp: Timestamp.now(),);

    try{
      await _groupChatsColRef
          .doc(roomID)
          .collection(messagesCollection)
          .doc(messageID)
          .set(message.toMap());
      messageSent = true;
      // debugPrint("Message is sent");
    }catch(e){
      errorMessage = e.toString();

      if(e is PlatformException){
        errorMessage = e.message!;
      }

      debugPrint("Error while sending message: $errorMessage");
    }

    return {
      'status' : messageSent,
      'responseMsg' : messageSent ? 'Success' : errorMessage
    };
  }


  static Future<void> markAsRead({required String messageID, required String roomID}) async{
    _chatsColRef
        .doc(roomID)
        .collection(messagesCollection)
        .doc(messageID)
        .update({
      'isReadByReceiver' : true
    });
  }

  static Future<void> markGroupMessageAsRead({required String messageID, required String roomID}) async{
    final DocumentReference messageRef = _groupChatsColRef // Replace with your actual collection reference
        .doc(roomID)
        .collection(messagesCollection) // Replace with your actual sub-collection name
        .doc(messageID);

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    await messageRef.update({
      'readByUsers': FieldValue.arrayUnion([currentUID]) // Adds the userID if not already present
    });
  }

  static Stream<int> getUnReadMessagesCount({required String roomID}) {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    return _chatsColRef
        .doc(roomID)
        .collection(messagesCollection)
        .where('isReadByReceiver', isEqualTo: false) // Unread messages
        .snapshots()
        .map((snapshot) {
      // Filter messages where senderID != currentUID
      final unreadMessages = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['senderID'] != currentUID;
      }).toList();
      return unreadMessages.length; // Return count of filtered messages
    });
  }

  static Stream<int> getGroupChatUnReadMessagesCount({required String roomID}) {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
   return _groupChatsColRef // Replace with your actual collection name
        .doc(roomID)
        .collection(messagesCollection) // Replace with your messages collection name
         .where('senderID', isNotEqualTo: currentUID) // Get messages not sent by current user
       .snapshots()
       .map((snapshot) {
     return snapshot.docs
         .where((doc) {
       List<dynamic> readByUsers = doc['readByUsers'] ?? [];
       return !readByUsers.contains(currentUID); // Filter unread messages
     }).length;
   });
  }

  static Stream<List<ChatModel>> get getUserChats {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    return _chatsColRef
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .where((doc) => doc.id.split('_').contains(currentUID))
            .map((doc) {
          final docID =  doc.id;
          List<String> userIDs =  docID.split('_');
            String remoteUID = userIDs
                .where((userID) => userID != FirebaseAuth.instance.currentUser!.uid)
                .first;
            final map = doc.data() as Map<String,dynamic>;

          ChatUserModel remoteUser = ChatUserModel.fromMap(map[remoteUID]);
          final chatModel = ChatModel(remoteUser: remoteUser, roomID: docID, dateTimeCreated: Timestamp.now());
          return chatModel;
        },).toList());
  }

  static Stream<List<GroupChatModel>> get getUserGroupChats {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    return _groupChatsColRef.where('memberIDs', arrayContains: currentUID)
        .snapshots()
        .map((snapshot){
        return snapshot.docs
            .map((doc) {
              return GroupChatModel.fromMap(doc.data() as Map<String, dynamic>);
        },).toList();
    });
  }
  static Stream<int> getTotalUnreadMessagesCountStream() {

    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    return _chatsColRef
        .snapshots()
        .asyncMap((querySnapshot) async {
      int totalUnreadCount = 0;

      for (var doc in querySnapshot.docs) {
        final roomID = doc.id;

        if (roomID.split('_').contains(currentUID)) {
          QuerySnapshot querySnapshot = await _chatsColRef
              .doc(roomID)
              .collection(messagesCollection)
              .get();
          // debugPrint("Unread Chat messages: ${querySnapshot.size}");
          // Filter messages where senderID != currentUID
          final unreadMessages = querySnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['senderID'] != currentUID;
          }).toList();

          totalUnreadCount += unreadMessages.length;
        }
      }
      return totalUnreadCount;
    });
  }

  static Stream<int> getTotalGroupUnreadMessagesCountStream() {

    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    return _groupChatsColRef
        .snapshots()
        .asyncMap((querySnapshot) async {

      int totalUnreadCount = 0;
      // debugPrint("Total group chats: ${querySnapshot.size}");
      for (var doc in querySnapshot.docs) {
        final roomID = doc.id;
        final map = doc.data() as Map<String, dynamic>;
        if (map['memberIDs'].contains(currentUID)) {
          QuerySnapshot querySnapshot = await _groupChatsColRef
              .doc(roomID)
              .collection(messagesCollection)
              .get();

          // Filter messages where senderID != currentUID
          final unreadMessages = querySnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            List<dynamic> readByUsers = doc['readByUsers'] ?? [];

            return data['senderID'] != currentUID && !readByUsers.contains(currentUID);
          }).toList();

          totalUnreadCount += unreadMessages.length;
        }
      }
      return totalUnreadCount;
    });
  }

  static Future<void> createGroupChat({required List<HitchesModel> hitches, required String groupName}) async {
    String groupChatID = DateTime.now().microsecondsSinceEpoch.toString();
    DateTime createdAt = DateTime.now();
    String adminID = FirebaseAuth.instance.currentUser!.uid;
    List<ChatUserModel> members = [];
    List<String> memberIDs = [];
    for (var hitch in hitches) {
      UserModel user = hitch.user;
      ChatUserModel chatUserModel = ChatUserModel(userID: user.userID, userName: user.userName, profilePicture: user.profilePicture);
      members.add(chatUserModel);
      memberIDs.add(user.userID);
    }

    UserModel? currentUser = await UserAuthService.instance.getCurrentUser();
    if(currentUser != null){
      members.add(ChatUserModel(userID: currentUser.userID, userName: currentUser.userName, profilePicture: currentUser.profilePicture));
      memberIDs.add(currentUser.userID);
    }

    GroupChatModel groupChatModel = GroupChatModel(chatID: groupChatID,
        createdAt: createdAt,
        members: members,
        memberIDs: memberIDs,
        groupName: groupName,
        adminID: adminID);

    await FirebaseFirestore.instance.collection(groupChatsCollection).doc(groupChatID).set(groupChatModel.toMap());

  }

  static Stream<List<MessagesModel>> getGroupChatMessages({required String roomID}) {
    return _groupChatsColRef.doc(roomID).collection(messagesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc)=> MessagesModel.fromMap(doc.data())).toList()..sort((a, b)=> a.timestamp.compareTo(b.timestamp));
    });
  }

  static Future<int> getTotalUnreadMessagesCount()async{
    int totalUnreadCount = 0;
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Get all chat rooms
      QuerySnapshot chatRoomsSnapshot =
      await FirebaseFirestore.instance.collection(chatsCollection).get();

      for (var chatDoc in chatRoomsSnapshot.docs) {
        bool isMyChat = chatDoc.id.split('_').contains(currentUID);
        if(isMyChat){
          // Fetch unread messages (ignoring senderID filtering)
          QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
              .collection(chatsCollection)
              .doc(chatDoc.id)
              .collection(messagesCollection)
              .where('isReadByReceiver', isEqualTo: false)
              .get();

          // Manually filter messages where senderID is not currentUID
          int unreadCount = messagesSnapshot.docs
              .where((doc) => doc['senderID'] != currentUID)
              .length;

          totalUnreadCount += unreadCount;
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread messages: $e');
    }

    return totalUnreadCount;
  }

  static Future<int> getTotalUnreadGroupMessagesCount()async{
    int totalUnreadCount = 0;
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      QuerySnapshot querySnapshot = await _groupChatsColRef
          .where('memberIDs', arrayContains: currentUID)
          .get();
      // debugPrint("Group chats found: ${querySnapshot.size}");
      for (var doc in querySnapshot.docs) {
        final roomID = doc.id;
        final map = doc.data() as Map<String, dynamic>;
        if (map['memberIDs'].contains(currentUID)) {
          QuerySnapshot querySnapshot = await _groupChatsColRef
              .doc(roomID)
              .collection(messagesCollection)
              .get();

          // Filter messages where senderID != currentUID
          final unreadMessages = querySnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            List<dynamic> readByUsers = doc['readByUsers'] ?? [];

            return data['senderID'] != currentUID && !readByUsers.contains(currentUID);
          }).toList();

          totalUnreadCount += unreadMessages.length;
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread messages: $e');
    }

    // debugPrint("Total unRead group messages count: $totalUnreadCount");
    return totalUnreadCount;
  }

  static Future<void> deleteGroupChat(String chatID) async{
    try{
      DocumentSnapshot docSnap =  await _groupChatsColRef.doc(chatID).get();
      if(docSnap.exists){
        await docSnap.reference.delete();
        Utils.showCopyToastMessage(message: "Group Chat removed successfully");
      }
    }catch(e){
      debugPrint("Exception while deleting group chatID: ${e.toString()}");
    }

  }
}