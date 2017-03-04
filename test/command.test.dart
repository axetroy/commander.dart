import 'package:commander/commander.dart' show Commander;
import 'package:commander/option.dart' show Option;
import 'package:test/test.dart';

void main() {
  Commander program = new Commander();

  setUp(() async {
    program = new Commander();

    program
      ..name('test')
      ..version('1.2.0')
      ..description('test desc')
      ..usage('<command> [options]');
  });

  group('basic info', () {
    test('test program info', () {
      expect(program.$name, equals('test'));
      expect(program.$version, equals('1.2.0'));
      expect(program.$description, equals('test desc'));
      expect(program.$usage, equals('<command> [options]'));
      expect(program.subCommands.length, equals(0));

      // should get default options in global command
      List helper = program.options
        .where((Option v) => v.long == '--help')
        .map((Option v) => v.long)
        .toList();
      expect(program.options.length, equals(2));
      expect(helper.length, equals(1));
      expect(helper[0], equals('--help'));
    });
  }, skip: false);


  group('test options', () {
    test('add a global options', () {
      expect(program.options.length, equals(2));
      program
        .option('-f, --force', 'force run this command');

      List force = program.options
        .where((Option v) => v.long == '--force')
        .map((Option v) => v.long)
        .toList();
      expect(force[0], equals('--force'));
      expect(program.options.length, equals(3));
    }, skip: false);

    test('add multiple options', () {
      expect(program.options.length, equals(2));
      program
        .option('-p, --peppers', 'Add peppers')
        .option('-P, --pineapple', 'Add pineapple')
        .option('-b, --bbq-sauce', 'Add bbq sauce')
        .option('-c, --cheese [type]', 'Add the specified type of cheese [marble]');

      expect(program.options, hasLength(6));
      program.parseArgv(['--peppers', '--pineapple']);
      expect(program.subCommands, hasLength(0));
      expect(program.$option, containsPair('peppers', true));
      expect(program.$option, containsPair('pineapple', true));
    }, skip: false);

    test('multiple options need set value but some it did not set', () {
      expect(program.options.length, equals(2));
      program
        .option('-p, --peppers', 'Add peppers')
        .option('-P, --pineapple', 'Add pineapple')
        .option('-b, --bbq-sauce', 'Add bbq sauce')
        .option('-c, --cheese [type]', 'Add the specified type of cheese [marble]');
      program.parseArgv(['--cheese', '--pineapple']);   // missing value it should be ['--cheese', '[value]', '--pineapple']
      expect(program.$option, containsPair('pineapple', true));
      expect(program.$option, containsPair('cheese', ''));    // should can't get any value, it's empty
    }, skip: false);

    test('add a command optoins', () {
      program
        .command('add <target>', 'add a target')
        .option('-a, -all', 'display all you can see')
        .action((Map argv, Map options) {
        expect(argv["target"], equals('~/home'));
        expect(options["all"], equals(true));
      });

      program.parseArgv(['add', '~/home', '-a']);
    }, skip: false);

    test('if input invalid command optoins, it should be ignore', () {
      program
        .command('add <target>', 'add a target')
        .option('-a, -all', 'display all you can see')
        .action((Map argv, Map options) {
        expect(options.keys, hasLength(3));
        expect(program.subCommands, hasLength(1));
        expect(options, containsPair('all', true));
      });

      // [-d] and [--abc] was not defined in program, it should be ignore
      program.parseArgv(['add', '~/home', '-a', '-d', '--abc']);
    }, skip: false);

    test('define a cli app without any command, and it will trigger global action', () {
      bool hasInvokeDefaultAction = false;
      program
        .action((Map argv, Map options) {
        hasInvokeDefaultAction = true;
        expect(program.subCommands.keys, hasLength(0));
      });

      // [-d] and [--abc] was not defined in program, it should be ignore
      program.parseArgv(['add', '~/home', '-a', '-d', '--abc']);
      expect(hasInvokeDefaultAction, isTrue);
    }, skip: false);
  }, skip: false);

  group('test command', () {
    test('add a global command', () {
      program
        .command('add <target>', 'add a target');

      expect(program.subCommands is Map, equals(true));
      expect(program.subCommands["add"] is Commander, equals(true));
    });

    test('add a global command and action', () {
      bool actionHasBeApply = false;
      program
        .command('add <target>', 'add a target')
        .action((Map argv, Map options) {
        actionHasBeApply = true;
        expect(argv, isMap);
        expect(options, isMap);
        expect(argv["target"], equals('~/home'));
      });

      program.parseArgv(['add', '~/home']);

      expect(actionHasBeApply, equals(true));
    });

    test('define multiple command', () {
      bool hasInvokeListCommand = false;
      program
        .command('add <target>', 'add a target')
        .option('-a, -all', 'display all you can see')
        .action((Map argv, Map options) {
        expect(options.keys, hasLength(1));
        expect(options, containsPair('all', true));
      });

      program
        .command('list', 'display all item')
        .action((Map argv, Map options) {
        hasInvokeListCommand = true;
      });

      // [-d] and [--abc] was not defined in program, it should be ignore
      program.parseArgv(['list', '-a', '-d', '--abc']);

      expect(hasInvokeListCommand, isTrue);
      expect(program.subCommands.keys, hasLength(2));
    });
  }, skip: false);
}
