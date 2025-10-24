import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetpack/viewmodel.dart';

class TrackingVM extends ViewModel {
  int disposed = 0;
  @override
  void onDispose() => disposed++;
}

class TestViewModelFactory extends ViewModelFactory {
  final Map<Type, ViewModel Function()> _creators;
  final Map<Type, int> createCalls = {};
  TestViewModelFactory(this._creators);

  @override
  T create<T extends ViewModel>() {
    createCalls[T] = (createCalls[T] ?? 0) + 1;
    final fn = _creators[T];
    if (fn == null) throw StateError('No creator for $T');
    return fn() as T;
  }
}

void main() {
  testWidgets('retains same instance across rebuilds', (tester) async {
    final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

    TrackingVM? first;
    TrackingVM? second;
    final tick = ValueNotifier(0);

    Widget app() => ViewModelFactoryProvider(
          viewModelFactory: factory,
          child: ValueListenableBuilder<int>(
            valueListenable: tick,
            builder: (_, __, ___) => ViewModelScope(
              builder: (context) {
                final vm = context.getViewModel<TrackingVM>();
                if (first == null) {
                  first = vm;
                } else {
                  second ??= vm;
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );

    await tester.pumpWidget(app());
    tick.value++;
    await tester.pump();

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(identical(first, second), isTrue);
    expect(factory.createCalls[TrackingVM], 1);
  });

  testWidgets('disposes when scope unmounts', (tester) async {
    final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

    final show = ValueNotifier(true);
    TrackingVM? vm;

    Widget app() => ViewModelFactoryProvider(
          viewModelFactory: factory,
          child: ValueListenableBuilder<bool>(
            valueListenable: show,
            builder: (_, s, __) => s
                ? ViewModelScope(
                    builder: (context) {
                      vm ??= context.getViewModel<TrackingVM>();
                      return const SizedBox.shrink();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        );

    await tester.pumpWidget(app());
    expect(vm, isNotNull);
    expect(vm!.disposed, 0);

    show.value = false;
    await tester.pump();

    expect(vm!.disposed, 1);
  });

  testWidgets('idempotent getViewModel per type/key', (tester) async {
    final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

    TrackingVM? a;
    TrackingVM? b;

    await tester.pumpWidget(
      ViewModelFactoryProvider(
        viewModelFactory: factory,
        child: ViewModelScope(
          builder: (context) {
            a = context.getViewModel<TrackingVM>();
            b = context.getViewModel<TrackingVM>();
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(a, isNotNull);
    expect(identical(a, b), isTrue);
    expect(factory.createCalls[TrackingVM], 1);
  });

  testWidgets('different keys => different instances + both disposed', (
    tester,
  ) async {
    final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

    final show = ValueNotifier(true);
    late TrackingVM vmA;
    late TrackingVM vmB;

    Widget app() => ViewModelFactoryProvider(
          viewModelFactory: factory,
          child: ValueListenableBuilder<bool>(
            valueListenable: show,
            builder: (_, s, __) => s
                ? ViewModelScope(
                    builder: (context) {
                      vmA = context.getViewModel<TrackingVM>(key: 'a');
                      vmB = context.getViewModel<TrackingVM>(key: 'b');
                      return const SizedBox.shrink();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        );

    await tester.pumpWidget(app());
    expect(identical(vmA, vmB), isFalse);
    expect(factory.createCalls[TrackingVM], 2);

    show.value = false;
    await tester.pump();

    expect(vmA.disposed, 1);
    expect(vmB.disposed, 1);
  });

  testWidgets('new instance after scope remount', (tester) async {
    final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

    final show = ValueNotifier(true);
    TrackingVM? first;
    TrackingVM? second;

    Widget app() => ViewModelFactoryProvider(
          viewModelFactory: factory,
          child: ValueListenableBuilder<bool>(
            valueListenable: show,
            builder: (_, s, __) => s
                ? ViewModelScope(
                    builder: (context) {
                      final vm = context.getViewModel<TrackingVM>();
                      if (first == null) {
                        first = vm;
                      } else if (!identical(first, vm)) {
                        second = vm;
                      }
                      return const SizedBox.shrink();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        );

    await tester.pumpWidget(app());
    expect(first, isNotNull);

    show.value = false; // unmount
    await tester.pump();
    expect(first!.disposed, 1);

    show.value = true; // remount
    await tester.pump();

    expect(second, isNotNull);
    expect(identical(first, second), isFalse);
    expect(factory.createCalls[TrackingVM], 2);
  });

  testWidgets('nested scopes: disposing child does not dispose parent', (
    tester,
  ) async {
    final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

    final showChild = ValueNotifier(true);
    late TrackingVM parentVM;
    TrackingVM? childVM;

    Widget app() => ViewModelFactoryProvider(
          viewModelFactory: factory,
          child: ViewModelScope(
            builder: (context) {
              parentVM = context.getViewModel<TrackingVM>();
              return ValueListenableBuilder<bool>(
                valueListenable: showChild,
                builder: (_, s, __) => s
                    ? ViewModelScope(
                        builder: (context) {
                          childVM = context.getViewModel<TrackingVM>();
                          return const SizedBox.shrink();
                        },
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        );

    await tester.pumpWidget(app());
    expect(parentVM.disposed, 0);
    expect(childVM, isNotNull);

    showChild.value = false; // remove inner scope only
    await tester.pump();

    expect(parentVM.disposed, 0);
    expect(childVM!.disposed, 1);
  });

  testWidgets(
    'navigator routes have independent scopes; pop disposes pushed scope only',
    (tester) async {
      final factory = TestViewModelFactory({TrackingVM: () => TrackingVM()});

      const pushKey = Key('push');
      const popKey = Key('pop');
      TrackingVM? vmHome;
      TrackingVM? vmSecond;

      await tester.pumpWidget(
        ViewModelFactoryProvider(
          viewModelFactory: factory,
          child: MaterialApp(
            home: ViewModelScope(
              builder: (context) {
                vmHome ??= context.getViewModel<TrackingVM>();
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      key: pushKey,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) {
                              return ViewModelScope(
                                builder: (ctx) {
                                  vmSecond ??= ctx.getViewModel<TrackingVM>();
                                  return Scaffold(
                                    body: Center(
                                      child: ElevatedButton(
                                        key: popKey,
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: const Text('Pop'),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('Push'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(vmHome, isNotNull);

      await tester.tap(find.byKey(pushKey));
      await tester.pumpAndSettle();

      expect(vmSecond, isNotNull);
      expect(identical(vmHome, vmSecond), isFalse);
      expect(factory.createCalls[TrackingVM], 2);

      await tester.tap(find.byKey(popKey));
      await tester.pumpAndSettle();

      expect(vmSecond!.disposed, 1);
      expect(vmHome!.disposed, 0);
    },
  );
}
