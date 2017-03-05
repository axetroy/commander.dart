library escli;

import 'dart:io';
import 'package:ee/ee.dart' show EventEmitter;
import 'option.dart' show Option;
import 'package:escli/utils.dart';

class Commander extends EventEmitter {
  String $name = '';
  String $version = '';
  String $description = '';
  String $usage = '';

  List<Option> options = [];
  List<String> argv;
  List<Map> _argv = [];
  Map<String, Commander> children = new Map();
  bool $root = true;
  Commander parent;

  String env = 'product';

  Map<String, dynamic> $option = new Map();
  Map<String, String> $argv = new Map();

  Commander({String name, bool root}) {
    $name = name ?? '';
    $root = root ?? false;
    this.option('-V, --version', 'print the current version', (bool requireVersion) {
      if (requireVersion == true) {
        stdout.write($version);
        exit(88);
      }
    });
    this.option('-h, --help', 'print the help info about ${$name}', (bool requireHelp) {
      if (requireHelp == true) {
        this.help();
        exit(89);
      }
    });
    this.option('-dev, --development', 'dart environment variables', (bool isDev) {
      if (isDev == true) {
        env = 'development';
      }
    });
  }

  name(String name) {
    $name = name;
    return this;
  }

  version(String version) {
    $version = version;
    return this;
  }

  description(String description) {
    $description = description;
    return this;
  }

  usage(String usage) {
    $usage = usage;
    return this;
  }

  option(String flags, String description, [void handler(dynamic data), dynamic defaultValue]) {
    final option = new Option(flags, description, handler, defaultValue);
    options.add(option);
    return this;
  }

  Commander command(String name, [String description, Map<String, dynamic> options]) {
    List<String> commands = name.split(new RegExp(r'\s+')).toList();
    String command = commands.removeAt(0);
    argv = commands;

    Commander subCommand = new Commander(name: command, root: false);

    subCommand
      ..description(description ?? '')
      ..parseExpectedArgs(argv);

    subCommand.parent = this;
    children[command] = subCommand;
    return subCommand;
  }

  Commander parseExpectedArgs(List<String> args) {
    if (args.length == 0) return this;
    int index = 0;
    args.forEach((arg) {
      Map<String, dynamic> argDetails = new Map();
      argDetails["name"] = "";
      argDetails["required"] = false;
      argDetails["variadic"] = false;
      argDetails["index"] = index;

      switch (arg[0]) {
        case '<':
          argDetails["required"] = true;
          argDetails["name"] = arg.trim().replaceAll(new RegExp(r'^[\s\S]|[\s\S]$'), '');
          break;
        case '[':
          argDetails["name"] = arg.replaceAll(new RegExp(r'^[\s\S]|[\s\S]$'), '');
          break;
      }

      final String name = argDetails["name"];

      if (name.length > 3 && name.substring(name.length - 3, name.length) == '...') {
        argDetails["variadic"] = true;
        argDetails["name"] = name.substring(name.length - 3, name.length);
      }

      if (name.isNotEmpty) {
        _argv.add(argDetails);
      }
      index++;
    });
    return this;
  }

  Commander action(void handler(Map argv, Map option)) {
    this.on($name, (dynamic data) => handler($argv, $option));
    return this;
  }

  void parseArgv(List<String> arguments) {
    arguments = arguments.toList();

    $option = new Map();
    $argv = new Map();

    //  parse options and set the value
    options.forEach((Option option) {
      option.parseArgv(arguments);
      // validate the options filed
      // if this options is required, but not set this value, and not found default value. it will throw an error
      if (option.haveSetFlag && option.required && option.value == '') {
        throw new Exception(
          '${option.long} <value> is required field, or you can set it to optional ${option.long} [value]'
        );
      }
      $option[option.key] = option.value;
      option.emit('run_handler', option.value);
    });

    // parse argv and set the value
    _argv.forEach((Map argv) {
      final current = arguments[argv["index"]];
      $argv[argv["name"]] = current.indexOf('-') == 0 ? '' : current;
    });

    String command = arguments.removeAt(0);

    Commander subCommand = children[command];

    if (subCommand == null) {
      // not root command
      if (command.isNotEmpty && command.indexOf('-') != 0 && env == 'development') {
        stderr.write('can\' found $command, please run ${$name} --help to get help infomation');
      } else {
        this.emit($name);
      }
    }
    else {
      subCommand.parseArgv(arguments);
    }
  }

  void help() {
    num maxOptionLength = max(options.map((Option op) => op.flags.length).toList());
    num maxCommandLength = max(children.values.map((Commander command) => command.$name.length).toList());

    String commands = children.values.map((Commander command) {
      String margin = repeat(' ', maxCommandLength - command.$name.length + 4);
      return '    ${command.$name} ${margin} ${command.$description}';
    }).join('\n');

    String optionsStr = options.map((Option op) {
      String margin = repeat(' ', maxOptionLength - op.flags.length + 4);
      return '    ${op.flags} ${margin} ${op.description}';
    }).join('\n');

    stdout.write('''

  Usage: ${$name} ${$usage}

    ${$description}

  commands:
${commands.isNotEmpty ? commands : '    can not found a valid command'}

  options:
${optionsStr}

Print '${$name} <command> --help for get more infomation'
''');
  }

}