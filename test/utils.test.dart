import 'package:test/test.dart';
import 'package:escli/utils.dart';

void main() {
  test('camelcase', () {
    expect(camelcase('abc-def'), equals('abcDef'));
    expect(camelcase('--no-skip'), equals('noSkip'));
    expect(camelcase('--shallow-exclude'), equals('shallowExclude'));
    expect(camelcase('--reference'), equals('reference'));
    expect(camelcase('--recurse-submodules'), equals('recurseSubmodules'));
    expect(camelcase('--no-checkout'), equals('noCheckout'));
  });

  test('repeat', () {
    expect(repeat('---', 0), equals('---'));
    expect(repeat('a', 3), equals('aaa'));
    expect(repeat('abc', 3), equals('abcabcabc'));
    expect(repeat('abc', -1), equals('abc'));
  });

  test('max', () {
    expect(max([2, 6, 10, 1, 3, 4]), equals(10));
    expect(max([-5, -4, -3, -2, -1]), equals(-1));
    expect(max([1, 2, 5, 5, 0, 1, 2, 4, 5]), equals(5));
  });
}