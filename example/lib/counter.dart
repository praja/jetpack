import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jetpack/eventqueue.dart';
import 'package:jetpack/viewmodel.dart';
import 'package:jetpack/livedata.dart';
import './numberwell.dart';

class Counter extends StatelessWidget {
  final String label;
  final int max;
  const Counter({super.key, this.label = "", this.max = 10});

  Future<void> onEvent(BuildContext context, CounterEvent event) async {
    if (event is MaxReachedEvent) {
      await Fluttertoast.showToast(
          msg: "Max reached!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    CounterViewModel viewModel = context.counterViewModel(max, key: label);

    return Column(
      children: [
        if (label.isNotEmpty) Text(label),
        EventListener(
            eventQueue: viewModel.eventQueue,
            onEvent: onEvent,
            child: LiveDataBuilder<int>(
                liveData: viewModel.counter,
                builder: (_, count) =>
                    NumberWell(count, onTap: viewModel.increment)))
      ],
    );
  }
}

class CounterViewModel extends ViewModel {
  final MutableLiveData<int> _counter = MutableLiveData(0);
  final MutableEventQueue<CounterEvent> _eventQueue = MutableEventQueue();
  late int _max;

  LiveData<int> get counter => _counter;
  EventQueue<CounterEvent> get eventQueue => _eventQueue;

  void increment() {
    if (_counter.value == max) {
      _eventQueue.push(CounterEvent.maxReachedEvent());
      return;
    }
    _counter.value++;
  }

  int get max => _max;

  void _initialize(int max) {
    if (max <= 0) {
      throw UnsupportedError("Max must be greater than 0");
    }
    _max = max;
  }
}

extension on BuildContext {
  CounterViewModel counterViewModel(int max, {String key = ""}) {
    final viewModel = getViewModel<CounterViewModel>(key: key);
    viewModel._initialize(max);
    return viewModel;
  }
}

abstract class CounterEvent {
  factory CounterEvent.maxReachedEvent() = MaxReachedEvent;
}

class MaxReachedEvent implements CounterEvent {
  const MaxReachedEvent();
}
