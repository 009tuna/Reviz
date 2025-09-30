import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient sb;
  final String bucket; // ör: 'uploads'
  StorageService(this.sb, {this.bucket = 'uploads'});

  /// Dosyayı yükler, public URL döndürür.
  Future<String> uploadImage(File file, {required String userId}) async {
    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final ext = file.path.split('.').last;
    final object =
        'users/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await sb.storage.from(bucket).uploadBinary(
          object,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

    // bucket public ise:
    final publicUrl = sb.storage.from(bucket).getPublicUrl(object);
    return publicUrl;
  }
}
