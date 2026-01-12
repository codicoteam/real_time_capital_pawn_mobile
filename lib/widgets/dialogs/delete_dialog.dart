import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';

class DeleteDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;
  const DeleteDialog({super.key, required this.itemName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Column(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
          SizedBox(width: 8),
          Text(
            'Confirm Deletion',
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
            'Are you sure you want to delete\n$itemName?',
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
              btnColor: Colors.redAccent,
              child: const Text(
                'Delete',
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
