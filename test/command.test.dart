// Copyright (c) 2017, axetroy. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:command/command.dart' show Command;
import 'package:test/test.dart';

void main(List<String> arguments) {
  test('calculate', () {
    var program = new Command();

    program
      ..name('gpmx')
      ..description('Git Package Manager, make you manage the repository easier, Power by Dart')
      ..usage('<command> [options]');

    program
      ..command('add <from> [to]')
          .option('-f, --force', 'force run this command')
          .action((Map a) {
        print('run command add $a');
      });

    program.help();

    program.parseArgv(arguments);
  });
}
