import 'package:flutter/widgets.dart';

import 'livedata.dart';

class _Event<T> {
  final T value;
  _Event(this.value);
}

/// An abstraction to communicate events to UI from ViewModel or the likes.
///
/// Depends on `LiveData` internally.
///
/// Most of the events originate in the UI, so wouldn't need communication of
/// the same to the UI layer.
///
/// In the rest of the cases, there will be changes to the "state" of the UI exposed
/// via `LiveData` / `Stream` etc.
///
/// But there are cases where the UI needs to be notified of events after an
/// asynchronous work etc for things like toasts, dialogs etc. These are essentially
/// "ephemeral state" and should be cleared after being handled.
/// Just as described in the [Official Android Guidelines for UI Events](https://developer.android.com/topic/architecture/ui-layer/events#consuming-trigger-updates)
///
/// If you are in doubt of whether to put something inside the state or fire an event,
/// prefer the state.
abstract class EventQueue<T> {
  final List<_Event<T>> _events = <_Event<T>>[];

  final MutableLiveData<_Event<T>?> _mutableNextEvent =
      MutableLiveData<_Event<T>?>(null);

  LiveData<_Event<T>?> get _nextEvent => _mutableNextEvent;

  void _onHandled(_Event<T> event) {
    _events.remove(event);
    if (_events.isNotEmpty) {
      _mutableNextEvent.value = _events.first;
    } else {
      _mutableNextEvent.value = null;
    }
  }

  void _push(T value) {
    final event = _Event<T>(value);
    _events.add(event);
    if (_mutableNextEvent.value == null && _events.isNotEmpty) {
      _mutableNextEvent.value = _events.first;
    }
  }
}

class MutableEventQueue<T> extends EventQueue<T> {
  void push(T value) {
    _push(value);
  }
}

class EventListener<T> extends StatelessWidget {
  final EventQueue<T> eventQueue;
  final Future<void> Function(BuildContext, T) onEvent;
  final Widget child;

  const EventListener({
    super.key,
    required this.eventQueue,
    required this.onEvent,
    required this.child,
  });

  void _onChange(BuildContext context, _Event<T>? event) async {
    if (event != null) {
      await onEvent(context, event.value);
      eventQueue._onHandled(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiveDataListener<_Event<T>?>(
      liveData: eventQueue._nextEvent,
      changeListener: (innerContext, event, _) {
        _onChange(innerContext, event);
      },
      child: child,
    );
  }
}
