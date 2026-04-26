import 'package:flutter/material.dart';
import '../../core/utils/pallete.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomTextField extends StatefulWidget {
  final Color? fillColor;
  final bool? filled;
  final Color? focusedBorderColor;
  final Color? defaultBorderColor;
  final Color? errorBorderColor;
  final TextEditingController? controller;
  final String? labelText;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSubmitted;
  final VoidCallback? onEditingComplete;
  final void Function(PointerDownEvent?)? onTapOutSide;
  final bool? obscureText;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final int? maxLength;
  final Widget? suffixIconButton;
  final bool? enabled;
  final bool? readOnly;
  final double? borderRadius;
  final EdgeInsets? contentPadding;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final bool autoValidate;
  final String? initialErrorText;

  const CustomTextField({
    super.key,
    this.maxLength,
    this.readOnly,
    this.controller,
    this.fillColor,
    this.filled,
    this.defaultBorderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    required this.labelText,
    this.labelStyle,
    this.inputTextStyle,
    this.keyboardType,
    this.prefixIcon,
    this.obscureText,
    this.suffixIconButton,
    this.enabled,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTapOutSide,
    this.borderRadius,
    this.contentPadding,
    this.focusNode,
    this.validator,
    this.autoValidate = false,
    this.initialErrorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _internalFocusNode;
  String? _errorText;
  bool _hasBeenTouched = false;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _errorText = widget.initialErrorText;
    
    // Add listener for focus changes
    _internalFocusNode.addListener(_onFocusChange);
    
    // Initial validation if autoValidate is true and there's initial error text
    if (widget.autoValidate && widget.initialErrorText != null) {
      _errorText = widget.initialErrorText;
    }
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_internalFocusNode.hasFocus && _hasBeenTouched) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null && !_isValidating) {
      _isValidating = true;
      final error = widget.validator!(widget.controller?.text);
      if (mounted) {
        setState(() {
          _errorText = error;
          _isValidating = false;
        });
      } else {
        _isValidating = false;
      }
    }
  }

  void _onTextChanged(String? value) {
    if (!_hasBeenTouched && value != null && value.isNotEmpty) {
      setState(() {
        _hasBeenTouched = true;
      });
    }
    
    if (widget.autoValidate && _hasBeenTouched) {
      _validateField();
    }
    
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          obscureText: widget.obscureText ?? false,
          controller: widget.controller,
          onChanged: _onTextChanged,
          readOnly: widget.readOnly ?? false,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          onTapOutside: widget.onTapOutSide ?? (event){
            FocusScope.of(context).unfocus();
          },
          enabled: widget.enabled ?? true,
          focusNode: _internalFocusNode,
          decoration: InputDecoration(
            fillColor: widget.fillColor ?? Colors.white,
            filled: widget.filled ?? true,
            counterText: '',
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIconButton,
            errorText: _errorText,
            errorMaxLines: 2,
            errorStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: widget.errorBorderColor ?? Colors.red.shade700,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? (widget.errorBorderColor ?? Colors.red.shade400)
                    : (widget.defaultBorderColor ?? Colors.grey.shade400),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? (widget.errorBorderColor ?? Colors.red.shade400)
                    : (widget.defaultBorderColor ?? Colors.grey.shade400),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? (widget.errorBorderColor ?? Colors.red.shade400)
                    : (widget.focusedBorderColor ?? AppColors.primaryColor),
                width: _errorText != null ? 2 : 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
              borderSide: BorderSide(
                color: widget.errorBorderColor ?? Colors.red.shade400,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
              borderSide: BorderSide(
                color: widget.errorBorderColor ?? Colors.red.shade400,
                width: 2,
              ),
            ),
            hintText: widget.labelText,
            labelStyle: widget.labelStyle ??
                Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey),
          ),
          style: widget.inputTextStyle ??
              Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryColor,
              ),
        ),
      ],
    );
  }
}

// Helper extension for GoogleFonts if not already imported
