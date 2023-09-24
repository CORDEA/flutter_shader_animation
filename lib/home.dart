import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Home')),
      body: _Body(),
    );
  }
}

class _Body extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        useAnimationController(duration: const Duration(seconds: 3));
    final shader = ref.watch(fragmentShaderProvider);
    final icon = ref.watch(iconProvider);
    final Widget child;
    if (shader.hasValue && icon.hasValue) {
      final animation = useMemoized(
        () => controller.drive(CurveTween(curve: Curves.easeInOut)),
        [controller],
      );
      child = AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return CustomPaint(
            painter: _Painter(
              shader.requireValue.fragmentShader(),
              icon.requireValue,
              animation.value,
            ),
            child: const AspectRatio(aspectRatio: 1),
          );
        },
      );
    } else {
      child = const CircularProgressIndicator();
    }
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          child,
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              controller.value = 0;
              controller.forward();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter(this.shader, this.image, this.progress);

  final ui.FragmentShader shader;
  final ui.Image image;
  final double progress;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (size.isEmpty) {
      return;
    }
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, progress);
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
