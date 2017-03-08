# commander.dart
[![Build Status](https://travis-ci.org/axetroy/commander.dart.svg?branch=master)](https://travis-ci.org/axetroy/commander.dart)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Dart](https://img.shields.io/badge/dart-%3E=1.20.0-blue.svg?style=flat-square)

The complete solution for Dart command-line interfaces, inspired by node [commander.js](https://github.com/tj/commander.js) which created by tj.

## Why

cause I don't like build the cli app with other exist lib.

those api are not graceful enough. so I want build a lib use like commander.js

it make you move cli tool from Nodejs easier.

This lib in developing. I can't make sure it work like expect even I have write many test cases.

Enjoy it!

## Requirement

- dart>=1.20.0

## Supports

- [x] Windows
- [x] Linux
- [x] MacOS

## Example

### Option parsing

```dart
#!/usr/bin/env dart

import 'package:escli/escli.dart' show program;

void main(List<String> arguments){
  program
    ..name('test')
    ..version('1.2.0')
    ..description('test desc')
    ..usage('<command> [options]')
    ..option('-p, --peppers', 'Add peppers')
    ..option('-P, --pineapple', 'Add pineapple')
    ..option('-b, --bbq-sauce', 'Add bbq sauce')
    ..option('-c, --cheese [type]', 'Add the specified type of cheese [marble]');
  
  program.parseArgv(arguments);
  
  print('--peppers: ${program.$option["peppers"]}');
  print('--pineapple: ${program.$option["pineapple"]}');
  print('--bbq-sauce: ${program.$option["bbqSauce"]}');
  print('--cheese: ${program.$option["cheese"]}');
  
  print('enjoy it');
}
```

### Coercion

```dart
import 'package:escli/escli.dart' show program;
void main(List<String> arguments) {
  parseInt(int n){
    print('--interger: $n');
  }
  parseFlow(num n){
    print('--float: $n');
  }
  range(val) {
    print('--float: $val');
  }

  list(val) {
    print('--list: $val');
  }

  collect(val) {
    print('--optional: $val');
  }

  increaseVerbosity(val) {
    print('--verbose: $val');
  }

  program
    ..name('test')
    ..version('1.2.0')
    ..description('test desc')
    ..usage('<command> [options]')
    ..option('-i, --integer <n>', 'An integer argument', parseInt)
    ..option('-f, --float <n>', 'A float argument', parseFlow)
    ..option('-l, --list <items>', 'A list', list)
    ..option('-o, --optional [value]', 'An optional value')
    ..option('-c, --collect [value]', 'A repeatable value', collect)
    ..option('-v, --verbose', 'A value that can be increased', increaseVerbosity, 0)
    ..parseArgv(arguments);
}
```

###  Specify the argument syntax

```dart
import 'package:escli/escli.dart' show program;

void main(List<String> arguments){
  program
    ..version('0.0.1')
    ..command('<cmd> [env]')
    ..action((Map argv, Map options) {
    print(argv);
    print(options);
  });
  program.parseArgv(arguments);
}
```

### Git-style sub-commands (Recommend)

```dart
import 'package:escli/escli.dart' show program;

void main(List<String> arguments) {
  program
    ..version('0.0.1');

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

```
$ gpmx -h

  Usage: gpmx <command> [options]

    Git Package Manager, make you manage the repository easier, Power by Dart

  Commands:
    ls|list              display the all repo.
    ad|add <repo>        clone repo into local dir.
    rm|remove            remove a repo.
    cl|clean             clean the temp/cache.
    rt|runtime           print the program runtime, useful for submit a issue.
    rl|relink            relink the base dir which contain repositories if you delete repository manually.
    ip|import <dir>      register a repository to GPM.

  Options:
    -V, --version      print the current version
    -h, --help         print the help info about 

```

### Automated -V, --version

```
$ gpmx --version
0.0.1
```

### Complete Demo

[https://github.com/gpmer/gpm.dart](https://github.com/gpmer/gpm.dart)

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