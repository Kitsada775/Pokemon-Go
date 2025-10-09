import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import '../services/pocketbase_service.dart';

class ProductFormScreen extends StatefulWidget {
  final RecordModel? product; // รับข้อมูลสินค้ามา (ถ้าเป็นการแก้ไข)

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ถ้ามีข้อมูล product แสดงว่าเป็นโหมดแก้ไข ให้ใส่ข้อมูลเดิมลงในฟอร์ม
    _nameController = TextEditingController(text: widget.product?.data['name'] ?? '');
    _priceController = TextEditingController(text: widget.product?.data['price']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูล
  Future<void> _submitForm() async {
    // ตรวจสอบความถูกต้องของข้อมูลในฟอร์ม
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final name = _nameController.text;
      final price = double.tryParse(_priceController.text) ?? 0.0;

      try {
        if (widget.product == null) {
          // ถ้าไม่มีข้อมูลเดิม = โหมดเพิ่ม (CREATE)
          await pbService.createProduct(name, price);
        } else {
          // ถ้ามีข้อมูลเดิม = โหมดแก้ไข (UPDATE)
          await pbService.updateProduct(widget.product!.id, name, price);
        }
        // กลับไปหน้ารายการสินค้าเมื่อสำเร็จ
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกไม่สำเร็จ: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'เพิ่มสินค้าใหม่' : 'แก้ไขสินค้า'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสินค้า',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'กรุณาใส่ชื่อสินค้า' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'ราคา',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณาใส่ราคา';
                  if (double.tryParse(value) == null) return 'กรุณาใส่ตัวเลขที่ถูกต้อง';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submitForm,
                      child: const Text('บันทึก', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}