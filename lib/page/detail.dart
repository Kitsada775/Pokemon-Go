import 'package:flutter/material.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the detail page'),

                    Hero(
            tag: 'hero-image',
            child: ClipOval(
              child: Image.asset(
                'assets/images/download.jpg', // ✅ ต้องตรงกับ pubspec.yaml
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),

          ],
        ),
      ),
    );
  }
}
