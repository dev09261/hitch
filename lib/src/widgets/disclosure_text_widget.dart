import 'package:flutter/cupertino.dart';
import '../res/string_constants.dart';

class DisclosureTextWidget extends StatelessWidget{
  const DisclosureTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(disclosureText, style: TextStyle(fontSize: 12, color: Color(0xff626262), height: 1.8),);
  }
}