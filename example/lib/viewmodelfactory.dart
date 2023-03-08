import 'package:example/scope.dart';
import 'package:jetpack/jetpack.dart';
import './counter.dart';

class ExampleViewModelFactory extends ViewModelFactory {
  const ExampleViewModelFactory();

  @override
  T create<T extends ViewModel>() {
    if (T == CounterViewModel) {
      return CounterViewModel() as T;
    } else if (T == RandomColorViewModel) {
      return RandomColorViewModel() as T;
    }
    throw Exception("Unknown ViewModel type");
  }
}
