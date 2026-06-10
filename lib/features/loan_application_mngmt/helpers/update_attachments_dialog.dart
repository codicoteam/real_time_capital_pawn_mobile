import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/attachment_model.dart';
import 'package:real_time_pawn/widgets/custom_button.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import '../../../models/attachment_model.dart' show AttachmentModel;

// ---------------------------------------------------------------------
// Auxiliary classes (UploadedAsset, AssetDetailsModal) – copied from provided code
// ---------------------------------------------------------------------
class UploadedAsset {
  final String? id;
  final String? category;
  final String? filename;
  final String? mimeType;
  final String? url;
  final File? localFile;
  final String? meta;
  final DateTime? createdAt;

  UploadedAsset({
    this.id,
    this.category,
    this.filename,
    this.mimeType,
    this.url,
    this.localFile,
    this.meta,
    this.createdAt,
  });

  factory UploadedAsset.fromAttachmentModel(
    AttachmentModel model, {
    File? localFile,
  }) {
    return UploadedAsset(
      id: model.id,
      category: model.category,
      filename: model.filename,
      mimeType: model.mimeType,
      url: model.url,
      localFile: localFile,
      meta: model.meta,
      createdAt: model.createdAt,
    );
  }

  String get imageUrl {
    if (url != null && url!.isNotEmpty) {
      return url!;
    } else if (localFile != null) {
      return localFile!.path;
    }
    return 'https://picsum.photos/200/200?random=${Random().nextInt(1000)}';
  }
}

// ---------------------------------------------------------------------
// Asset Details Modal (for entering asset info before upload)
// ---------------------------------------------------------------------
class AssetDetailsModal extends StatefulWidget {
  final File imageFile;
  final String? selectedLoanCategory;
  final Function(String assetName, String serialNumber, String conditionNotes)
  onAssetSaved;

  const AssetDetailsModal({
    super.key,
    required this.imageFile,
    required this.selectedLoanCategory,
    required this.onAssetSaved,
  });

  @override
  State<AssetDetailsModal> createState() => _AssetDetailsModalState();
}

class _AssetDetailsModalState extends State<AssetDetailsModal> {
  late TextEditingController _assetNameController;
  late TextEditingController _serialNumberController;
  late TextEditingController _conditionNotesController;

  @override
  void initState() {
    super.initState();
    _assetNameController = TextEditingController();
    _serialNumberController = TextEditingController();
    _conditionNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _serialNumberController.dispose();
    _conditionNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Asset Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _assetNameController,
              labelText: 'Asset Name *',
              prefixIcon: const Icon(Icons.description_outlined, size: 20),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _serialNumberController,
              labelText: 'Serial/Model Number',
              prefixIcon: const Icon(Icons.numbers, size: 20),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _conditionNotesController,
              labelText: 'Condition Notes',
              prefixIcon: const Icon(Icons.note_outlined, size: 20),
              maxLength: 200,
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              btnColor: AppColors.primaryColor,
              width: double.infinity,
              borderRadius: 12,
              onTap: () {
                if (_assetNameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Expanded(child: Text('Please enter asset name')),
                        ],
                      ),
                      backgroundColor: AppColors.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                widget.onAssetSaved(
                  _assetNameController.text.trim(),
                  _serialNumberController.text.trim(),
                  _conditionNotesController.text.trim(),
                );
              },
              child: Text(
                'Save Asset',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }
}
