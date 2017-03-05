num max(List<num> numList) {
  if (numList.length == 0) return 0;
  num output = numList[0];
  numList.forEach((num num) {
    if (num > output) {
      output = num;
    }
  });
  return output;
}

String repeat(String str, int times) {
  List<String> list = [];
  if (times <= 0) return str;
  while (times != 0) {
    list.add(str);
    times--;
  }
  return list.join('');
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