import 'package:flutter/widgets.dart';

abstract class ViewModel {
	void onDispose() {
	}
}

class ViewModelStore {
	final Map<String, ViewModel> _viewModels = <String, ViewModel>{};

	T? get<T extends ViewModel>({ String key = "" }) {
		final Type type = T;
		return _viewModels["$key:$type"] as T?;
	}

	void put<T extends ViewModel>(T viewModel, { String key = "" }) {
		final Type type = T;
		_viewModels["$key:$type"] = viewModel;
	}

	void dispose() {
		for (final ViewModel viewModel in _viewModels.values) {
			viewModel.onDispose();
		}
		_viewModels.clear();
	}
}

class ViewModelStoreProvider extends InheritedWidget {
	final ViewModelStore viewModelStore;

	const ViewModelStoreProvider({
		super.key,
		required this.viewModelStore,
		required super.child,
	});

	static ViewModelStoreProvider of(BuildContext context) {
		final ViewModelStoreProvider? scope = context.dependOnInheritedWidgetOfExactType<ViewModelStoreProvider>();
		assert(scope != null, "No ViewModelScope found in context");
		return scope!;
	}

	@override
	bool updateShouldNotify(ViewModelStoreProvider oldWidget) {
		return viewModelStore != oldWidget.viewModelStore;
	}
}

abstract class ViewModelFactory {
	const ViewModelFactory();

	T create<T extends ViewModel>();
}

class ViewModelFactoryProvider extends InheritedWidget {
	final ViewModelFactory viewModelFactory;

	const ViewModelFactoryProvider({
		super.key,
		required this.viewModelFactory,
		required super.child,
	});

	static ViewModelFactoryProvider of(BuildContext context) {
		final ViewModelFactoryProvider? scope = context.dependOnInheritedWidgetOfExactType<ViewModelFactoryProvider>();
		assert(scope != null, "No ViewModelFactoryScope found in context");
		return scope!;
	}

	@override
	bool updateShouldNotify(ViewModelFactoryProvider oldWidget) {
		return viewModelFactory != oldWidget.viewModelFactory;
	}
}

class ViewModelProvider {
	ViewModelStore viewModelStore;
	ViewModelFactory viewModelFactory;

	ViewModelProvider(this.viewModelStore, this.viewModelFactory);

	T get<T extends ViewModel>({ String key = "" }) {
		final T? viewModel = viewModelStore.get<T>(key: key);
		if (viewModel != null) {
			return viewModel;
		}
		// if viewModel is null, create a new one
		final T newViewModel = viewModelFactory.create<T>();
		viewModelStore.put(newViewModel, key: key);
		return newViewModel;
	}
}

extension ViewModelProviderExtension on BuildContext {
	ViewModelProvider get viewModelProvider {
		final ViewModelStoreProvider viewModelStoreProvider = ViewModelStoreProvider.of(this);
		final ViewModelFactoryProvider viewModelFactoryProvider = ViewModelFactoryProvider.of(this);
		return ViewModelProvider(viewModelStoreProvider.viewModelStore, viewModelFactoryProvider.viewModelFactory);
	}
}

class ViewModelScope extends StatefulWidget {
	final Widget Function(BuildContext) builder;

	const ViewModelScope({
		super.key,
		required this.builder,
	});

	@override
	State<ViewModelScope> createState() => ViewModelScopeState();
}

class ViewModelScopeState extends State<ViewModelScope> {
	final ViewModelStore viewModelStore = ViewModelStore();

	@override
	Widget build(BuildContext context) {
		return ViewModelStoreProvider(
			viewModelStore: viewModelStore,
			child: Builder(
				builder: widget.builder
			)
		);
	}

	@override
	void dispose() {
		viewModelStore.dispose();
		super.dispose();
	}
}
