import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jetpack/jetpack.dart';

class Scope extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const Scope({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ViewModelScope(builder: (innerContext) {
      return Padding(
          padding: const EdgeInsets.all(8),
          child: RandomColorContainer(
            child: builder(innerContext),
          ));
    });
  }
}

class RandomColorContainer extends StatefulWidget {
  final Widget? child;

  const RandomColorContainer({super.key, this.child});

  @override
  State<StatefulWidget> createState() {
    return RandomColorContainerState();
  }
}

class RandomColorContainerState extends State<RandomColorContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final RandomColorViewModel viewModel;
  late final Animation<Color?> animation;

  @override
  void initState() {
    super.initState();

    viewModel = context.getViewModel();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    final color = viewModel.color;
    animation = ColorTween(
      begin: color.withOpacity(0.5),
      end: color,
    ).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          color: animation.value,
          padding: const EdgeInsets.all(16),
          child: widget.child,
        ));
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
