import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:test/test.dart';

class TestModule extends FluentModule {
  TestModule(this.name, this.log);
  final List<String> log;
  final String name;

  @override
  Future<void> onCreate(Registry registry) async {
    log.add('$name:build');
  }

  @override
  Future<void> onStart() async {
    log.add('$name:onStart');
  }

  @override
  Future<void> onStop() async {
    log.add('$name:onStop');
  }
}

void main() {
  tearDown(Fluent.reset);

  test('verify lifecycle order', () async {
    final log = <String>[];
    final moduleA = TestModule('ModuleA', log);
    final moduleB = TestModule('ModuleB', log);

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
