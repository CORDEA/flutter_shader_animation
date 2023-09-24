import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final fragmentShaderProvider =
    FutureProvider((ref) => ui.FragmentProgram.fromAsset('assets/shader.frag'));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _Body(),
    );
  }
}

class _Body extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shader = ref.watch(fragmentShaderProvider);
    final Widget child;
    if (shader.hasValue) {
      child = CustomPaint(
        painter: _Painter(shader.requireValue.fragmentShader()),
        child: const AspectRatio(aspectRatio: 1),
      );
    } else {
      child = const CircularProgressIndicator();
    }
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: child),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter(this.shader);

  final ui.FragmentShader shader;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (size.isEmpty) {
      return;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
