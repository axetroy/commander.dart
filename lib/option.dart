class Option {
  String flags;
  String long;
  String short;

  String name() => long..replaceAll(new RegExp('--'), '').replaceAll(new RegExp('no-'), '');
  String description;

  bool required = false;
  bool optional = true;
  bool anti = false;

  List<Map> argv = [];

  String key;
  dynamic value = false;

  dynamic defaultValue;

  Option(String _flags, String _description, [Function fn, dynamic defaultValue]) {
    flags = _flags;
    description = _description;
    required = flags.indexOf('<') >= 0;
    optional = flags.indexOf('[') >= 0;
    anti = flags.indexOf('-no-') >= 0;

    if (required || optional) {
      value = '';
    }

    List flagsList = flags.split(new RegExp(r'[ ,|]+'));

    if (flagsList.length > 1) {
      short = flagsList.removeAt(0);
    }

    long = flagsList.removeAt(0);
    key = camelcase(long);
  }

  bool isOption(String arg) {
    return arg == short || arg == long;
  }

  /**
   * 把字符串，根据这个option，生成字段
   */
  Map<String, String> parseArgv(List<String> _arguments) {
    final Map<String, dynamic> output = new Map();
    List<String> arguments = _arguments.toList();
    while (arguments.length != 0) {
      String arv = arguments.removeAt(0);
      if ((arv == short || arv == long) && arv.isNotEmpty) {
        // not just a flag, need to set a value
        if (value is! bool) {
          // if loop to last element, then set the value to empty string
          if (arguments.isEmpty || arguments.last == arv) {
            output[key] = '';
          }
          else {
            output[key] = arguments.removeAt(0);
          }
        }
        // it just a flag, true or false
        else {
          output[key] = true;
        }
      };
    }

/*    arguments
        .where((String v) => v == short || v == long)
        .forEach((arv) {
      // not just a flag, need to set a value
      if (value is! bool) {
        // if loop to last element, then set the value to empty string
        if (index > arguments.length - 1) {
          output[key] = '';
          return;
        };
        final String nextArv = arguments[index + 1];
        output[key] = nextArv;
      }
      // it just a flag, true or false
      else {
        output[key] = true;
      }
      index++;
    });*/
    return output;
  }
}

String camelcase(String flag) {
  return flag.split('-')
      .where((str) => str.isNotEmpty)
      .reduce((str, String word) {
    List<String> wordList = word.split('').toList();
    wordList = wordList.isEmpty ? [''] : wordList;
    return str + wordList.removeAt(0).toUpperCase() + wordList.join('');
  });
}