import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkifyTextMessage extends StatelessWidget {
  final String messageText;
  final bool isReceiver;
  const LinkifyTextMessage({super.key, required this.messageText, this.isReceiver = false});

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      linkifyText(messageText),
      textAlign: TextAlign.start,
    );
  }

  TextSpan linkifyText(String text) {
    final RegExp urlRegExp = RegExp(
      r'((https?:\/\/)?(www\.)?[a-zA-Z0-9\-_]+(\.[a-zA-Z]{2,})+(\/[^\s]*)?)',
      caseSensitive: false,
    );

    List<TextSpan> spans = [];
    text.splitMapJoin(
      urlRegExp,
      onMatch: (Match match) {
        String url = match.group(0)!;
        if (!url.startsWith('http')) {
          url = 'https://$url';
        }
        spans.add(
          TextSpan(
            text: match.group(0),
            style: const TextStyle(
                color: AppColors.blueColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                fontFamily: 'Inter',
                decorationColor: AppColors.blueColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
        return match.group(0)!;
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(
          text: nonMatch,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: isReceiver ? Colors.black : Colors.white),
        ));
        return nonMatch;
      },
    );

    return TextSpan(children: spans);
  }
}