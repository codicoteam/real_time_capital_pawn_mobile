import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_button.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/attachment_model.dart';
import '../helpers/attached_files_mngmt_helper.dart';

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

class AssetUploadSection extends StatefulWidget {
  final List<UploadedAsset> uploadedAssets;
  final String? selectedLoanCategory;
  final Function(List<UploadedAsset>) onAssetsUpdated;
  final String entityType;
  final String entityId;

  const AssetUploadSection({
    Key? key,
    required this.uploadedAssets,
    required this.selectedLoanCategory,
    required this.onAssetsUpdated,
    required this.entityType,
    required this.entityId,
  }) : super(key: key);

  @override
  State<AssetUploadSection> createState() => _AssetUploadSectionState();
}

class _AssetUploadSectionState extends State<AssetUploadSection> {
  late List<UploadedAsset> _uploadedAssets;
  int? _selectedAssetIndex;
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadMessage = '';

  @override
  void initState() {
    super.initState();
    _uploadedAssets = List.from(widget.uploadedAssets);
  }

  @override
  void didUpdateWidget(covariant AssetUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uploadedAssets != oldWidget.uploadedAssets) {
      setState(() {
        _uploadedAssets = List.from(widget.uploadedAssets);
      });
    }
  }

  void _notifyParent() {
    widget.onAssetsUpdated(_uploadedAssets);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _showAssetDetailsModal(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _showAssetUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildAssetUploadModal();
      },
    );
  }

  void _showAssetDetailsModal(File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return AssetDetailsModal(
          imageFile: imageFile,
          selectedLoanCategory: widget.selectedLoanCategory,
          onAssetSaved: (assetName, serialNumber, conditionNotes) async {
            await _uploadAssetToSupabase(
              imageFile: imageFile,
              assetName: assetName,
              serialNumber: serialNumber,
              conditionNotes: conditionNotes,
            );
          },
        );
      },
    );
  }

  Future<void> _uploadAssetToSupabase({
    required File imageFile,
    required String assetName,
    required String serialNumber,
    required String conditionNotes,
  }) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadMessage = 'Preparing upload...';
    });

    try {
      // Step 1: Upload to Supabase Storage (NO AUTH NEEDED - Public bucket)
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${assetName.replaceAll(' ', '_')}.jpg';
      final filePath = 'attachments/$fileName';

      setState(() {
        _uploadProgress = 0.2;
        _uploadMessage = 'Uploading to storage...';
      });

      DevLogs.logInfo('📤 Uploading to storage: $filePath');

      // Direct upload - no auth checks
      await _supabase.storage
          .from('topics')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      DevLogs.logInfo('✅ File uploaded to storage');

      setState(() {
        _uploadProgress = 0.5;
        _uploadMessage = 'Getting public URL...';
      });

      // Get public URL
      final publicUrl = _supabase.storage.from('topics').getPublicUrl(filePath);
      DevLogs.logInfo('🔗 Public URL: $publicUrl');

      setState(() {
        _uploadProgress = 0.7;
        _uploadMessage = 'Registering attachment...';
      });

      // Step 2: Register attachment in backend
      final metaData =
          '{"asset_name":"$assetName","serial_number":"$serialNumber","condition_notes":"$conditionNotes"}';

      DevLogs.logInfo('💾 Registering attachment in database...');

      final attachmentModel = await AttachmentHelper.uploadAttachment(
        entityType: widget.entityType,
        entityId: widget.entityId,
        category: widget.selectedLoanCategory ?? 'general',
        filename: fileName,
        mimeType: 'image/jpeg',
        url: publicUrl,
        meta: metaData,
      );

      setState(() {
        _uploadProgress = 0.9;
        _uploadMessage = 'Finalizing...';
      });

      if (attachmentModel != null) {
        // Success! Create UploadedAsset and add to list
        final newAsset = UploadedAsset.fromAttachmentModel(
          attachmentModel,
          localFile: imageFile,
        );

        setState(() {
          _uploadedAssets.add(newAsset);
          _uploadProgress = 1.0;
          _uploadMessage = 'Upload complete!';
        });

        _notifyParent();

        DevLogs.logInfo('🎉 Asset uploaded successfully!');

        // Show success message
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Asset uploaded successfully!')),
                ],
              ),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to save attachment to database');
      }
    } on StorageException catch (e) {
      DevLogs.logError('❌ Storage Exception: ${e.toString()}');
      DevLogs.logError('   Status Code: ${e.statusCode}');
      DevLogs.logError('   Error: ${e.error}');
      DevLogs.logError('   Message: ${e.message}');

      if (mounted) {
        String errorMessage = 'Upload failed: ';

        // Check if it's a permission error
        if (e.statusCode == '403' || e.statusCode == 403) {
          errorMessage +=
              'Access denied. Make sure the storage bucket is public in Supabase Dashboard.';
        } else {
          errorMessage += e.message!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      DevLogs.logError('❌ General Exception: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Upload failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadMessage = '';
        });
      }
    }
  }

  Widget _buildAssetUploadModal() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Asset',
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
          const SizedBox(height: 24),
          Text(
            'Choose an upload method',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 16),

          // Upload Options
          Row(
            children: [
              Expanded(
                child: _buildUploadOption(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can add asset details after selecting an image',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAssetDetails(int index) {
    setState(() {
      _selectedAssetIndex = index;
    });
    _showAssetEditModal(index);
  }

  void _showAssetEditModal(int index) {
    final asset = _uploadedAssets[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return AssetEditModal(
          asset: asset,
          onAssetUpdated: (updatedAsset) {
            setState(() {
              _uploadedAssets[index] = updatedAsset;
            });
            _notifyParent();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('Asset details updated!')),
                  ],
                ),
                backgroundColor: AppColors.successColor,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          onAssetRemoved: () {
            setState(() {
              _uploadedAssets.removeAt(index);
            });
            _notifyParent();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('Asset removed')),
                  ],
                ),
                backgroundColor: AppColors.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAssetThumbnail(int index) {
    final asset = _uploadedAssets[index];
    return GestureDetector(
      onTap: () => _editAssetDetails(index),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              image: DecorationImage(
                image: asset.localFile != null
                    ? FileImage(asset.localFile!)
                    : NetworkImage(asset.imageUrl) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                asset.filename ?? 'Asset ${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildUploadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child:
            Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated circular progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: _uploadProgress,
                              strokeWidth: 10,
                              backgroundColor: AppColors.borderColor
                                  .withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                          Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_rounded,
                                  size: 45,
                                  color: AppColors.primaryColor,
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(
                                duration: 2000.ms,
                                color: AppColors.primaryColor.withOpacity(0.5),
                              )
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.15, 1.15),
                                duration: 1000.ms,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.15, 1.15),
                                end: const Offset(1, 1),
                                duration: 1000.ms,
                              ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Progress percentage
                      Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              letterSpacing: 2,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2000.ms,
                            color: AppColors.primaryColor.withOpacity(0.5),
                          ),
                      const SizedBox(height: 12),

                      // Upload message
                      Text(
                            _uploadMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fadeIn(duration: 1000.ms)
                          .then()
                          .fadeOut(duration: 1000.ms),
                      const SizedBox(height: 20),

                      // Linear progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 10,
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            backgroundColor: AppColors.borderColor.withOpacity(
                              0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Uploading steps indicator
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepIndicator(
                              'Storage',
                              _uploadProgress >= 0.5,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.subtextColor,
                            ),
                            const SizedBox(width: 6),
                            _buildStepIndicator(
                              'Database',
                              _uploadProgress >= 0.9,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.subtextColor,
                            ),
                            const SizedBox(width: 6),
                            _buildStepIndicator('Done', _uploadProgress >= 1.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryColor.withOpacity(0.2)
            : AppColors.borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.primaryColor
              : AppColors.borderColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Icon(Icons.check_circle, size: 12, color: AppColors.primaryColor),
          if (isActive) const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primaryColor : AppColors.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSectionCard(
          title: 'Upload Assets',
          icon: Icons.cloud_upload_outlined,
          children: [
            // Uploaded Assets Grid
            if (_uploadedAssets.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _uploadedAssets.length,
                itemBuilder: (context, index) {
                  return _buildAssetThumbnail(index);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Upload Button
            CustomButton(
              btnColor: _isUploading
                  ? AppColors.borderColor.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: 12,
              width: double.infinity,
              height: 48,
              boxBorder: Border.all(
                color: _isUploading
                    ? AppColors.borderColor
                    : AppColors.primaryColor,
                width: 1.5,
              ),
              onTap: _isUploading ? () {} : () => _showAssetUploadModal(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 20,
                    color: _isUploading
                        ? AppColors.subtextColor
                        : AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isUploading ? 'Uploading...' : 'Add Asset',
                    style: GoogleFonts.poppins(
                      color: _isUploading
                          ? AppColors.subtextColor
                          : AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (_uploadedAssets.isEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.subtextColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Upload at least one asset photo',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Upload overlay
        if (_isUploading) _buildUploadingOverlay(),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

// Asset Details Modal
class AssetDetailsModal extends StatefulWidget {
  final File imageFile;
  final String? selectedLoanCategory;
  final Function(String assetName, String serialNumber, String conditionNotes)
  onAssetSaved;

  const AssetDetailsModal({
    Key? key,
    required this.imageFile,
    required this.selectedLoanCategory,
    required this.onAssetSaved,
  }) : super(key: key);

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
                  color: AppColors.primaryColor.withOpacity(0.3),
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

// Asset Edit Modal
class AssetEditModal extends StatefulWidget {
  final UploadedAsset asset;
  final Function(UploadedAsset) onAssetUpdated;
  final VoidCallback onAssetRemoved;

  const AssetEditModal({
    Key? key,
    required this.asset,
    required this.onAssetUpdated,
    required this.onAssetRemoved,
  }) : super(key: key);

  @override
  State<AssetEditModal> createState() => _AssetEditModalState();
}

class _AssetEditModalState extends State<AssetEditModal> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.asset.meta ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
                  'Edit Asset Details',
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
            const SizedBox(height: 24),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
                image: DecorationImage(
                  image: widget.asset.localFile != null
                      ? FileImage(widget.asset.localFile!)
                      : NetworkImage(widget.asset.imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Asset ID: ${widget.asset.id ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Asset Description',
              prefixIcon: const Icon(Icons.description_outlined, size: 20),
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    btnColor: AppColors.errorColor,
                    borderRadius: 12,
                    width: double.infinity,
                    onTap: () {
                      widget.onAssetRemoved();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Remove',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    btnColor: AppColors.primaryColor,
                    borderRadius: 12,
                    width: double.infinity,
                    onTap: () {
                      final updatedAsset = UploadedAsset(
                        id: widget.asset.id,
                        category: widget.asset.category,
                        filename: widget.asset.filename,
                        mimeType: widget.asset.mimeType,
                        url: widget.asset.url,
                        localFile: widget.asset.localFile,
                        meta: _descriptionController.text,
                        createdAt: widget.asset.createdAt,
                      );

                      widget.onAssetUpdated(updatedAsset);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
