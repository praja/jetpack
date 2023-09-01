import 'package:jetpack/jetpack.dart';
import 'package:test/test.dart';

void main() {
  test('viewModel is retrievable from ViewModelStore until dispose', () {
    ViewModelStore store = ViewModelStore();
    _TestViewModel viewModel = _TestViewModel();

    store.put(viewModel);
    expect(store.get<_TestViewModel>(), equals(viewModel));

    store.dispose();
    expect(store.get<_TestViewModel>(), equals(null));
  });

  test('keyed viewModel is retrievable from ViewModelStore until dispose', () {
    ViewModelStore store = ViewModelStore();
    _TestViewModel viewModel1 = _TestViewModel();
    _TestViewModel viewModel2 = _TestViewModel();

    store.put(viewModel1, key: 'test_key_1');
    store.put(viewModel2, key: 'test_key_2');
    expect(store.get<_TestViewModel>(key: 'test_key_1'), equals(viewModel1));
    expect(store.get<_TestViewModel>(key: 'test_key_2'), equals(viewModel2));

    store.dispose();
    expect(store.get<_TestViewModel>(key: 'test_key_1'), equals(null));
    expect(store.get<_TestViewModel>(key: 'test_key_2'), equals(null));
  });

  test('livedata should invoke observer on observe', () {
    String value = 'test_value';
    LiveData<String> liveData = MutableLiveData(value);
    bool invoked = false;

    liveData.observe((String data) {
      expect(data, equals(value));
      invoked = true;
    });

    expect(invoked, equals(true));
  });

  test('livedata should not invoke observer if emitCurrentValue is false', () {
    String value = 'test_value';
    LiveData<String> liveData = MutableLiveData(value);
    bool invoked = false;

    liveData.observe((String data) {
      invoked = true;
    }, emitCurrentValue: false);

    expect(invoked, equals(false));
  });

  test('liveData observer can be removed on value changed', () {
    MutableLiveData<int> liveData = MutableLiveData(1);
    Function remove = () {};
    observer(int value) {
      if (value == 0) {
        remove();
      }
    }

    remove = () {
      liveData.removeObserver(observer);
    };

    liveData.observe(observer);
    liveData.value = 0;
  });
}

class _TestViewModel extends ViewModel {}
