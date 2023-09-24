import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final fragmentShaderProvider =
    FutureProvider((ref) => ui.FragmentProgram.fromAsset('assets/shader.frag'));

final iconProvider = FutureProvider((ref) async {
  final data = await ui.ImmutableBuffer.fromAsset('assets/icon.png');
  final codec = await ui.instantiateImageCodecFromBuffer(data);
  final info = await codec.getNextFrame();
  return info.image;
});

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
    final icon = ref.watch(iconProvider);
    final Widget child;
    if (shader.hasValue && icon.hasValue) {
      child = CustomPaint(
        painter: _Painter(
          shader.requireValue.fragmentShader(),
          icon.requireValue,
        ),
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
  _Painter(this.shader, this.image);

  final ui.FragmentShader shader;
  final ui.Image image;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (size.isEmpty) {
      return;
    }
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setImageSampler(0, image);
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
