import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../services/pocketbase_service.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  bool loading = true;
  List<Product> items = [];
  List<Product> filtered = [];
  String? filterStatus;
  String query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final list = await PBService.list();
    setState(() {
      items = list;
      _applyFilters();
      loading = false;
    });
  }

  void _applyFilters() {
    filtered = items.where((p) {
      final okStatus = filterStatus == null || p.status == filterStatus;
      final okQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.price.toString().contains(query);
      return okStatus && okQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final ava = items.where((e) => e.status == 'available').length;
    final unava = total - ava;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสินค้า'),
        centerTitle: true,
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (ok == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  // แผงสรุป
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        _StatCard(title: 'ทั้งหมด', value: '$total'),
                        _StatCard(title: 'พร้อมขาย', value: '$ava', tone: cs.primaryContainer),
                        _StatCard(title: 'ไม่พร้อม', value: '$unava', tone: cs.errorContainer),
                      ],
                    ),
                  ),
                  // ค้นหา
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      onChanged: (v) {
                        setState(() {
                          query = v.trim().toLowerCase();
                          _applyFilters();
                        });
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'ค้นหา (ชื่อ/ราคา)',
                      ),
                    ),
                  ),
                  // กรองสถานะ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          selected: filterStatus == null,
                          label: const Text('ทั้งหมด'),
                          onSelected: (_) => setState(() { filterStatus = null; _applyFilters(); }),
                        ),
                        ChoiceChip(
                          selected: filterStatus == 'available',
                          label: const Text('พร้อมขาย'),
                          onSelected: (_) => setState(() { filterStatus = 'available'; _applyFilters(); }),
                        ),
                        ChoiceChip(
                          selected: filterStatus == 'unavailable',
                          label: const Text('ไม่พร้อมขาย'),
                          onSelected: (_) => setState(() { filterStatus = 'unavailable'; _applyFilters(); }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // รายการ
                  ...filtered.map((p) => _ProductTile(
                        product: p,
                        onEdit: () async {
                          final ok = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)),
                          );
                          if (ok == true) _load();
                        },
                        onDelete: () async {
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('ลบรายการ?'),
                              content: Text('ต้องการลบ "${p.name}" จริงหรือไม่'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
                              ],
                            ),
                          );
                          if (yes == true) {
                            await PBService.remove(p.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ลบสำเร็จ')),
                              );
                            }
                            _load();
                          }
                        },
                      )),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? tone;
  const _StatCard({required this.title, required this.value, this.tone});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = tone ?? cs.surfaceContainerHighest;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProductTile({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final url = product.photoUrl(PBService.baseUrl);
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 46, height: 46,
            child: url == null
                ? Container(
                    color: cs.surfaceContainerHighest,
                    child: const Icon(Icons.inventory_2, size: 24),
                  )
                : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          ),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text('ราคา: ${product.price.toStringAsFixed(2)}'),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: product.status == 'available'
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product.status,
                  style: TextStyle(
                    color: product.status == 'available' ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              )
            ],
          ),
        ),
        trailing: Wrap(spacing: 4, children: [
          IconButton.filledTonal(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton.filledTonal(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            style: IconButton.styleFrom(foregroundColor: Colors.red),
          ),
        ]),
      ),
    );
  }
}
