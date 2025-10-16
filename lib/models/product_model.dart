class Product {
  final String id;
  final String collectionId;
  final String name;
  final double price;
  final String? photo;   // ชื่อไฟล์ใน PocketBase
  final String status;   // available | unavailable

  Product({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.price,
    this.photo,
    this.status = 'available',
  });

  factory Product.fromRecord(Map<String, dynamic> j) {
    return Product(
      id: j['id'] as String,
      collectionId: (j['collectionId'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      price: (j['price'] as num?)?.toDouble() ?? 0,
      photo: (j['photo'] ?? '') == '' ? null : (j['photo'] as String),
      status: (j['status'] ?? 'available').toString(),
    );
  }

  /// สร้าง URL ของรูปตาม baseUrl
  String? photoUrl(String baseUrl) {
    if (photo == null || photo!.isEmpty || collectionId.isEmpty) return null;
    return '$baseUrl/api/files/$collectionId/$id/$photo';
  }
}
