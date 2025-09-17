import 'package:flutter/material.dart';
import '../models/custom_table_row.dart';
import '../utils/utils.dart';


typedef CustomTableDividersOptions = ({ Divider? horizontal, VerticalDivider? vertical, bool? hideHeaderHorizontalDivider });

class CustomTable extends StatelessWidget {

  final CustomTableRow? header;
  final Map<int, double>? columnWidths;
  final CustomTableDividersOptions? dividers;
  final List<CustomTableRow> children;

  const CustomTable({
    super.key,
    this.header,
    this.columnWidths,
    this.dividers,
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    var hasHeader = header != null;
    var rowsCount = children.length + (hasHeader ? 1 : 0);

    return Container(
      child: Column(
        children: Utils.separatedListBuilder(
          rowsCount,
          builder: (rowIndex) {
            var row = rowIndex == 0
              ? hasHeader ? header! : children[rowIndex]
              : children[rowIndex - (hasHeader ? 1 : 0)];

            var rowChildren = row.children;

            return InkWell(
              onTap: row.onTap,
              mouseCursor: row.onTap == null ? null : SystemMouseCursors.click,
              child: Container(
                decoration: row.decoration,
                child: Row(
                  children: Utils.separatedListBuilder(
                    rowChildren.length,
                    builder: (columnIndex) {
                      var child = rowChildren[columnIndex];
                      var columnWidth = columnWidths == null ? null : columnWidths![columnIndex];
              
                      if (columnWidth != null)
                        return SizedBox(width: columnWidth, child: child);
                      return Expanded(child: child);
                    },
                    separatedBuilder: (_) => dividers?.vertical ?? const SizedBox()
                  ),
                ),
              ),
            );
          },
          separatedBuilder: (rowIndex) => dividers?.hideHeaderHorizontalDivider == true && hasHeader && rowIndex == 0
            ? const SizedBox()
            : dividers?.horizontal ?? const SizedBox()
        )
      ),
    );
  }

}
