import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/utils/pallete.dart'; // Add intl package to format date

class CustomDateOfBirthField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextStyle? inputTextStyle;
  final Icon? prefixIcon;
  final bool? enabled;

  const CustomDateOfBirthField({
    super.key,
    this.controller,
    required this.labelText,
    this.labelStyle,
    this.inputTextStyle,
    required this.prefixIcon,
    this.enabled,
  });

  @override
  _CustomDateOfBirthFieldState createState() => _CustomDateOfBirthFieldState();
}

class _CustomDateOfBirthFieldState extends State<CustomDateOfBirthField> {
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy'); // Formatting date
  String? _errorMessage; // To show error if user is underage

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary:
                  AppColors.primaryColor, // Change the primary color to yellow
              onPrimary: Colors.white, // Text color on the primary color
              onSurface: AppColors.primaryColor, // Text color on the surface
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ), // Background color of the dialog
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final int userAge = _calculateAge(pickedDate);
      if (userAge < 5) {
        setState(() {
          _errorMessage = 'You are under age';
          widget.controller?.text = '';
        });
      } else {
        setState(() {
          _errorMessage = null; // Clear error if age is valid
          widget.controller?.text = _dateFormat.format(pickedDate);
        });
      }
    }
  }

  int _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (birthDate.month > today.month ||
        (birthDate.month == today.month && birthDate.day > today.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.enabled ?? true ? () => _selectDate(context) : null,
          child: AbsorbPointer(
            // Prevent typing, only allow date picker
            child: TextField(
              controller: widget.controller,
              cursorColor: Colors.black, // Set cursor color to black
              decoration: InputDecoration(
                fillColor: Colors.white, // Customize as needed
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: widget.prefixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                labelText: widget.labelText ?? '',
                labelStyle:
                    widget.labelStyle ??
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
              ),
              style:
                  widget.inputTextStyle ??
                  TextStyle(color: AppColors.primaryColor, fontSize: 12),
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
