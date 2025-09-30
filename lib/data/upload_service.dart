import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class UploadService {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient sb;
  UploadService(this.sb);

  Future<List<File>> pickImages({int max = 5}) async {
    final list = await _picker.pickMultiImage();
    return (list).take(max).map((x) => File(x.path)).toList();
  }

  Future<List<String>> uploadImages({
    required List<File> files,
    required String bucket, // örn: 'request_images'
    required String userId,
  }) async {
    final urls = <String>[];
    for (final f in files) {
      final key =
          'users/$userId/${DateTime.now().millisecondsSinceEpoch}_${p.basename(f.path)}';
      await sb.storage.from(bucket).upload(key, f);
      final pub = sb.storage.from(bucket).getPublicUrl(key);
      urls.add(pub);
    }
    return urls;
  }
}
