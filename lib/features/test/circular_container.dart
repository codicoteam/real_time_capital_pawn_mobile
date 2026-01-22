import 'package:flutter/material.dart';

class TCircularContainer extends StatelessWidget {
  const TCircularContainer({
    super.key,
    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.backgroundColor = Colors.white,
  });

  final double? width;
  final double? height;
  final double? radius;
  final double? padding;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(400),
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }
}
