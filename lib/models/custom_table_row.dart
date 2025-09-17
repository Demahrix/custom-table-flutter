import 'package:flutter/material.dart';

class CustomTableRow {

  final LocalKey? key;
  final VoidCallback? onTap;
  final Decoration? decoration;
  final List<Widget> children;

  CustomTableRow({
    this.key,
    this.onTap,
    this.decoration,
    required this.children
  });

}
