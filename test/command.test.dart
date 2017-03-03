import '../lib/command.dart' show Command;
import '../lib/option.dart' show Option;
import 'package:test/test.dart';

void main() {
  Command program = new Command();

  setUp(() async {
    program = new Command();

    program
      ..name('test')
      ..description('test desc')
      ..usage('<command> [options]');
  });

  test('test program info', () {
    expect(program.$name, equals('test'));
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
  });

  test('add a global command', () {
    program
      .command('add <target>', 'add a target');

    expect(program.subCommands is Map, equals(true));
    expect(program.subCommands["add"] is Command, equals(true));
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

  test('add a command optoins', () {
    program
      .command('add <target>', 'add a target')
      .option('-a, -all', 'display all you can see')
      .action((Map argv, Map options) {
      expect(argv["target"], equals('~/home'));
      expect(options["all"], equals(true));
    });

    program.parseArgv(['add', '~/home', '-a']);
  });

  test('if input invalid command optoins, it should be ignore', () {
    program
      .command('add <target>', 'add a target')
      .option('-a, -all', 'display all you can see')
      .action((Map argv, Map options) {
      expect(options.keys, hasLength(1));
      expect(options, containsPair('all', true));
    });

    // [-d] and [--abc] was not defined in program, it should be ignore
    program.parseArgv(['add', '~/home', '-a', '-d', '--abc']);
  });
}
