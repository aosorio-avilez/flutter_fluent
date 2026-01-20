import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:test/test.dart';

class SyncTestModule extends FluentModule {
  SyncTestModule(this.name, this.log);
  final List<String> log;
  final String name;

  @override
  void onCreate(Registry registry) {
    log.add('$name:build');
  }

  @override
  void onStart() {
    log.add('$name:onStart');
  }

  @override
  void onStop() {
    log.add('$name:onStop');
  }
}

void main() {
  tearDown(Fluent.reset);

  test('verify synchronous lifecycle order', () async {
    final log = <String>[];
    final moduleA = SyncTestModule('ModuleA', log);
    final moduleB = SyncTestModule('ModuleB', log);

    await Fluent.build([moduleA, moduleB]);

    expect(log, [
      'ModuleA:build',
      'ModuleB:build',
      'ModuleA:onStart',
      'ModuleB:onStart',
    ]);

    await Fluent.reset();

    expect(log, [
      'ModuleA:build',
      'ModuleB:build',
      'ModuleA:onStart',
      'ModuleB:onStart',
      'ModuleB:onStop', // LIFO
      'ModuleA:onStop',
    ]);
  });
}
