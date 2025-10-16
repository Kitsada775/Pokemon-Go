import 'dart:math';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

Future<void> main() async {
  // ถ้าเป็น Android Emulator เปลี่ยนเป็น 'http://10.0.2.2:8090'
  final pb = PocketBase('http://127.0.0.1:8090');
  final f = Faker(); final rnd = Random();

  for (var i = 0; i < 20; i++) {
    final name = f.food.cuisine();
    final price = double.parse(((rnd.nextDouble() * 500) + 20).toStringAsFixed(2));
    final status = rnd.nextBool() ? 'available' : 'unavailable';

    // โหลดรูปสุ่ม
    final img = await http.get(Uri.parse('https://picsum.photos/seed/$i/600/400'));
    final file = http.MultipartFile.fromBytes('photo', img.bodyBytes, filename: 'p$i.jpg');

    await pb.collection('products').create(
      body: {'name': name, 'price': price, 'status': status},
      files: [file],
    );
    print('✓ $name ($status) ฿$price');
  }
  print('Done.');
}
