import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class LottieAnimWidget extends StatelessWidget{
  final String anim;
  final bool repeat;
  const LottieAnimWidget({super.key, required this.anim, this.repeat = false});
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(anim, repeat: repeat);
  }

}