import 'package:flutter/material.dart';

class CustomTableRow {

  final LocalKey? key;
  final Decoration? decoration;
  final List<Widget> children;

  CustomTableRow({
    this.key,
    this.decoration,
    required this.children
  });

}
