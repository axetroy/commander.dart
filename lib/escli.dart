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
  Map<String, Map> models = new Map();
  Map<String, Commander> children = new Map();
  Commander parent;

  bool haveSetAction = false;

  Map<String, dynamic> $option = new Map();
  Map<String, String> $argv = new Map();

  Commander({String name}) {
    $name = name ?? '';
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

    Commander childCommand = new Commander(name: command);
    childCommand.parent = this;

    childCommand
      ..description(description ?? '')
      ..parseExpectedArgs(commands);

    children[command] = childCommand;
    return childCommand;
  }

  Commander parseExpectedArgs(List<String> args) {
    if (args.length == 0) return this;
    int index = 0;
    args.forEach((arg) {
      Map<String, dynamic> model = new Map();
      model["name"] = "";
      model["required"] = false;
      model["variadic"] = false;
      model["index"] = index;

      switch (arg[0]) {
        case '<':
          model["required"] = true;
          model["name"] = arg.trim().replaceAll(new RegExp(r'^[\s\S]|[\s\S]$'), '');
          break;
        case '[':
          model["name"] = arg.replaceAll(new RegExp(r'^[\s\S]|[\s\S]$'), '');
          break;
      }

      final String name = model["name"];

      if (name.length > 3 && name.substring(name.length - 3, name.length) == '...') {
        model["variadic"] = true;
        model["name"] = name.substring(name.length - 3, name.length);
      }

      if (name.isNotEmpty) {
        models[name] = model;
      }
      index++;
    });
    return this;
  }

  Commander action(void handler(Map argv, Map option)) {
    haveSetAction = true;
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

    /**
     * parse command
     * example:
     * program
     *    ..name('git')
     *    .command('add <repo>')
     *    .action((Map argv, Map options){
     *        print(argv["repo"]);
     *    });
     */
    models.forEach((String name, Map argv) {
      final current = arguments[argv["index"]];
      $argv[name] = current.indexOf('-') == 0 ? '' : current;
    });

    String command = arguments.isNotEmpty ? arguments.removeAt(0) : '';

    Commander childCommand = children[command];

    if (childCommand == null || command == '') {
      // next argument is not empty && not a flag, then:
      // 1. if not defined any command in root Command, then it will trigger the global action
      //    RootCommand.children.length == 0;
      //    argument: 'whatever_command'
      // 2. it will emit the event to fire action if have require value
      //    command: add <dir>
      //    argument: add /home/axetroy
      // 3. if command don't have require value, then it should throw error: invalid command
      //    command: add
      //    argument: add /home/axetroy   # Invalid Command: /home/axetroy
      if (command.isNotEmpty && command.indexOf('-') != 0) {
        Commander root = getRoot();
        // trigger the global action
        if (root.children.isEmpty && root.haveSetAction == true) {
          root.emit(root.$name);
        }
        else if ($argv.keys.length != 0) {
          this.emit($name);
        }
        else {
          stderr.write('\nInvalid Command: $command\n');
          this.help();
        }
      }
      else {
        this.emit($name);
      }
    }
    else {
      childCommand.parseArgv(arguments);
    }
  }

  /**
   * return the root command
   */
  Commander getRoot() {
    Commander current = this;
    Commander root = current;
    while (current.parent != null) {
      current = current.parent;
      root = current;
    }
    return root;
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

  Commands:
${commands.isNotEmpty ? commands : '    can not found a valid command'}

  Options:
${optionsStr}

Run ${$name} <command> --help for get more infomation
''');
  }

}

Commander program = new Commander();