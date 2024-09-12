## 1.0.7
* Fix: This widget has been unmounted, so the State no longer has a context (and should be considered defunct).

## 1.0.6
* Fix `EventListener` not consuming events emitted in the event queue before widget is in the tree

## 1.0.4
* Updated installation, usage and setup in README

## 1.0.3
### Fixes
* Fix: Avoid `setState` being inside `initState` of `LiveDataBuilder` and `LiveDataListener`

## 1.0.2
### Fixes
* Fix ERROR: Concurrent modification during iteration: _Set if LiveData.removeObserver is called during notify

## 1.0.1
#### Fixes
* Made `context.viewModelProvider.get()` safe to call in `StatefulWidget.initState()` and anywhere you can access `context`
* Removed deprecation for `context.viewModelProvider` as there are valid use cases for it like a GlobalViewModelProvider etc.

## 1.0.0
#### 💫 New
* More optimal `context.getViewModel()` and `ViewModelProvider.of(context)` methods to acquire `ViewModel`
* Acquiring a `ViewModel` is now safe in `StatefulWidget.initState()`

#### ⚠️ Deprecated
* `context.viewModelProvider.get()` - Use `context.getViewModel()` or `ViewModelProvider.of(context)` instead

## 0.1.3
#### 💫 New
`EventListener` and `EventQueue` for communicating events to UI

These events are expected to be used for ephemeral state changes to the UI like showing toasts, dialog etc.

## 0.1.2
#### Fixes
* Diagram formatting in `viewmodel` documentation

## 0.1.1
#### 💫 New
* `example` published to pub.dev

## 0.1.0
#### 🚨 Breaking Changes
* `ViewModelScopeState` -> `_ViewModelScopeState`

#### 💫 New Features
* `LiveDataListener` for performing UI SideEffects on `LiveData` value change

#### Bug fixes
* Fixed `ViewModel`s not being cleared off `ViewModelStore` on `dispose`
	(Might not have mattered in terms of application memory usage, since those objects don't have any reference and would be garbage collected)

## 0.0.1
* Initial Release with `ViewModel` and `LiveData`
