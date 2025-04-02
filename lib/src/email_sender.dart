import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitch/src/res/html_content.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  static Future<void> sendEmail({required String recipientEmail, bool isAccepted = false}) async {
    // Email credentials (replace with your actual email and password)
    final String username = dotenv.env['SENDER_EMAIL']!;
    final String password = dotenv.env['PASSWORD']!;

    // SMTP server configuration
    final smtpServer = gmail(username, password);

    String subject = isAccepted ? '🎾❤️Accepted Hitch Request' : "🎾❤️Request to Play";
    String htmlContent = isAccepted ? EmailHtmlContent.requestAcceptedHtmlContent : EmailHtmlContent.requestReceiveHtmlContent;
    // Create the email message
    final message = Message()
      ..from =  Address(username, 'Hitch Player Finder')
      ..recipients.add(recipientEmail) // Add the recipient email
      ..subject = subject
      ..html = htmlContent; // Use HTML content

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);
      debugPrint('Email sent: ${sendReport.toString()}');
    } catch (e) {
      debugPrint('Email not sent: $e');
    }
  }
}