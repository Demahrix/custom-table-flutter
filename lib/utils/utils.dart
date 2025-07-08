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

  static List<int?> getPagination({
    required int currentPage,
    required int totalPages,
    int delta = 1
  }) {

    var pageNumbers = <int>[];
    var left = currentPage - delta;
    var right = currentPage + delta;

    for (var i=0; i<totalPages; ++i) {
      if (i == 0 || i == totalPages - 1 || (i >= left && i <= right))
        pageNumbers.add(i);
    }

    var result = <int?>[];
    int? previous;

    for (var page in pageNumbers) {
      if (previous != null && (page - previous) > 1)
        result.add(null);
      result.add(page);
      previous = page;
    }

    return result;
  }

  static T? nullOr<T>(T? value, T Function(T) fn) {
    if (value == null)
      return null;
    return fn(value);
  }

}
