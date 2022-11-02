import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CapturedImages extends StatelessWidget {
  final List<XFile> images;
  const CapturedImages({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "captured-image",
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index){
          return Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(5),
              child: Image.file(File(images[index].path))
          );
        }
      )
    );
  }
}
