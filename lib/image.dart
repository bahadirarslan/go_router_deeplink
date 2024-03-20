import 'dart:io';

import 'package:flutter/material.dart';

import 'import_channel.dart';

class ImageDart extends StatefulWidget {
  const ImageDart({super.key});

  @override
  State<ImageDart> createState() => _ImageDartState();
}

class _ImageDartState extends State<ImageDart> {
  final ImportFileChannel _importFileChannel = ImportFileChannel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: _importFileChannel.getMediaStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.file(File(snapshot.data!.first.path)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(child: const Text("Close"), onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst)),
                    ],
                  );
                }
                return const Text('Waiting for file import...');
              },
            )
          ],
        ),
      ),
    );
  }
}
