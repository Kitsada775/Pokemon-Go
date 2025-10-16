import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/pocketbase_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _fkey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  String _status = 'available';
  XFile? _image;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name.text = widget.product!.name;
      _price.text = widget.product!.price.toString();
      _status = widget.product!.status;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => _image = x);
  }

  Future<void> _submit() async {
    if (!_fkey.currentState!.validate()) return;
    final price = double.parse(_price.text.trim());
    if (widget.product == null) {
      await PBService.create(
        name: _name.text.trim(),
        price: price,
        status: _status,
        image: _image,
      );
    } else {
      await PBService.update(
        id: widget.product!.id,
        name: _name.text.trim(),
        price: price,
        status: _status,
        image: _image,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = widget.product?.photoUrl(PBService.baseUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'เพิ่มสินค้า' : 'แก้ไขสินค้า'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _fkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                validator: (v) => v == null || v.trim().isEmpty ? 'กรอกชื่อ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ราคา'),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  final d = double.tryParse(t);
                  if (d == null) return 'กรอกราคาเป็นตัวเลข';
                  if (d < 0) return 'ราคาต้อง ≥ 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('พร้อมขาย')),
                  DropdownMenuItem(value: 'unavailable', child: Text('ไม่พร้อมขาย')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'available'),
                decoration: const InputDecoration(labelText: 'สถานะ'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('เลือกรูป'),
                  ),
                  const SizedBox(width: 12),
                  if (_image != null) Text(_image!.name),
                ],
              ),
              const SizedBox(height: 12),
              if (existingUrl != null && _image == null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(existingUrl, height: 120),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกการเปลี่ยนแปลง'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
