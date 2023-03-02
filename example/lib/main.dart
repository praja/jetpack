import 'package:example/scope.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/jetpack.dart';
import './viewmodelfactory.dart';
import './counter.dart';
import 'multi_scope_demo.dart';

void main() {
	const ExampleViewModelFactory viewModelFactory = ExampleViewModelFactory();
	runApp(const MyApp(viewModelFactory: viewModelFactory));
}

class MyApp extends StatelessWidget {
	final ViewModelFactory viewModelFactory;
	const MyApp({super.key, required this.viewModelFactory});

	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return ViewModelFactoryProvider(
			viewModelFactory: viewModelFactory,
			child: MaterialApp(
				title: 'Flutter Demo',
				theme: ThemeData(
					// This is the theme of your application.
					//
					// Try running your application with "flutter run". You'll see the
					// application has a blue toolbar. Then, without quitting the app, try
					// changing the primarySwatch below to Colors.green and then invoke
					// "hot reload" (press "r" in the console where you ran "flutter run",
					// or simply save your changes to "hot reload" in a Flutter IDE).
					// Notice that the counter didn't reset back to zero; the application
					// is not restarted.
					primarySwatch: Colors.blue,
				),
				home: const HomePage(title: 'Simple Scope Demo'),
			),
		);
	}
}

class HomePage extends StatelessWidget {
	const HomePage({super.key, required this.title});
	final String title;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				// Here we take the value from the MyHomePage object that was created by
				// the App.build method, and use it to set our appbar title.
				title: Text(title),
			),
			body: Center(
				// Center is a layout widget. It takes a single child and positions it
				// in the middle of the parent.
				child: Scope(
					builder: (_) => Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Padding(
								padding: EdgeInsets.all(16),
								child: Text('Here are two counter components in the same scope. They react to clicks on each other because they are talking to the same ViewModel'),
							),
							const Counter(),
							const Counter(),
							ElevatedButton(
									onPressed: () {
										Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MultiScopeDemo()));
									},
									child: const Text('NEXT')
							)
						],
					),
				)
			)
		);
	}
}
