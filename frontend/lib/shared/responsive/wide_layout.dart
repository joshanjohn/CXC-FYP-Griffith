import 'package:flutter/material.dart';
import 'package:frontend/features/prediction/view/widgets/image_uploader.dart';

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

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
