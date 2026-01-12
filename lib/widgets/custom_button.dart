import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color btnColor;
  final double width;
  final double? height;
  final double borderRadius;
  final BoxBorder? boxBorder;
  final Widget child;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.btnColor,
    required this.width,
    required this.borderRadius,
    this.height,
    this.boxBorder,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height, // Let it be null to adapt to content
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: boxBorder,
        ),
        child: child,
      ),
    );
  }
}
