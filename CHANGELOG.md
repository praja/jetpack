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
