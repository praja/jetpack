import 'package:flutter/widgets.dart';

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
    for (final LiveDataObserver<T> observer in _observers) {
      observer(_currentValue);
    }
  }
}

typedef LiveDataObserver<T> = void Function(T);

class MutableLiveData<T> extends LiveData<T> {
  // @param initialValue: The initial value of the LiveData.
  MutableLiveData(super._currentValue);

  set value(T value) {
    _updateValue(value);
  }
}

class LiveDataBuilder<T> extends StatefulWidget {
  final LiveData<T> liveData;
  final Widget Function(BuildContext, T) builder;
  const LiveDataBuilder({
    super.key,
    required this.liveData,
    required this.builder,
  });

  @override
  LiveDataBuilderState<T> createState() => LiveDataBuilderState<T>();
}

class LiveDataBuilderState<T> extends State<LiveDataBuilder<T>> {
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
