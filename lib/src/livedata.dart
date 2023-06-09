import 'package:flutter/widgets.dart';

/// Observable state holder that allows for imperatively setting and reading the state value
///
/// You'd use this inside a `ViewModel` to expose state for the UI to observe/listen like this
/// ```dart
/// class CounterViewModel extends ViewModel {
///   final MutableLiveData<int> _counter = MutableLiveData(0);
///
///   LiveData<int> get counter => _counter;
///
///   void increment() {
///     _counter.value++;
///   }
/// }
/// ```
///
/// @see also [LiveDataBuilder] and [LiveDataListener]
abstract class LiveData<T> {
  T _currentValue;
  LiveData(this._currentValue);

  T get value => _currentValue;

  final Set<LiveDataObserver<T>> _observers = {};

  void observe(LiveDataObserver<T> observer) {
    _observers.add(observer);
    observer(_currentValue);
  }

  void removeObserver(LiveDataObserver<T> observer) {
    _observers.remove(observer);
  }

  void _updateValue(T value) {
    final oldValue = _currentValue;
    _currentValue = value;

    if (_currentValue != oldValue) {
      _notifyObservers();
    }
  }

  void _notifyObservers() {
    // copying to allow for observers to call `removeObserver` during iteration
    final observersToNotify = Set.of(_observers);
    for (final LiveDataObserver<T> observer in observersToNotify) {
      observer(_currentValue);
    }
  }
}

typedef LiveDataObserver<T> = void Function(T);

/// An Updateable LiveData as the name suggests
///
/// This is defined separately from `LiveData` to avoid
/// access to consumers of the `LiveData`(UI) to modify the state directly
/// You'd expose a `LiveData<T>` publicly from a `ViewModel` while backing
/// it using a private `MutableLiveData<T>` like this
/// ```dart
/// class CounterViewModel extends ViewModel {
///   final MutableLiveData<int> _counter = MutableLiveData(0);
///
///   LiveData<int> get counter => _counter;
///
///   void increment() {
///     _counter.value++;
///   }
/// }
/// ```
class MutableLiveData<T> extends LiveData<T> {
  // @param initialValue: The initial value of the LiveData.
  MutableLiveData(super._currentValue);

  set value(T value) {
    _updateValue(value);
  }
}

/// A Widget that observes a `LiveData` and rebuilds on change
///
/// ```dart
/// LiveDataBuilder<int>(
///   liveData: viewModel.counter,
///   builder: (BuildContext buildContext, int count) =>
///     Text('$count'),
///   )
/// )
/// ```
/// See also [LiveDataListener] for performing UI Side Effects on livedata change
class LiveDataBuilder<T> extends StatefulWidget {
  final LiveData<T> liveData;
  final Widget Function(BuildContext, T) builder;
  const LiveDataBuilder({
    super.key,
    required this.liveData,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _LiveDataBuilderState<T>();
}

class _LiveDataBuilderState<T> extends State<LiveDataBuilder<T>> {
  late final LiveDataObserver<T> _observer;
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _observer = (T value) {
      setState(() {
        _currentValue = value;
      });
    };
    widget.liveData.observe(_observer);
  }

  @override
  void dispose() {
    widget.liveData.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}

/// A LiveData observer that invokes a change listener on [LiveData] change
///
/// While [LiveDataBuilder] is for updating a UI based on the [LiveData]
/// [LiveDataListener] allows to listen to a [LiveData] and perform a Side Effect
/// See [Side Effects in Flutter](https://codewithandrea.com/articles/side-effects-flutter/)
class LiveDataListener<T> extends StatefulWidget {
  final Widget child;
  final LiveData<T> liveData;
  final LiveDataChangeListener<T> changeListener;

  const LiveDataListener({
    super.key,
    required this.liveData,
    required this.child,
    required this.changeListener,
  });

  @override
  State<StatefulWidget> createState() {
    return _LiveDataListenerState<T>();
  }
}

typedef LiveDataChangeListener<T> = Function(BuildContext, T, T?);

class _LiveDataListenerState<T> extends State<LiveDataListener<T>> {
  late final LiveDataObserver<T> _observer;
  T? _previousValue;

  @override
  void initState() {
    super.initState();
    _observer = _onChanged;
    _previousValue = widget.liveData.value;
    _startObserving(widget.liveData);
  }

  @override
  void didUpdateWidget(covariant LiveDataListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveData != widget.liveData) {
      _stopObserving(oldWidget.liveData);
      _previousValue = widget.liveData.value;
      _startObserving(widget.liveData);
    }
  }

  @override
  void dispose() {
    _stopObserving(widget.liveData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _startObserving(LiveData<T> liveData) {
    liveData.observe(_observer);
  }

  void _onChanged(T value) {
    widget.changeListener(context, value, _previousValue);
    _previousValue = value;
  }

  void _stopObserving(LiveData<T> liveData) {
    liveData.removeObserver(_observer);
  }
}
