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

  dynamic value;

  dynamic defaultValue;

  Option(String _flags, String _description, Function fn, dynamic defaultValue) {
    flags = _flags;
    description = _description;
    required = flags.indexOf('<') >= 0;
    optional = flags.indexOf('[') >= 0;
    anti = flags.indexOf('-no-') >= 0;

    List flagsList = flags.split(new RegExp(r'[ ,|]+'));

    if (flagsList.length > 1) {
      short = flagsList.removeAt(0);
    }

    long = flagsList.removeAt(0);
  }

  bool isOption(String arg) {
    print('$arg $short $long');
    return arg == short || arg == long;
  }

  Option set(dynamic _value) {
    value = _value;
    return this;
  }

  /**
   * 把字符串，根据这个option，生成字段
   */
  Map<String, String> parseArgv(List<String> arguments) {
    final Map<String, dynamic> output = new Map();

    arguments
      .where((v) => v == short || v == long)
      ..where((String agv) => new RegExp('^\-\-').hasMatch(agv))
        .forEach((String _long) {
        final String name = _long.replaceAll(new RegExp('^[-]+'), '');
        output[camelcase(name)] = true;
      })
      ..where((String agv) => new RegExp('^\-[^\-]').hasMatch(agv))
        .forEach((String _short) {
        if (_short == short) {
          final String name = long.replaceAll(new RegExp('^[-]+'), '');
          output[camelcase(name)] = true;
        }
      });

    return output;
  }

  Option parseExpectedArgs(List<String> args) {
    if (args.length == 0) return this;
    args.forEach((arg) {
      Map<String, dynamic> argDetails = new Map();
      argDetails["name"] = "";
      argDetails["required"] = false;
      argDetails["variadic"] = false;

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
        argv.add(argDetails);
      }
    });
    return this;
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