import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request storage/photos permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      // Request camera permission
      bool hasPermission = await requestCameraPermission();

      if (!hasPermission) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      // Request storage permission
      bool hasPermission = await requestStoragePermission();

      if (!hasPermission) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  static Future<List<File>?> pickMultipleImages() async {
    try {
      // Request storage permission
      bool hasPermission = await requestStoragePermission();

      if (!hasPermission) {
        return null;
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        return images.map((xfile) => File(xfile.path)).toList();
      }
      return null;
    } catch (e) {
      print('Error picking multiple images: $e');
      return null;
    }
  }

  // Show bottom sheet to choose camera or gallery
  static Future<File?> showImageSourceDialog(BuildContext context, {bool cameraOnly = false}) async {
    if (cameraOnly) {
      return await pickImageFromCamera();
    }

    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF1976D2)),
                  title: const Text('Camera'),
                  onTap: () async {
                    print('Camera option selected');
                    final file = await pickImageFromCamera();
                    print('Camera returned file: ${file?.path ?? "null"}');
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF1976D2)),
                  title: const Text('Gallery'),
                  onTap: () async {
                    print('Gallery option selected');
                    final file = await pickImageFromGallery();
                    print('Gallery returned file: ${file?.path ?? "null"}');
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
