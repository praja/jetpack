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
