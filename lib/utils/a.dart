
List<dynamic> getPagination({
  required int currentPage, // 0-based
  required int totalPages,  // aussi 0-based (ex: totalPages = 10 → pages 0..9)
  int delta = 1,
}) {
  final List<int> pageNumbers = [];

  int left = currentPage - delta;
  int right = currentPage + delta;

  for (int i = 0; i < totalPages; i++) {
    if (i == 0 || i == totalPages - 1 || (i >= left && i <= right)) {
      pageNumbers.add(i);
    }
  }

  List<dynamic> result = [];
  int? previous;

  for (var page in pageNumbers) {
    if (previous != null && page - previous > 1) {
      result.add('...');
    }
    result.add(page);
    previous = page;
  }

  return result;
}

void main(List<String> args) {
  print(getPagination(currentPage: 20, totalPages: 21));
}