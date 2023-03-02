import 'package:flutter/widgets.dart';

abstract class LiveData<T> {
	T _currentValue;
	LiveData(this._currentValue);

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

	T get value => _currentValue;
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
