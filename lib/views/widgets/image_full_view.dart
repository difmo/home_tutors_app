import 'package:flutter/material.dart';

class ImageFullView extends StatelessWidget {
  final String imageurl;
  const ImageFullView({super.key, required this.imageurl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Image.network(imageurl)),
      appBar: AppBar(
        title: const Text('Image View'),
      ),
    );
  }
}
