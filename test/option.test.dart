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

      Map result1 = option.parseArgv(['-f', 'aaa']);
      expect(result1, containsPair('force', true));

      // duplicate define
      Map result2 = option.parseArgv(['-f', 'aaa', '--force']);
      expect(result2, containsPair('force', true));

      // input a flag witch was not defined, and it should not be contains
      Map result3 = option.parseArgv(['-f', 'aaa', '--aabbcc']);
      expect(result3, containsPair('force', true));
      expect(result3.containsKey('aabbcc'), isFalse);
    });

    test('single flag', () {
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
      option = new Option('-t, --to <div>', 'ouput dir');

      expect(option.short, equals('-t'));
      expect(option.long, equals('--to'));
      expect(option.description, equals('ouput dir'));
      expect(option.required, isTrue);
      expect(option.optional, isFalse);
      expect(option.anti, isFalse);

      Map result1 = option.parseArgv(['--to', '/home/axetroy']);
      expect(result1.containsKey('f'), isFalse);
      expect(result1.keys, hasLength(1));
      expect(result1, containsPair('to', '/home/axetroy'));

//       empty value
      Map result2 = option.parseArgv(['--to', '']);
      expect(result2, containsPair('to', ''));

      // mssing value
      Map result3 = option.parseArgv(['--to']);
      expect(result3, containsPair('to', ''));
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