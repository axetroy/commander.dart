library command;

import 'event-emitter.dart' show EventEmitter;
import 'option.dart' show Option;


class SubCommand extends EventEmitter {
  String _alias = '';
  String _command = '';
  List<String> _argument = [];
  Map<String, Map> _argv = new Map();
  String _description = '';
  List _options = [];
  Function _action = (options) => {};

  SubCommand({String command, List<String> arguments, Map argv}) {
    _command = command;
    _argument = arguments;
    _argv = argv;
  }

  description(String description) {
    _description = description;
    return this;
  }

  alias(String alias) {
    _alias = alias;
    return this;
  }

  option(String flags, String description, [Function fn, dynamic defaultValue]) {
    final option = new Option(flags, description, fn, defaultValue);
    _options.add(option);
    return this;
  }

  SubCommand action(Function handler) {
    _action = handler;
    return this;
  }

  run(List<String> arguments) {
    Map options = new Map();
//    int index = 0;
//    arguments.forEach((argv) {
//      // flag
//      if (argv.indexOf('-') == 0) {
//        options[argv.replaceAll(new RegExp(r'-+'), '')] = true;
//      } else {
//
//      }
//      index++;
//    });
//    print(options);
    _action(arguments);
  }

}

class Command extends EventEmitter {
  String _name = '';
  String _description = '';
  String _usage = '';
  List _options = [];
  List<Function> handlers = [];
  Map<String, SubCommand> _commands = new Map();

  Command([dev]) {
    this.option('-V, --version', 'print the current version');
    this.option('-h, --help', 'print the help info about $_name');
  }

  name(String name) {
    _name = name;
    return this;
  }

  description(String description) {
    _description = description;
    return this;
  }

  usage(String usage) {
    _usage = usage;
    return this;
  }

  option(String flags, String description, [Function fn, dynamic defaultValue]) {
    final option = new Option(flags, description, fn, defaultValue);
    _options.add(option);
    return this;
  }

  SubCommand command(String commandRaw) {
    List<String> commands = commandRaw.split(new RegExp(r'\s+')).toList();
    String command = commands.removeAt(0);
    List<String> arguments = commands;

    List<Match> requireMatches = new RegExp(r'\<[^\>]+\>').allMatches(arguments.join(' '));
    List<Match> optionsMatches = new RegExp(r'\[[^\]]+\]').allMatches(arguments.join(' '));

    // combine to List
    List<Match> matches = new List.from(requireMatches)
      ..addAll(optionsMatches);

    Map<String, Map> argv = new Map();

    for (Match m in matches) {
      String match = m.group(0);
      String name = match.replaceAll(new RegExp(r'^(\<|\[)|(\>|\])$'), '');
      Map argvEntity = new Map();
      argvEntity["require"] = new RegExp(r'\<[^\>]+\>').hasMatch(match);
      argv[name] = argvEntity;
    }

    print(argv);

    SubCommand subCommand = new SubCommand(command: command, arguments: arguments, argv: argv);
    _commands[command] = subCommand;
    return subCommand;
  }

  Command action(Function handler) {
    return this;
  }

  void parseArgv(List<String> arguments) {
    arguments = arguments.toList();
    String command = arguments.removeAt(0);
    List<String> options = arguments;

    SubCommand commandEntity = _commands[command];

    if (commandEntity == null) {
      // if not found command, it will run global command
      print('did not found any command');
    }
    else {
      commandEntity.run(options);
    }
  }

  void help() {
    print('''
$_name $_usage

$_description
''');
  }

}