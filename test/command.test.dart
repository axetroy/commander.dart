import 'package:test/test.dart';
import 'package:escli/command.dart' show Command;

void main() {
  test('basic', () {
    Command cmd = new Command('add <dir>', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, isNotEmpty);

    Map model = cmd.models["dir"];
    expect(model, isNotEmpty);
    expect(model["name"], equals('dir'));
    expect(model["index"], equals(1));
    expect(model["required"], isTrue);
    expect(model["optional"], isFalse);

    expect(model["value"], isNull);
    cmd.parse(['add', '/home/axetroy']);
    expect(model["value"], '/home/axetroy');
  }, skip: true);

  test('multi value', () {
    Command cmd = new Command('add <from> <to>', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, isNotEmpty);

    cmd.parse(['add', '/home/axetroy', '/home/admin']);

    Map fromModel = cmd.models["from"];
    expect(fromModel, isNotEmpty);
    expect(fromModel["name"], equals('from'));
    expect(fromModel["index"], equals(1));
    expect(fromModel["required"], isTrue);
    expect(fromModel["optional"], isFalse);
    expect(fromModel["value"], '/home/axetroy');

    Map toModel = cmd.models["to"];
    expect(toModel, isNotEmpty);
    expect(toModel["name"], equals('to'));
    expect(toModel["index"], equals(2));
    expect(toModel["required"], isTrue);
    expect(toModel["optional"], isFalse);
    expect(toModel["value"], '/home/admin');
  }, skip: true);

  test('command without value', () {
    Command cmd = new Command('add', 'add a dir to contain');

    expect(cmd.haveValue, isFalse);
    expect(cmd.models.keys, isEmpty);

    cmd.parse(['add', '/home/axetroy', '/home/admin']);

    expect(cmd.models, isEmpty);
  }, skip: true);

  test('command without value', () {
    Command cmd = new Command('add [dir]', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, hasLength(1));

    cmd.parse(['add']);

    Map output = cmd.toMap();
    Map dirModel = cmd.models["dir"];
    expect(dirModel, isNotNull);
    expect(dirModel["value"], isNull);
    expect(output["dir"], isNull);
  }, skip: true);

  test('command without value', () {
    Command cmd = new Command('add [dir]', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, hasLength(1));

    cmd.parse(['add', '/home']);

    Map output = cmd.toMap();
    Map dirModel = cmd.models["dir"];
    expect(dirModel, isNotNull);
    expect(output["dir"], "/home");
  }, skip: true);

  test('command with flag', () {
    Command cmd = new Command('add [dir]', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, hasLength(1));

    cmd.parse(['add', '/home', '-f', '-v']);

    Map output = cmd.toMap();
    Map dirModel = cmd.models["dir"];
    expect(dirModel, isNotNull);
    expect(output["dir"], "/home");
  }, skip: true);

  test('command with flag', () {
    Command cmd = new Command('add [dir]', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, hasLength(1));

    cmd.parse(['add', '-f', '/home', '-f', '-v']);

    Map output = cmd.toMap();
    Map dirModel = cmd.models["dir"];
    expect(dirModel, isNotNull);
    expect(output["dir"], "/home");
  }, skip: true);

  test('multi value', () {
    Command cmd = new Command('add <from> <to>', 'add a dir to contain');

    expect(cmd.haveValue, isTrue);
    expect(cmd.models, isNotEmpty);

    cmd.parse(['add', '-f', '/home/axetroy', '-c', '/home/admin']);

    Map fromModel = cmd.models["from"];
    expect(fromModel, isNotEmpty);
    expect(fromModel["name"], equals('from'));
    expect(fromModel["index"], equals(1));
    expect(fromModel["required"], isTrue);
    expect(fromModel["optional"], isFalse);
    expect(fromModel["value"], '/home/axetroy');

    Map toModel = cmd.models["to"];
    expect(toModel, isNotEmpty);
    expect(toModel["name"], equals('to'));
    expect(toModel["index"], equals(2));
    expect(toModel["required"], isTrue);
    expect(toModel["optional"], isFalse);
    expect(toModel["value"], '/home/admin');
  }, skip: true);

  test('command without value but with flag', () {
    Command cmd = new Command('add', 'add a dir to contain');

    expect(cmd.haveValue, isFalse);
    expect(cmd.models, hasLength(0));

    cmd.parse(['add', '-f', '-f', '-v']);

    Map output = cmd.toMap();
    Map dirModel = cmd.models["dir"];
    expect(dirModel, isNull);
    expect(output, isEmpty);
  }, skip: false);
}