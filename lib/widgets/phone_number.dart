import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/utils/pallete.dart';

class CustomPhoneNumberField extends StatelessWidget {
  Color? fillColor;
  bool? filled;
  Color? focusedBoarderColor;
  Color? defaultBoarderColor;
  TextEditingController? controller;
  final String? labelText;
  final void Function(String?)? onChanged;
  final bool? obscureText;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final Icon? prefixIcon;
  int? maxLength;
  Widget? suffixIconButton;
  bool? enabled;

  CustomPhoneNumberField({
    super.key,
    this.maxLength,
    this.controller,
    this.fillColor,
    this.filled,
    this.defaultBoarderColor,
    this.focusedBoarderColor,
    required this.labelText,
    this.labelStyle,
    this.inputTextStyle,
    required this.prefixIcon,
    this.obscureText,
    this.suffixIconButton,
    this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      keyboardType: TextInputType.phone, // Change keyboard to phone number type
      obscureText: obscureText ?? false,
      controller: controller,
      onChanged: onChanged,
      enabled: enabled ?? true,
      cursorColor: Colors.black, // Set the cursor color to black
      decoration: InputDecoration(
        fillColor: fillColor,
        filled: filled ?? false,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIconButton,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: defaultBoarderColor ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: defaultBoarderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: focusedBoarderColor ?? AppColors.primaryColor),
        ),
        labelText: labelText ?? '',
        labelStyle: labelStyle ?? GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      style: inputTextStyle ?? TextStyle(
        color: AppColors.primaryColor,
        fontSize: 12,
      ),
    );
  }
}
