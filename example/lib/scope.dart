import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jetpack/jetpack.dart';

class Scope extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const Scope({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ViewModelScope(builder: (innerContext) {
      final RandomColorViewModel viewModel =
          innerContext.viewModelProvider.get();
      return Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            color: viewModel.color,
            padding: const EdgeInsets.all(16),
            child: builder(innerContext),
          ));
    });
  }
}

Color _generateRandomLightColor() {
  return Color.fromARGB(
    255,
    180 + Random().nextInt(55),
    180 + Random().nextInt(55),
    180 + Random().nextInt(55),
  );
}

class RandomColorViewModel extends ViewModel {
  final Color color = _generateRandomLightColor();
}
