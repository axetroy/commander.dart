import 'package:escli/escli.dart' show Commander;
import 'package:escli/option.dart' show Option;
import 'package:test/test.dart';

void main() {
  Commander program;
  String name = 'escli';
  String version = '1.2.0';
  String description = 'escli, a lib to build your cli-app';
  String usage = '<command> [options]';

  setUp(() async {
    program = new Commander();

    program
      ..name(name)
      ..version(version)
      ..description(description)
      ..usage(usage);
  });

  group('basic', () {
    test('test program info', () {
      expect(program.$name, equals(name));
      expect(program.$version, equals(version));
      expect(program.$description, equals(description));
      expect(program.$usage, equals(usage));
      expect(program.children.length, equals(0));

      // should get default options in global command
      List helper = program.options
        .where((Option v) => v.long == '--help')
        .map((Option v) => v.long)
        .toList();
      expect(program.options, hasLength(2));
      expect(helper, hasLength(1));
      expect(helper[0], equals('--help'));
    }, skip: false);

    test('if not define any action, should run global action', () {
      bool hasRunDefaultAction = false;
      program
        .action((argv, option) {
        hasRunDefaultAction = true;
      });

      program.parseArgv(['--cheese', '--pineapple']);

      expect(hasRunDefaultAction, isTrue);
    }, skip: false);

    test('if i run a invalid command', () {
      bool hasRunDefaultAction = false;
      bool hasRunCommandAction = false;
      program
        .action((argv, option) {
        // it won't run this forever, cause
        hasRunDefaultAction = true;
      });

      program
        .command('test_command')
        .action((argv, option) {
        // it won't run this forever, cause
        hasRunCommandAction = true;
      })
        .on('--help', (dynamic data) {
        print('trigger the help');
      });

      program.parseArgv(['invalid_command', '--cheese', '--pineapple', '-dev']);

      expect(hasRunDefaultAction, isFalse);
      expect(hasRunCommandAction, isFalse);
    }, skip: false);
  }, skip: false);


  group('options', () {
    test('add a global options', () {
      expect(program.options, hasLength(2));
      program
        .option('-f, --force', 'force run this command');

      List force = program.options
        .where((Option v) => v.long == '--force')
        .map((Option v) => v.long)
        .toList();
      expect(force[0], equals('--force'));
      expect(program.options, hasLength(3));
    }, skip: false);

    test('add multiple options', () {
      expect(program.options, hasLength(2));
      program
        .option('-p, --peppers', 'Add peppers')
        .option('-P, --pineapple', 'Add pineapple')
        .option('-b, --bbq-sauce', 'Add bbq sauce')
        .option('-c, --cheese [type]', 'Add the specified type of cheese [marble]');

      expect(program.options, hasLength(6));
      program.parseArgv(['--peppers', '--pineapple']);
      expect(program.children, hasLength(0));
      expect(program.$option, containsPair('peppers', true));
      expect(program.$option, containsPair('pineapple', true));
    }, skip: false);

    test('multiple options need set value but some it did not set', () {
      expect(program.options, hasLength(2));
      program
        .option('-p, --peppers', 'Add peppers')
        .option('-P, --pineapple', 'Add pineapple')
        .option('-b, --bbq-sauce', 'Add bbq sauce')
        .option('-c, --cheese [type]', 'Add the specified type of cheese [marble]');
      program.parseArgv(
        ['--cheese', '--pineapple']); // missing value it should be ['--cheese', '[value]', '--pineapple']
      expect(program.$option, containsPair('pineapple', true));
      expect(program.$option, containsPair('cheese', '')); // should can't get any value, it's empty
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
        expect(program.children, hasLength(1));
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
        expect(program.children.keys, hasLength(0));
      });

      program.parseArgv(['~/home', '-a', '-d', '--abc']);
      expect(hasInvokeDefaultAction, isTrue);
    }, skip: false);

    test('add a options handler and it will trigger spead the value', () {
      bool hasTriggerOptionHandler = false;
      program
        .option('-all, --display-all', 'force run this command', ([bool displayAll]) {
        expect(displayAll, true);
        hasTriggerOptionHandler = true;
      })
        .option('-t, --to <target>', 'force run this command', ([String target]) {
        expect(target, equals('/home/axetroy'));
        hasTriggerOptionHandler = true;
      });
      expect(hasTriggerOptionHandler, isFalse);
      program.parseArgv(['-all', '--a', '--bb', '-t', '/home/axetroy']);
      expect(hasTriggerOptionHandler, isTrue);
    }, skip: false);

    test('set multiple defaultValue', () {
      String username;
      String target;
      program..option('-u, --username <name>', 'your user name', (name) {
        username = name;
      }, 'axetroy')..option('-t, --to <target>', 'target dir', (dir) {
        target = dir;
      }, '/home/axetroy');

      // this is all missing value
      program.parseArgv(['-all', '--a', '--bb', '-t']);

      expect(username, equals('axetroy'));
      expect(target, equals('/home/axetroy'));
    }, skip: false);
  }, skip: false);

  group('command', () {
    test('add a global command', () {
      program
        .command('add <target>', 'add a target');

      expect(program.children is Map, equals(true));
      expect(program.children["add"] is Commander, equals(true));
    }, skip: false);

    test('add a command and action', () {
      bool actionHasBeApply = false;
      program
        .command('add <target>', 'add a target')
        .action((Map argv, Map options) {
        actionHasBeApply = true;
        expect(program.children, hasLength(1));
        expect(argv, isMap);
        expect(options, isMap);
        expect(argv["target"], equals('~/home'));
      });

      program.parseArgv(['add', '~/home']);

      expect(actionHasBeApply, isTrue);
    }, skip: false);

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

      expect(program.children, hasLength(2));
      expect(hasInvokeListCommand, isTrue);
      expect(program.children.keys, hasLength(2));
    }, skip: false);

    test('test command alias name', () {
      bool hasInvokeListCommand = false;
      int callTimes = 0;
      program
        .command('list', 'display all item')
        .alias('ls')
        .action((Map argv, Map options) {
        hasInvokeListCommand = true;
        callTimes++;
      });

      expect(callTimes, equals(0));
      // [-d] and [--abc] was not defined in program, it should be ignore
      program.parseArgv(['ls', '-a', '-d', '--abc']);
      expect(callTimes, equals(1));
      program.parseArgv(['ls', '-a', '-d', '--abc']);
      expect(callTimes, equals(2));
      program.parseArgv(['list', '-a', '-d', '--abc']);
      expect(callTimes, equals(3));

      expect(program.children, hasLength(1));
      expect(hasInvokeListCommand, isTrue);
    }, skip: false);
  }, skip: false);
}
