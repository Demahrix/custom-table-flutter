import 'package:flutter/material.dart' show Widget;

class Utils {

  Utils._();

  static List<Widget> separatedListBuilder(
    int length, {
      required Widget Function(int index) builder,
      required Widget Function(int index) separatedBuilder
    }) => List<Widget>.generate(length == 0 ? 0 : length * 2 - 1, (index) {
      if (index & 1 == 1)
        return separatedBuilder(index ~/ 2);
      return builder(index ~/ 2);
    }, growable: false);

}
