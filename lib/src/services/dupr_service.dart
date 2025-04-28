import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitch/src/models/dupr_model.dart';

class DuprService {
  static final DuprService _instance = DuprService._internal();
  factory DuprService() => _instance;
  DuprService._internal();

  static final String _clientId = dotenv.env['DURP_CLIENT_ID']!;
  static final String _clientKey = dotenv.env['DURP_CLIENT_KEY']!;
  static final String _secretKey = dotenv.env['DURP_SECRET_KEY']!;
  static const String _baseUrl = "https://prod.mydupr.com/api/v1.0";
  final _dio = Dio();
  late String _bearerToken;
  String? duprId;

  Future<DuprModel> getDupr({String? email}) async {
    _bearerToken = await _getBearerToken();
    if (_bearerToken == "") {
      return DuprModel(status: 'error');
    }
    if (duprId == null || duprId == "") {
      duprId = await _getDuprIdByEmail(email!);
      if (duprId == "") {
        return DuprModel(status: 'error');
      }
    }
    Map<String, dynamic> data = await _getRatingInfo(duprId!);
    debugPrint("$data");
    return DuprModel.fromMap(data);
  }

  String _xAuth() {
    List<int> bytes = utf8.encode("$_clientKey:$_secretKey"); // Convert string to bytes
    String base64String = base64Encode(bytes); // Encode to Base64
    return base64String;
  }

  Future<Map<String, dynamic>> _getRatingInfo(String _duprId) async {
    try {
      var response = await _dio.post("$_baseUrl/player",
          data: {
            "duprIds": [
              _duprId
            ],
            "sortBy": "string"
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $_bearerToken',
                'Accept': '*/*',
                'Content-Type': 'application/json'
              }
          )
      );
      var data = {
        'status': 'success',
        'singles': response.data['results'][0]['ratings']['singles'],
        'doubles': response.data['results'][0]['ratings']['doubles'],
        'duprId': response.data['results'][0]['duprId']
      };
      return data;
    } on DioException catch (e) {
      debugPrint("${e.response?.data}");
      return {
        'status': 'error'
      };
    }
  }

  Future<String> _getBearerToken() async {
    try {
      var response = await _dio.post("https://prod.mydupr.com/api/auth/v1.0/token",
          options: Options(
              headers: {
                'x-authorization': _xAuth(),
                'Accept': 'application/json'
              }
          )
      );
      return response.data['result']['token'];
    } on DioException catch (e) {
      debugPrint("${e.response?.data}");
      return "";
    }
  }

  Future<String> _getDuprIdByEmail(String email) async {
    try {
      var response = await _dio.post("$_baseUrl/player/duprid-by-email",
          data: {
            'email': email
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $_bearerToken',
              }
          )
      );
      return response.data['result'];
    } on DioException catch (e) {
      debugPrint("${e.response?.data}");
      return "";
    }
  }
}