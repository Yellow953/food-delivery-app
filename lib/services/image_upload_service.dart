import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks images from gallery and uploads them to Firebase Storage.
class ImageUploadService {
  static final _picker = ImagePicker();

  /// Picks a single image and uploads it to [storagePath].
  /// Returns the download URL on success, null if cancelled or failed.
  static Future<String?> pickAndUpload(String storagePath) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked == null) return null;
      return await _upload(picked.path, storagePath);
    } catch (_) {
      return null;
    }
  }

  /// Picks multiple images and uploads each to [storageFolder]/{timestamp}_{i}.jpg.
  /// Returns list of download URLs for successfully uploaded images.
  static Future<List<String>> pickMultipleAndUpload(
      String storageFolder) async {
    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked.isEmpty) return [];
      final ts = DateTime.now().millisecondsSinceEpoch;
      final futures = picked.asMap().entries.map((e) => _upload(
            e.value.path,
            '$storageFolder/${ts}_${e.key}.jpg',
          ));
      final results = await Future.wait(futures);
      return results.whereType<String>().toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String?> _upload(String localPath, String storagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref(storagePath);
      final task = await ref.putFile(File(localPath));
      return await task.ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
