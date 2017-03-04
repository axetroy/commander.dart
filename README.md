# commander.dart
[![Build Status](https://travis-ci.org/axetroy/commander.dart.svg?branch=master)](https://travis-ci.org/axetroy/commander.dart)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Dart](https://img.shields.io/badge/dart-%3E=1.20.0-blue.svg?style=flat-square)

The complete solution for Dart command-line interfaces, inspired by node [commander](https://github.com/tj/commander.js) witch created by tj.

## Requirement

- dart>=1.20.0

## Supports

- [ ] Windows
- [x] Linux
- [x] MacOS

## Example

```dart
#!/usr/bin/env dart

import 'package:commander/commander.dart' show Commander;

void main(List<String> arguments){
  Commander program = new Commander();
  
  program
    ..name('test')
    ..version('1.2.0')
    ..description('test desc')
    ..usage('<command> [options]')
    .option('-p, --peppers', 'Add peppers')
    .option('-P, --pineapple', 'Add pineapple')
    .option('-b, --bbq-sauce', 'Add bbq sauce')
    .option('-c, --cheese [type]', 'Add the specified type of cheese [marble]');
  
  program.parseArgv(arguments);
  
  print('--peppers: ${program.$option["peppers"]}');
  print('--pineapple: ${program.$option["pineapple"]}');
  print('--bbq-sauce: ${program.$option["bbqSauce"]}');
  print('--cheese: ${program.$option["cheese"]}');
  
  print('enjoy it');
}
```

## Test
```bash
./scripts/test
```

## Contribute

```bash
git clone https://github.com/axetroy/commander.dart.git
cd ./commander.dart
pub get
./scripts/test
```

You can flow [Contribute Guide](https://github.com/axetroy/commander.dart/blob/master/contributing.md)

## License

The [MIT License](https://github.com/axetroy/commander.dart/blob/master/LICENSE)