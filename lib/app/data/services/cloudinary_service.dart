import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File;

class CloudinaryService {
  static Future<String?> uploadImage(
    dynamic imageFileOrBytes, {
    required String fileName,
  }) async {
    try {
      const cloudName = 'dzzo7hzht';
      const uploadPreset = 'jejak_rasa';

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        // Web: image bytes dari picker (XFile.readAsBytes)
        final Uint8List bytes = imageFileOrBytes as Uint8List;
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: fileName),
        );
      } else {
        // Android/iOS: image path dari File
        final File imageFile = imageFileOrBytes as File;
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            filename: fileName,
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return data['secure_url'];
      }

      return null;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }
}
