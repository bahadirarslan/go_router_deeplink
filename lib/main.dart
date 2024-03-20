import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'first.dart';
import 'image.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  redirect: (context, state) {
    print(state);
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
    GoRoute(path: '/first', builder: (context, state) => const FirstScreen(), routes: [
      GoRoute(
        path: 'image-capture',
        builder: (context, state) => const ImageDart(),
      ),
    ]),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  context.push("/first");
                },
                child: const Text("First Screen"))
          ],
        ),
      ),
    );
  }
}
