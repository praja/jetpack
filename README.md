# Jetpack for Flutter
A set of abstractions, utilities inspired from Android Jetpack 🚀 to help manage state in flutter applications.

## Features
### `LiveData`
State holder and change notifier, that also allows to read current value.

If you are fully onto `Stream`s and reactive programming, you might not need this. But if you want to write imperative code to update state, this should help.

### `ViewModel`
Business logic container that exposes state, event methods to the UI and communicates with the rest of the application

## Usage

Create your `ViewModel` and expose state using `LiveData`
```dart
import 'package:jetpack/jetpack.dart';

class CounterViewModel extends ViewModel {
	final MutableLiveData<int> _counter = MutableLiveData(0);

	LiveData<int> get counter => _counter;

	void increment() {
		_counter.value++;
	}
}
```

You can access your `CounterViewModel` anywhere using `BuildContext` as described below

```dart
@override
Widget build(BuildContext context) {
	final CounterViewModel viewModel = context.viewModelProvider.get();
}
```

And you can consume `LiveData` using `LiveDataBuilder`
```dart
LiveDataBuilder<int>(
	liveData: viewModel.counter,
	builder: (BuildContext buildContext, int count) =>
		Text('$count'),
	)
)
```

And you can pass UI events to `ViewModel` by just invoking the method on it
```dart
FloatingActionButton(
	onPressed: viewModel.increment,
	//...
)
```

## Getting started
This library is not yet published. Until then, consider copying the [`viewmodel.dart`](./lib/livedata.dart) and [`livedata.dart`](./lib/livedata.dart)

<details open>
<summary>Create a <code>ViewModelFactory</code> for your app</summary>

```dart
class MyAppViewModelFactory extends ViewModelFactory {
	const MyAppViewModelFactory();
	
	@override
	T create<T extends ViewModel>() {
		if (T == HomeViewModel) {
			return HomeViewModel() as T;
		}
		throw Exception("Unknown ViewModel type");
	}
}
```

</details>

TBA: Add instructions for the users of dependency frameworks like [`get_it`](https://pub.dev/packages/get_it)

<details open>
<summary>Provide your <code>ViewModelFactory</code> at the root of your App</summary>

```dart
void main() {
	const MyAppViewModelFactory viewModelFactory = MyAppViewModelFactory();
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
				title: 'Flutter App',
				theme: ThemeData(
					primarySwatch: Colors.blue,
				),
				home: const HomePage(title: 'Home Page'),
			),
		);
	}
}
```

</details>

<details open>
<summary>Create a base widget <code>Page</code> to wrap all page contents with a `ViewModelScope`</summary>

```dart
abstract class Page extends StatelessWidget {
	const Page({super.key});

	Widget buildContent(BuildContext context);

	@override
	Widget build(BuildContext context) {
		return ViewModelScope(builder: buildContent);
	}
}
```

If you have a base class already for all pages, then wrap the content using `ViewModelScope` as above

</details>

## Why another State Management Library?
These are proven patterns in Android Ecosystem for more than 5 years. They are still intact even after the adoption of a completely new UI framework - Jetpack Compose. These abstractions have been resilient to change because of **low coupling** and **flexibility**.

Existing solutions in flutter like `bloc`, `provider` etc. limit the logic holders to only emit one stream of state by default, and require extra boiler plate to "select" the pieces of states that the UI would want to react to.

```dart
class MyLogicHolder: LogicHolder<StateModel>
```

Sometimes, we want to expose multiple different state streams that are related but change/emit at a different frequency. Exposing them right from the `ViewModel` without any boilerplate overhead of writing Selectors etc. is very convenient without any cost.

```dart
class MyViewModel: ViewModel {
	final MutableLiveData<int> _counter = MutableLiveData(0);
	final MutableLiveData<boolean> _isModified = MutableLiveData(false);

	LiveData<int> get counter => _counter;
	LiveData<int> get isModified => _isModified;

	void increment() {
		_counter.value++;
		_isModified.value = true;
	}
}
```

This allows us to organize and propagate state the way it is consumed in the UI and minimize unnecessary rebuilding of widgets

You can expose state to the UI using `Future`s and `Stream`s as well. Your **choice**.
```dart
class ProductViewModel: ViewModel {
	//

	Future<ProductDetails> productDetails = await fetchProductDetails();
	Stream<bool> isAddedToCart = cartRepository.isAddedToCart(_productId);
}
```
And use `FutureBuilder` and `StreamBuilder` to listen and update the UI.

And there is no need of creating extra models for communicating UI events to `ViewModel`. Just call the methods directly.
```dart
ElevatedButton(
	onPressed: viewModel.increment
	//...
)
```

