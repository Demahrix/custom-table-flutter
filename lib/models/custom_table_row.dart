import 'package:flutter/material.dart';

class CustomTableRow {

  final Key? key;
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
