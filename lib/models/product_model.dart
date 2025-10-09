// lib/models/product_model.dart
import 'package:pocketbase/pocketbase.dart';

class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  // Factory constructor เพื่อแปลง RecordModel เป็น Product
  factory Product.fromRecord(RecordModel record) {
    return Product(
      id: record.id,
      name: record.data['name'] as String,
      price: (record.data['price'] as num).toDouble(),
    );
  }
}