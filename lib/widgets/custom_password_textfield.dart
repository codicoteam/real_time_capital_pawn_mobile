import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class CustomPasswordTextfield extends StatefulWidget {
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
  final bool? obscureText;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final TextInputType? keyboardType;
  final Icon? prefixIcon;
  final int? maxLength;
  final bool? enabled;
  final bool? readOnly;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final bool autoValidate;
  final String? initialErrorText;
  final void Function(String)? onStrengthChanged;

  const CustomPasswordTextfield({
    super.key,
    this.maxLength,
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
    this.enabled,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.readOnly,
    this.focusNode,
    this.validator,
    this.autoValidate = false,
    this.initialErrorText,
    this.onStrengthChanged,
  });

  @override
  State<CustomPasswordTextfield> createState() => _CustomPasswordTextfieldState();
}

class _CustomPasswordTextfieldState extends State<CustomPasswordTextfield> {
  bool _obscureText = true;
  late FocusNode _internalFocusNode;
  String? _errorText;
  bool _hasBeenTouched = false;
  bool _isValidating = false;
  int _passwordStrength = 0;

  // Password strength criteria
  bool get _hasMinLength => (widget.controller?.text.length ?? 0) >= 8;
  bool get _hasUppercase => (widget.controller?.text ?? '').contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => (widget.controller?.text ?? '').contains(RegExp(r'[a-z]'));
  bool get _hasNumber => (widget.controller?.text ?? '').contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => (widget.controller?.text ?? '').contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? true;
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _errorText = widget.initialErrorText;
    
    // Add listener for focus changes
    _internalFocusNode.addListener(_onFocusChange);
    
    // Initial validation if autoValidate is true and there's initial error text
    if (widget.autoValidate && widget.initialErrorText != null) {
      _errorText = widget.initialErrorText;
    }
    
    // Add controller listener for real-time strength updates
    if (widget.onStrengthChanged != null) {
      widget.controller?.addListener(_updatePasswordStrength);
      _updatePasswordStrength();
    }
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    if (widget.onStrengthChanged != null) {
      widget.controller?.removeListener(_updatePasswordStrength);
    }
    super.dispose();
  }

  void _updatePasswordStrength() {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasUppercase) strength++;
    if (_hasLowercase) strength++;
    if (_hasNumber) strength++;
    if (_hasSpecialChar) strength++;
    
    if (strength != _passwordStrength) {
      setState(() {
        _passwordStrength = strength;
      });
      widget.onStrengthChanged?.call(_getStrengthLabel());
    }
  }

  String _getStrengthLabel() {
    if (_passwordStrength <= 1) return 'Weak';
    if (_passwordStrength <= 3) return 'Medium';
    return 'Strong';
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 1) return Colors.red;
    if (_passwordStrength <= 3) return Colors.orange;
    return Colors.green;
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
    
    // Update password strength on every change
    if (widget.onStrengthChanged != null) {
      _updatePasswordStrength();
    }
    
    widget.onChanged?.call(value);
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          obscureText: _obscureText,
          controller: widget.controller,
          onChanged: _onTextChanged,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          enabled: widget.enabled ?? true,
          readOnly: widget.readOnly ?? false,
          focusNode: _internalFocusNode,
          decoration: InputDecoration(
            fillColor: widget.fillColor ?? Colors.white,
            filled: widget.filled ?? true,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: widget.prefixIcon,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _toggleObscureText,
            ),
            errorText: _errorText,
            errorMaxLines: 2,
            errorStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: widget.errorBorderColor ?? Colors.red.shade700,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? (widget.errorBorderColor ?? Colors.red.shade400)
                    : (widget.defaultBorderColor ?? Colors.grey.shade400),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? (widget.errorBorderColor ?? Colors.red.shade400)
                    : (widget.defaultBorderColor ?? Colors.grey.shade400),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? (widget.errorBorderColor ?? Colors.red.shade400)
                    : (widget.focusedBorderColor ?? AppColors.primaryColor),
                width: _errorText != null ? 2 : 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: widget.errorBorderColor ?? Colors.red.shade400,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: widget.errorBorderColor ?? Colors.red.shade400,
                width: 2,
              ),
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
        ),
        
        // Password strength indicator (only show if user has typed something)
        if (widget.onStrengthChanged != null && 
            widget.controller != null && 
            widget.controller!.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2 * _passwordStrength,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _getStrengthColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength:',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _getStrengthLabel(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStrengthColor(),
                ),
              ),
            ],
          ),
          // Password requirements checklist
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildRequirementChip('8+ chars', _hasMinLength),
              _buildRequirementChip('Uppercase', _hasUppercase),
              _buildRequirementChip('Lowercase', _hasLowercase),
              _buildRequirementChip('Number', _hasNumber),
              _buildRequirementChip('Special char', _hasSpecialChar),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRequirementChip(String label, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMet ? Colors.green : Colors.grey,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}