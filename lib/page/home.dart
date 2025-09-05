import 'package:flutter/material.dart';
import 'package:myapp/page/detail.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // 🔁 ไปหน้า Detail เมื่อกดปุ่ม
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Detail(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      // ✅ ใช้ Hero ครอบ CircleAvatar
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Hero(
  tag: 'hero-image',
  child: CircleAvatar(
    radius: 20,
    backgroundImage: AssetImage('assets/images/download.jpg'), 
          ),
        ),
      ),
    );
  }
}
