import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import '../services/pocketbase_service.dart';
import 'product_form_screen.dart'; // เดี๋ยวเราจะสร้างไฟล์นี้เป็นไฟล์ถัดไป

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  // สร้าง Future เพื่อรับข้อมูลสินค้า
  late Future<List<RecordModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ฟังก์ชันสำหรับโหลด/รีเฟรชข้อมูล
  void _loadProducts() {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    setState(() {
      _productsFuture = pbService.fetchProducts();
    });
  }

  // ฟังก์ชันสำหรับลบ
  void _deleteProduct(String id) async {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    try {
      await pbService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบสินค้าแล้ว!'), backgroundColor: Colors.green),
      );
      _loadProducts(); // โหลดข้อมูลใหม่หลังลบสำเร็จ
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ฟังก์ชันสำหรับนำทางไปหน้าฟอร์ม (สำหรับเพิ่ม/แก้ไข)
  void _navigateToForm({RecordModel? product}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ProductFormScreen(product: product),
          ),
        )
        .then((_) => _loadProducts()); // เมื่อกลับมาหน้านี้ ให้โหลดข้อมูลใหม่
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสินค้า (PocketBase)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts, // ปุ่มรีเฟรช
          ),
        ],
      ),
      body: FutureBuilder<List<RecordModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีสินค้าในระบบ'));
          }

          final products = snapshot.data!;

          // แสดงผลข้อมูลที่ได้มาด้วย ListView
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(product.data['name']),
                  subtitle: Text('ราคา: ${product.data['price']} บาท'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(product: product), // ปุ่มแก้ไข
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id), // ปุ่มลบ
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // ปุ่มเพิ่มสินค้าใหม่
        child: const Icon(Icons.add),
      ),
    );
  }
}