import 'package:example/scope.dart';
import 'package:flutter/material.dart';

import 'counter.dart';
import 'viewmodel_key_demo.dart';

class MultiScopeDemo extends StatelessWidget {
  const MultiScopeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Multi Scope Demo')),
        body: Column(
          children: [
            const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'Here are multiple counters in different scopes, reacting independently, because they have their own ViewModel in each of their scopes')),
            Center(child: Scope(builder: (_) => const Counter())),
            Center(child: Scope(builder: (_) => const Counter())),
            const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'Go Back to see the counter state of the previous page still intact. \n\nAnd come back to this page by clicking NEXT to see the counter state lost. Scope gets disposed when it is removed from the stack')),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ViewModelKeyDemo()));
                },
                child: const Text('NEXT'))
          ],
        ));
  }
}
