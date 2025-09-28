import 'dart:io' show SocketException;
import 'dart:math' show min;

import 'package:custom_table/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:untitled_ui_icons/untitled_ui_icons.dart';
import '../models/custom_table_row.dart';
import 'custom_table.dart';
import 'custom_table_cell.dart';


typedef PaginationOptions = ({ bool? hide, Color? selectedColor, BoxDecoration? decoration });

enum CustomPaginationTableState {
  loading, data, error
}

class CustomPaginationTableData<T> {
  CustomPaginationTableState state;
  List<T>? data;
  Object? error;

  CustomPaginationTableData.fromData(List<T> values): state = CustomPaginationTableState.data, data = values;
  CustomPaginationTableData.fromError(Object? e): state = CustomPaginationTableState.error, error = e;
  CustomPaginationTableData.fromLoading(): state = CustomPaginationTableState.loading;

}


class CustomPaginationTable<T> extends StatelessWidget {

  static const ROW_HEIGHT = 41.0;

  final int pageSize;
  final CustomPaginationTableData<T> data;
  /// Commence a 1
  final int? currentPage;
  final int? totalCount;

  final Map<int, double>? columnWidths;
  final CustomTableDividersOptions? dividers;
  final CustomTableRow? header;
  final CustomTableRow Function(BuildContext context, T value, int index) rowBuilder;

  final ValueChanged<int> onPageChanged;
  final VoidCallback onRetry;

  final Widget Function()? loadingWidget;
  final Widget Function()? emptyWidgetBuidler;
  final Widget Function(Object? error)? errorWidgetBuilder;

  final PaginationOptions? paginationOptions;

  const CustomPaginationTable({
    super.key,
    required this.pageSize,
    required this.data,
    this.currentPage,
    this.totalCount,
    this.columnWidths,
    this.dividers,
    this.header,
    required this.rowBuilder,
    required this.onPageChanged,
    required this.onRetry,
    this.loadingWidget,
    this.emptyWidgetBuidler,
    this.errorWidgetBuilder,
    this.paginationOptions
  });

  @override
  Widget build(BuildContext context) {

    var newHeader = header ?? CustomTableRow(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(4.0))
      ),
      children: [
        CustomTableCell(child: Text('')),
      ]
    );

    var values = data.data;

    var tableWidget = switch(data.state) {
      CustomPaginationTableState.loading => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTable(
            header: newHeader,
            children: [],
          ),
          SizedBox(
            height: pageSize * ROW_HEIGHT,
            child: loadingWidget?.call() ?? _loadingWidgetBuilder(),
          )
        ],
      ),

      CustomPaginationTableState.error => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTable(
            key: newHeader.key,
            header: newHeader,
            children: [],
          ),

          SizedBox(
            height: pageSize * ROW_HEIGHT,
            child: errorWidgetBuilder?.call(data.error) ?? _errorWidgetBuilder(data.error),
          )
        ],
      ),

      CustomPaginationTableState.data => CustomTable(
        header: newHeader,
        columnWidths: columnWidths,
        dividers: dividers,
        children: List.generate(values!.length, (index) => rowBuilder(context, values[index], index), growable: false),
      )
    };

    if (paginationOptions?.hide == true)
      return tableWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tableWidget,
        _paginationWidget()
      ],
    );
  }

  Widget _loadingWidgetBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        const SizedBox(width: 16.0),
        Text(
          'Chargement...',
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        )
      ],
    );
  }


  Widget _errorWidgetBuilder(Object? error) {
    var isNetworkError = error is SocketException;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(isNetworkError ? Icons.wifi_off_rounded : Icons.error, color: Colors.red.shade700),
        const SizedBox(width: 16.0),
        Text(
          isNetworkError ? 'Aucune connexion internet, réessayer plus tard' : 'Une erreur s\'est produite',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700
          ),
        )
      ],
    );
  }

  Widget _paginationWidget() {
    var totalPages = totalCount == null || pageSize == 0 ? null : (totalCount! / pageSize).ceil();
    var paginationNumbers = currentPage == null || totalCount == null || totalPages == null
      ? null
      : Utils.getPagination(currentPage: currentPage! - 1, totalPages: totalPages, delta: 1);

    var paginationNumbersCount = paginationNumbers?.length ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10.0
      ),      
      decoration: paginationOptions?.decoration ?? BoxDecoration(
        // color: Colors.grey[200],
        // borderRadius: BorderRadius.all(Radius.circular(4.0)),
        border: Border(top: BorderSide(color: Colors.grey[200]!))
      ),
      child: currentPage == null || totalCount == null || pageSize == 0
        ? null
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500
                ),
                children: [
                  TextSpan(
                    text: 'Affichage de ',
                    style: TextStyle(color: Colors.black54)
                  ),
                  TextSpan(text: '${((currentPage! - 1) * pageSize) + 1}-${min(currentPage! * pageSize, totalCount ?? (2^53 - 1))}'),
                  TextSpan(
                    text: ' sur ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextSpan(text: totalCount!.toString()),
                  TextSpan(
                    text: ' entrées',
                    style: TextStyle(color: Colors.black54)
                  )
                ]
              )),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(paginationNumbersCount + 2, (index) {
                  var isLast = index == paginationNumbersCount + 1;
                  var pageNumber = index == 0 || isLast 
                    ? null
                    : Utils.nullOr(paginationNumbers![index - 1], (e) => e + 1);

                  var isPrevButton = index == 0;

                  return Padding(
                    padding: index == 0 ? EdgeInsets.zero : const EdgeInsets.only(left: 8.0),
                    child: _PaginationButton(
                      selected: pageNumber == currentPage,
                      pageNumber: pageNumber,
                      isNextButton: isLast,
                      isPrevButton: isPrevButton,
                      disabled: (currentPage == 1 && isPrevButton) || (isLast && currentPage == totalPages),
                      paginationOptions: paginationOptions,
                      onTap: () {
                        if (pageNumber != null)
                          onPageChanged(pageNumber);
                        else if (isPrevButton)
                          onPageChanged(currentPage! - 1);
                        else if (isLast)
                          onPageChanged(currentPage! + 1);
                      }
                    ),
                  );
                }, growable: false),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Afficher par page'),
                  const SizedBox(width: 12.0),
                  SizedBox(
                    width: 48.0,
                    height: 32.0,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
                        contentPadding: EdgeInsets.only(left: 2.0)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: currentPage,
                          // padding: EdgeInsets.zero,
                          onChanged: (value) {
                            if (value != null && value != currentPage)
                              onPageChanged(value);
                          },
                          items: List.generate((totalPages ?? 0), (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text((index + 1).toString())
                          ))
                        ),
                      ),
                    ),
                  )
                ],
              )

            ],
          ),
    );
  }

}


/// Gerer le clique et la desactivation des arrows
class _PaginationButton extends StatelessWidget {

  final bool selected;
  final int? pageNumber;
  final bool isNextButton;
  final bool isPrevButton;
  final bool disabled;
  final VoidCallback? onTap;
  final PaginationOptions? paginationOptions;

  const _PaginationButton({
    required this.selected,
    this.pageNumber,
    required this.isNextButton,
    required this.isPrevButton,
    required this.disabled,
    this.onTap,
    this.paginationOptions
  });

  @override
  Widget build(BuildContext context) {
    var selectedColor = paginationOptions?.selectedColor ?? Colors.orange;

    var color = selected
      ? selectedColor
      : disabled ? Colors.black12 : Colors.black87;

    var selectedBackground = selectedColor.withValues(alpha: 0.12);

    return InkWell(
      onTap: selected || disabled || (isNextButton == false && isPrevButton == false && pageNumber == null)
      ? null
      : onTap,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      child: Container(
        height: 28.0,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: selected ? selectedBackground : null,
          border: selected ? null : Border.all(color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(6.0))
        ),
        child: isNextButton
          ? Icon(UntitledUiIcons.chevron_right, size: 14.0, color: color)
          : isPrevButton
              ? Icon(UntitledUiIcons.chevron_left, size: 14.0, color: color)
              : Text(
                  pageNumber?.toString() ?? '...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color
                  ),
                )
      ),
    );
  }

}
