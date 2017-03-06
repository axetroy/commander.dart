import 'package:ee/ee.dart' show EventEmitter;

class Command extends EventEmitter {
  String cmd;
  String command;
  String alias;
  String description;


  bool haveValue = false;

  Map<String, Map<String, dynamic>> models = new Map();

  Map<String, dynamic> config;

  List<String> argument;

  Command(String Command, String Description, [Map<String, dynamic>Config]) {
    command = Command;
    description = Description;
    config = Config ?? new Map();

    List<String> commands = command.split(new RegExp(r'\s+')).map((String v) => v.trim()).toList();
    cmd = commands.removeAt(0);

    // generate the models
    if (commands.length > 0) {
      int index = 1;
      commands.forEach((String argv) {
        Map<String, dynamic> model = new Map();

        String key = argv.replaceAll(new RegExp(r'^[\<\[]|[\>\]]'), '');
        model["name"] = key;
        model["index"] = index;

        if (new RegExp(r'^\[[^\]]+\]$').hasMatch(argv)) {
          model["required"] = false;
          model["optional"] = true;
        }
        else if (new RegExp(r'^\<[^\>]+\>$').hasMatch(argv)) {
          model["required"] = true;
          model["optional"] = false;
        }
        else {
//          throw new Exception('Invalid Command "$key" in "$command"');
          print('Invalid Command "$key" in "$command"');
          return;
        }
        models[key] = model;
        index++;
      });
    }

    haveValue = models.keys.isEmpty ? false : true;
  }

  parse(List<String> $arguments) {
    $arguments = $arguments.toList();

    argument = $arguments.map((String v) => v.trim()).toList();

    int index = 0;
    int lastFlag = null;
    argument.forEach((String argv) {
      // skip the flag
      if (argv.indexOf('-') == 0) {
        lastFlag = index;
        return;
      }
//      else if (lastFlag != null && lastFlag == index - 1) {
//        index++;
//        return;
//      }
      models.forEach((key, Map value) {
        if (index == value["index"]) value["value"] = argv;
      });
      index++;
    });

    models.forEach((String key, dynamic model) {
      if (model["required"] == true && model["value"] == null) {
        throw new Exception('The argument <${key}> is required');
      }
    });
  }

  toMap() {
    Map<String, dynamic> output = new Map();
    models.forEach((String key, dynamic model) {
      output[key] = model["value"];
    });
    return output;
  }

}