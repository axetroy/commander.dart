# commander.dart
[![Build Status](https://travis-ci.org/axetroy/commander.dart.svg?branch=master)](https://travis-ci.org/axetroy/commander.dart)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Dart](https://img.shields.io/badge/dart-%3E=1.20.0-blue.svg?style=flat-square)

The complete solution for Dart command-line interfaces, inspired by node [commander.js](https://github.com/tj/commander.js) which created by tj.

## Why

cause I don't like build the cli app with other exist lib.

those api not graceful enough. so I want build a lib use like commander.js

so, you can move cli tool from Nodejs easier.

remember, This lib in developing. 

even I have write many test case for this. Still can't make sure it work like expect.

use at your risk. any way I am :)

## Requirement

- dart>=1.20.0

## Supports

- [ ] Windows
- [x] Linux
- [x] MacOS

## Example

### Option parsing

```dart
#!/usr/bin/env dart

import 'package:escli/escli.dart' show Commander;

void main(List<String> arguments){
  Commander program = new Commander();
  
  program
    .name('test')
    .version('1.2.0')
    .description('test desc')
    .usage('<command> [options]')
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

###  Specify the argument syntax

```dart
import 'package:escli/escli.dart' show Commander;

void main(List<String> arguments){
  Commander program = new Commander();

  program
    .version('0.0.1')
    .arguments('<cmd> [env]')
    .action((Map argv, Map options) {
    print(argv);
    print(options);
  });

  program.parseArgv(arguments);
}
```

### Git-style sub-commands (Recommend)

```dart
import 'package:escli/escli.dart' show Commander;

void main(List<String> arguments) {
  Commander program = new Commander();

  program
    .version('0.0.1');

  program
    .command('install [name]', 'install one or more packages')
    .action((Map argv, Map options) {

    });

  program
    .command('search [query]', 'search with optional query')
    .action((Map argv, Map options) {

    });
  
  program
    .command('list', 'list packages installed')
    .action((Map argv, Map options) {

    });
}
```

### Automated -h, --help
### Automated -v, --version
### Automated -dev, --development


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