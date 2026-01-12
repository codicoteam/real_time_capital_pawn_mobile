import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_button/general_button.dart';

class ConformationDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;
  final IconData icon;
  const ConformationDialog({super.key, required this.itemName,  required this.icon,required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Column(
        children: [
          Icon(icon, color: Colors.green, size: 40),
          SizedBox(width: 8),
          Text(
            'Confirm Approve',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 20
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to approve\n$itemName?',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GeneralButton(
              width: 100, 
              onTap: (){
                Get.back();
              },
              btnColor: Colors.grey,
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            GeneralButton(
              width: 100,
              onTap: (){
                Get.back();
                onConfirm();
              },
              btnColor: Colors.green,
              child: const Text(
                'Approve',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
