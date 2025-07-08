import 'package:flutter/material.dart';


class CustomTableCell extends StatelessWidget {

  final Decoration? decoration;
  final Widget child;

  const CustomTableCell({
    super.key,
    this.decoration,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
     var theme = Theme.of(context);

    return Container(
      decoration: decoration,
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: theme.brightness == Brightness.light ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 13.0
        ),
        child: child
      ),
    );
  }

}
