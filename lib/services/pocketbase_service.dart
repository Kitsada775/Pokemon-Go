// lib/services/pocketbase_service.dart
import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final pb = PocketBase('http://127.0.0.1:8090'); // <-- ใส่ URL ของคุณ

  // CREATE
  Future<void> createProduct(String name, double price) async {
    final body = <String, dynamic>{
      "name": name,
      "price": price,
    };
    await pb.collection('products').create(body: body);
  }

  // READ (List)
  Future<List<RecordModel>> fetchProducts() async {
    final records = await pb.collection('products').getFullList(
          sort: '-created',
        );
    return records;
  }

  // UPDATE
  Future<void> updateProduct(String id, String name, double price) async {
    final body = <String, dynamic>{
      "name": name,
      "price": price,
    };
    await pb.collection('products').update(id, body: body);
  }

  // DELETE
  Future<void> deleteProduct(String id) async {
    await pb.collection('products').delete(id);
  }
}