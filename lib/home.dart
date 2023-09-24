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
      child = const Center();
    } else {
      child = const CircularProgressIndicator();
    }
    return Center(child: child);
  }
}
