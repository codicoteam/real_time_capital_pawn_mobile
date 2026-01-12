import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class CustomPasswordTextfield extends StatefulWidget {
  final Color? fillColor;
  final bool? filled;
  final Color? focusedBoarderColor;
  final Color? defaultBoarderColor;
  final TextEditingController? controller;
  final String? labelText;
  final void Function(String?)? onChanged;
  final bool? obscureText;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final TextInputType? keyBoardType;
  final Icon? prefixIcon;
  final int? maxLength;
  final bool? enabled;

  const CustomPasswordTextfield({
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
    this.keyBoardType,
    required this.prefixIcon,
    this.obscureText,
    this.enabled,
    this.onChanged,
  });

  @override
  State<CustomPasswordTextfield> createState() => _CustomPasswordTextfieldState();
}

class _CustomPasswordTextfieldState extends State<CustomPasswordTextfield> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: widget.maxLength,
      keyboardType: widget.keyBoardType ?? TextInputType.text,
      obscureText: _obscureText,
      controller: widget.controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled ?? true,
      decoration: InputDecoration(
        fillColor: widget.fillColor,
        filled: widget.filled ?? false,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText != null
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: _toggleObscureText,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: widget.defaultBoarderColor ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: widget.defaultBoarderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: widget.focusedBoarderColor ?? AppColors.primaryColor),
        ),
        labelText: widget.labelText ?? '',
        labelStyle: widget.labelStyle ?? GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      style: widget.inputTextStyle ?? TextStyle(
        color: AppColors.primaryColor,
        fontSize: 12,
      ),
    );
  }
}
