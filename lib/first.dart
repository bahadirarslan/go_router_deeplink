import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('First Screen'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text("Image Screen"),
            onPressed: () => context.push("/first/image-capture"),
          ),
        ));
  }
}
