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
}

class _TestViewModel extends ViewModel {}
