import 'package:flutter/material.dart';
import 'package:jetpack/viewmodel.dart';
import 'package:jetpack/livedata.dart';
import './numberwell.dart';

class Counter extends StatelessWidget {
	final String label;
	const Counter({super.key, this.label = ""});

	@override
	Widget build(BuildContext context) {
		CounterViewModel viewModel = context.viewModelProvider.get(key: label);

		return Column(
			children: [
				if(label.isNotEmpty) Text(label),
				LiveDataBuilder<int>(
					liveData: viewModel.counter,
					builder: (_, count) => NumberWell(
						count,
						onTap: viewModel.increment
					)
				)
			],
		);
	}
}

class CounterViewModel extends ViewModel {
	final MutableLiveData<int> _counter = MutableLiveData(0);

	LiveData<int> get counter => _counter;

	void increment() {
		_counter.value++;
	}
}
