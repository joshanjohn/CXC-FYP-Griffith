import 'package:flutter/material.dart';
import 'package:frontend/features/presentation/responsive/narrow_layout.dart';
import 'package:frontend/features/presentation/responsive/wide_layout.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // wide screen
          return WideLayout();
        } else {
          // narrow screen
          return NarrowLayout();
        }
      },
    );
  }
}
