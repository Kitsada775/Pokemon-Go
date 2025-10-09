import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/pocketbase_service.dart';
import 'screens/products_list_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Provider ครอบ MaterialApp เพื่อให้ทุกหน้าจอเข้าถึง Service ได้
    return Provider(
      create: (_) => PocketBaseService(),
      child: MaterialApp(
        title: 'Flutter PocketBase CRUD',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        home: const ProductsListScreen(), // กำหนดให้หน้านี้เป็นหน้าแรก
      ),
    );
  }
}