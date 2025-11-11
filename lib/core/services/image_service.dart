import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_cropper/image_cropper.dart';  // Disabled for web compatibility
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery with optional compression and cropping
  Future<File?> pickImageFromGallery({
    bool compress = true,
    bool crop = false,
    int quality = 85,
    CropAspectRatio? aspectRatio,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: compress ? quality : 100,
      );

      if (pickedFile == null) return null;

      File imageFile = File(pickedFile.path);

      // Crop if requested
      if (crop) {
        imageFile = await cropImage(imageFile, aspectRatio: aspectRatio) ?? imageFile;
      }

      // Compress if requested
      if (compress) {
        imageFile = await compressImage(imageFile, quality: quality) ?? imageFile;
      }

      return imageFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick image from camera with optional compression and cropping
  Future<File?> pickImageFromCamera({
    bool compress = true,
    bool crop = false,
    int quality = 85,
    CropAspectRatio? aspectRatio,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: compress ? quality : 100,
      );

      if (pickedFile == null) return null;

      File imageFile = File(pickedFile.path);

      // Crop if requested
      if (crop) {
        imageFile = await cropImage(imageFile, aspectRatio: aspectRatio) ?? imageFile;
      }

      // Compress if requested
      if (compress) {
        imageFile = await compressImage(imageFile, quality: quality) ?? imageFile;
      }

      return imageFile;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({
    bool compress = true,
    int quality = 85,
    int maxImages = 10,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: compress ? quality : 100,
      );

      if (pickedFiles.isEmpty) return [];

      // Limit number of images
      final limitedFiles = pickedFiles.take(maxImages).toList();

      List<File> imageFiles = [];
      for (var pickedFile in limitedFiles) {
        File imageFile = File(pickedFile.path);

        if (compress) {
          imageFile = await compressImage(imageFile, quality: quality) ?? imageFile;
        }

        imageFiles.add(imageFile);
      }

      return imageFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Compress an image file
  Future<File?> compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed${path.extension(file.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Crop an image
  /// NOTE: Image cropping is disabled for web compatibility.
  /// Returns the original file without cropping.
  Future<File?> cropImage(
    File file, {
    dynamic aspectRatio,  // Changed from CropAspectRatio? to dynamic
    List<dynamic>? aspectRatioPresets,  // Changed from List<CropAspectRatioPreset>?
  }) async {
    try {
      // Image cropping is currently disabled for web compatibility
      // TODO: Re-enable when image_cropper supports web or find alternative
      debugPrint('Image cropping is disabled - returning original image');
      return file;

      /* Original implementation - disabled for web compatibility
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: aspectRatio,
        aspectRatioPresets: aspectRatioPresets ?? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF6366F1),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
          ),
        ],
      );

      return croppedFile != null ? File(croppedFile.path) : null;
      */
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Get image file size in bytes
  Future<int> getImageSize(File file) async {
    return await file.length();
  }

  /// Get image file size in human-readable format
  Future<String> getImageSizeFormatted(File file) async {
    final bytes = await getImageSize(file);
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Delete temporary image files
  Future<void> cleanupTempImages() async {
    try {
      final dir = await getTemporaryDirectory();
      final files = dir.listSync();

      for (var file in files) {
        if (file is File &&
            (file.path.endsWith('.jpg') ||
             file.path.endsWith('.jpeg') ||
             file.path.endsWith('.png'))) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp images: $e');
    }
  }
}
