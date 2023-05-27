import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// `ViewModel`s are essentially UI State Controllers
///
/// A `ViewModel` lives until the "Scope" of it is disposed
/// which is typically a page or a tab. See [ViewModelScope]
/// Inside a `ViewModelScope`, you can access a `ViewModel` inside a Widget like this
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final CounterViewModel viewModel = context.getViewModel();
/// }
/// ```
///
/// `ViewModel`s allow for UI Widgets to be as simple as possible
/// UI only talks and listens to the `ViewModel`, the rest of
/// the application code is abstracted away.
///
/// ```
///                               ┌─────────┐
///                  ┌───────────►│ Network │
///                  │            └─────────┘
/// ┌────┐     ┌─────┴─────┐      ┌──────────┐
/// │ UI │◄───►│ ViewModel ├─────►│ Database │
/// └────┘     └─────┬─────┘      └──────────┘
///                  │            ┌──────────┐
///                  └───────────►│ MemCache │
///                               └──────────┘
/// ```
/// One can choose to have more abstractions between the `ViewModel`
/// and network, database and memcache like `Repository`, `Service`
/// to simplify the logic inside a `ViewModel` or to hold some state
/// in a larger scope than the ViewModel
abstract class ViewModel {
  void onDispose() {}
}

class ViewModelStore {
  final Map<String, ViewModel> _viewModels = <String, ViewModel>{};

  T? get<T extends ViewModel>({String key = ""}) {
    final Type type = T;
    return _viewModels["$key:$type"] as T?;
  }

  void put<T extends ViewModel>(T viewModel, {String key = ""}) {
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
    final ViewModelStoreProvider? scope =
        context.dependOnInheritedWidgetOfExactType<ViewModelStoreProvider>();
    assert(scope != null, "No ViewModelScope found in context");
    return scope!;
  }

  @override
  bool updateShouldNotify(ViewModelStoreProvider oldWidget) {
    return viewModelStore != oldWidget.viewModelStore;
  }
}

/// Describes how to construct the `ViewModel`s in your app
///
/// Typically there is just one implmenentation of this per application
/// Use the [ViewModelFactoryProvider] to supply the factory
/// down the Widget tree
abstract class ViewModelFactory {
  const ViewModelFactory();

  T create<T extends ViewModel>();
}

/// Supplies the [viewModelFactory] down the Widget tree
///
/// Wrap your `App` component with this widget
/// ```dart
/// void main() {
///   const MyAppViewModelFactory viewModelFactory = MyAppViewModelFactory();
///   runApp(const MyApp(viewModelFactory: viewModelFactory));
/// }
///
/// class MyApp extends StatelessWidget {
///   final ViewModelFactory viewModelFactory;
///   const MyApp({super.key, required this.viewModelFactory});
///
///   // This widget is the root of your application.
///   @override
///   Widget build(BuildContext context) {
///     return ViewModelFactoryProvider(
///       viewModelFactory: viewModelFactory,
///       child: MaterialApp(
///         title: 'Flutter App',
///         theme: ThemeData(
///           primarySwatch: Colors.blue,
///         ),
///         home: const HomePage(title: 'Home Page'),
///       ),
///     );
///   }
/// }
/// ```
class ViewModelFactoryProvider extends StatelessWidget {
  final Widget child;
  final ViewModelFactory viewModelFactory;

  const ViewModelFactoryProvider({
    super.key,
    required this.viewModelFactory,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: viewModelFactory,
      child: child,
    );
  }
}

/// Provides the `ViewModel` present in the scope or creates one
///
/// You can acquire a `ViewModel` using `BuildContext`
/// ```dart
/// ViewModelProvider.of<YourViewModel>(context)();
/// ```
class ViewModelProvider {
  ViewModelStore viewModelStore;
  ViewModelFactory viewModelFactory;

  ViewModelProvider(this.viewModelStore, this.viewModelFactory);

  static T of<T extends ViewModel>(BuildContext context) {
    return context.getViewModel();
  }

  @Deprecated("Use context.getViewModel() instead")
  T get<T extends ViewModel>({String key = ""}) {
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
  @Deprecated("Use context.getViewModel() instead")
  ViewModelProvider get viewModelProvider {
    final vmStore = Provider.of<ViewModelStore>(this);
    final vmFactory = Provider.of<ViewModelFactory>(this);
    return ViewModelProvider(vmStore, vmFactory);
  }

  /// Returns the `ViewModel` present in the scope or creates one
  ///
  /// If the `ViewModel` is already present in the scope then it just returns it
  /// So this method is **safe to call within `StatelssWidget.build()` and StatefulWidget.initState()**
  /// Basically anywhere you have access to `context`
  ///
  /// `ViewModel` in the scope is identified using it's type by default
  /// If you want multiple `ViewModel`s of the same type in a scope, then
  /// you can use the `key` parameter to distinguish the different `ViewModel`s
  /// of the same type
  T getViewModel<T extends ViewModel>({String key = ""}) {
    final vmStore = Provider.of<ViewModelStore>(this, listen: false);
    final vmFactory = Provider.of<ViewModelFactory>(this, listen: false);

    final T? viewModel = vmStore.get<T>(key: key);
    if (viewModel != null) {
      return viewModel;
    }
    // if viewModel is null, create a new one
    final T newViewModel = vmFactory.create<T>();
    vmStore.put(newViewModel, key: key);
    return newViewModel;
  }
}

/// A Wrapper Widget denoting a scope for the `ViewModel`s used inside it
///
/// Typically used inside a  base `Page` Widget like this
/// ```dart
/// abstract class Page extends StatelessWidget {
///   const Page({super.key});
///
///   Widget buildContent(BuildContext context);
///
///   @override
///   Widget build(BuildContext context) {
///     return ViewModelScope(builder: buildContent);
///   }
/// }
/// ```
/// When a `ViewModelScope` is disposed and removed from the UI tree
/// all the `ViewModel`s acquired inside are also disposed
class ViewModelScope extends StatefulWidget {
  final Widget Function(BuildContext) builder;

  const ViewModelScope({
    super.key,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _ViewModelScopeState();
}

class _ViewModelScopeState extends State<ViewModelScope> {
  final ViewModelStore viewModelStore = ViewModelStore();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
        value: viewModelStore, child: Builder(builder: widget.builder));
  }

  @override
  void dispose() {
    viewModelStore.dispose();
    super.dispose();
  }
}
