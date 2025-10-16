import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;          // ใช้ multipart ของ http
import 'package:pocketbase/pocketbase.dart';

import '../models/product_model.dart';

class PBService {
  /// ปรับให้ตรงกับเครื่อง (PC: 127.0.0.1, Android Emulator: 10.0.2.2)
  static const String baseUrl = 'http://127.0.0.1:8090';
  static final PocketBase pb = PocketBase(baseUrl);
  static const String collection = 'products';

  static Future<List<Product>> list() async {
    final recs = await pb.collection(collection).getFullList(sort: '-created');
    return recs.map((r) => Product.fromRecord(r.toJson())).toList();
  }

  static Future<RecordModel> create({
    required String name,
    required double price,
    String status = 'available',
    XFile? image,
  }) async {
    final body = {'name': name, 'price': price, 'status': status};
    final files = await _multipartFromXFile(image);
    return pb.collection(collection).create(body: body, files: files);
  }

  static Future<RecordModel> update({
    required String id,
    required String name,
    required double price,
    String status = 'available',
    XFile? image,
  }) async {
    final body = {'name': name, 'price': price, 'status': status};
    final files = await _multipartFromXFile(image);
    return pb.collection(collection).update(id, body: body, files: files);
  }

  static Future<void> remove(String id) =>
      pb.collection(collection).delete(id);

  // รองรับทั้งเว็บ (bytes) และมือถือ/เดสก์ท็อป (path)
  static Future<List<http.MultipartFile>> _multipartFromXFile(XFile? x) async {
    if (x == null) return <http.MultipartFile>[];
    final filename = x.name;
    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      return [http.MultipartFile.fromBytes('photo', bytes, filename: filename)];
    } else {
      return [await http.MultipartFile.fromPath('photo', x.path, filename: filename)];
    }
  }
}
