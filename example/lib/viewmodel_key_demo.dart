import 'package:flutter/material.dart';

import 'counter.dart';
import 'scope.dart';

class ViewModelKeyDemo extends StatelessWidget {
  const ViewModelKeyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ViewModel Key Demo')),
      body: Scope(
        builder: (_) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Here are multiple counter components in the same scope but with different "label"s.\n\nCounters with the same label have the same ViewModel.\n\nCounters with different labels have different ViewModels'),
            ),
            Counter(label: 'Alpha'),
            Counter(label: 'Beta'),
            Counter(label: 'Alpha'),
          ],
        ),
      )
    );
  }

}