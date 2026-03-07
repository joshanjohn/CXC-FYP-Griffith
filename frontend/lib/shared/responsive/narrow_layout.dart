import 'package:flutter/material.dart';
import 'package:frontend/features/prediction/widgets/image_uploader.dart';

class NarrowLayout extends StatelessWidget {
  const NarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [Center(child: ImageUploader())]),
      ),
    );
  }
}
