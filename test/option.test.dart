import 'package:test/test.dart';
import '../lib/command.dart' show Command;
import 'package:command/option.dart' show Option, camelcase;

void main() {
  Option option;

  setUp(() {});

  group('flag', () {
    test('option as a flag', () {
      option = new Option('-f, --force', 'run command in force mode');

      expect(option.short, equals('-f'));
      expect(option.long, equals('--force'));
      expect(option.description, equals('run command in force mode'));
      expect(option.required, isFalse);
      expect(option.optional, isFalse);
      expect(option.anti, isFalse);

      expect(option.argv, isEmpty);
      expect(option.value, isFalse);

      option.parseArgv(['-f', 'aaa']);
      expect(option.value, isTrue);

      // duplicate define
      option.parseArgv(['-f', 'aaa', '--force']);
      expect(option.value, isTrue);

      // input a flag witch was not defined, and it should not be contains
      option.parseArgv(['-f', 'aaa', '--aabbcc']);
      expect(option.value, isTrue);
    });

    test('single flag only contain the long field', () {
      option = new Option('--force', 'run command in force mode');

      expect(option.short, isNull);
      expect(option.long, equals('--force'));
      expect(option.description, equals('run command in force mode'));
      expect(option.required, isFalse);
      expect(option.optional, isFalse);
      expect(option.anti, isFalse);

      expect(option.argv, isEmpty);
      expect(option.value, isFalse);
    });
  }, skip: false);

  group('value', () {
    test('option as a value', () {
      option = new Option('-t, --to <dir>', 'ouput dir');

      expect(option.short, equals('-t'));
      expect(option.long, equals('--to'));
      expect(option.description, equals('ouput dir'));
      expect(option.required, isTrue);
      expect(option.optional, isFalse);
      expect(option.anti, isFalse);

      option.parseArgv(['--to', '/home/axetroy']);
      expect(option.key, equals('to'));
      expect(option.value, equals('/home/axetroy'));

      //  empty value
      option.parseArgv(['--to', '']);
      expect(option.value, equals(''));

      // mssing value
      option.parseArgv(['--to']);
      expect(option.value, equals(''));
    });
  }, skip: false);

  group('command function', () {
    test('test camelcase', () {
      String result1 = camelcase('--flag');
      expect(result1, equals('flag'));

      String result2 = camelcase('-f');
      expect(result2, equals('f'));

      String result3 = camelcase('--no-skip');
      expect(result3, equals('noSkip'));

      String result4 = camelcase('--no-skip-command');
      expect(result4, equals('noSkipCommand'));
    });
  }, skip: false);
}