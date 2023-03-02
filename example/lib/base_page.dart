import 'package:flutter/widgets.dart';
import 'package:jetpack/viewmodel.dart';

abstract class Page extends StatelessWidget {
  const Page({super.key});

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ViewModelScope(builder: buildContent);
  }
}
