class Option {
  String _flags;
  bool _required;
  bool _optional;
  bool _bool;
  String _long;
  String _short;
  String _description;
  dynamic _defaultValue;

  Option(String flags, String description, Function fn, dynamic defaultValue) {
    _flags = flags;
    _required = ~flags.indexOf('<');
    _optional = ~flags.indexOf('[');
    _bool = !~flags.indexOf('-no-');
    List flagsList = flags.split(new RegExp(r'[ ,|]+'));
    if (flagsList.length > 1 && new RegExp('r^[[<]').hasMatch(flagsList[1])) _short = flagsList.removeAt(0);
    _long = flagsList.removeAt(0);
    _description = description || '';
  }

  String name() {
    return _long
        .replaceAll(new RegExp('--'), '')
        .replaceAll(new RegExp('no-'), '');
  }

  bool isOption(String arg) {
    return arg == _short || arg == _long;
  }

}