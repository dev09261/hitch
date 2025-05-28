import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:hitch/src/res/app_text_styles.dart';

class HitchSliderWidget extends StatefulWidget{
  const HitchSliderWidget({super.key,required this.onChange, this.distanceFromCurrentLocation = 10, this.isScrollable = true});
  final Function(double value) onChange;
  final double distanceFromCurrentLocation;
  final bool isScrollable;
  @override
  State<HitchSliderWidget> createState() => _HitchSliderWidgetState();
}

class _HitchSliderWidgetState extends State<HitchSliderWidget> {
  late double _currentValue;
  ui.Image? _thumbImage;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.distanceFromCurrentLocation;
    _loadImage();
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/icons/pickBall.png');
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _thumbImage = frameInfo.image;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.lightGreen,
              inactiveTrackColor: Colors.grey.shade300,
              trackHeight: 6.0,
              trackShape: CustomTrackShape(),

              thumbShape: CustomThumbShape(_thumbImage),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
            ),
            child: Slider(
              min: 5.0,
              max: 20.0,
              value: _currentValue,
              onChanged: (value) {
                widget.onChange(value);
                if(widget.isScrollable){
                  setState(() {
                    _currentValue = value;
                  });
                }

              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("5 miles", style: AppTextStyles.regularTextStyle.copyWith(fontSize: 14),),
            Text("10 miles", style: AppTextStyles.regularTextStyle.copyWith(fontSize: 14),),
            Text("20 miles", style: AppTextStyles.regularTextStyle.copyWith(fontSize: 14),)
          ],
        ),

      ],
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  final ui.Image? thumbImage;

  CustomThumbShape(this.thumbImage);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(40, 40); // Size of the thumb
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    if (thumbImage != null) {
      // Draw the image at the thumb's center
      const double imageSize = 40.0;
      final Offset imageOffset = center - const Offset(imageSize / 2, imageSize / 2);
      canvas.drawImage(thumbImage!, imageOffset, Paint());
    } else {
      // Optionally, you can draw a fallback shape if the image is not loaded
      final Paint fallbackPaint = Paint()..color = Colors.lightGreen;
      canvas.drawCircle(center, 20.0, fallbackPaint);
    }
  }
}


class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}