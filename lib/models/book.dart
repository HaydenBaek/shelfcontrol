class BookStatus {
  static const String wantToRead = 'want_to_read';
  static const String reading = 'reading';
  static const String finished = 'finished';

  static const List<String> values = [wantToRead, reading, finished];
}

class Book {
  const Book({
    this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.status = BookStatus.wantToRead,
    this.notes = '',
    this.rating = 0,
    this.currentPage = 0,
  });

  final int? id;
  final String title;
  final String author;
  final String coverUrl;
  final String status;
  final String notes;
  final int rating;
  final int currentPage;

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? coverUrl,
    String? status,
    String? notes,
    int? rating,
    int? currentPage,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'status': status,
      'notes': notes,
      'rating': rating,
      'currentPage': currentPage,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      author: (map['author'] as String?) ?? 'Unknown Author',
      coverUrl: (map['coverUrl'] as String?) ?? '',
      status: _parseStatus(map['status'] as String?),
      notes: (map['notes'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      currentPage: (map['currentPage'] as num?)?.toInt() ?? 0,
    );
  }

  factory Book.fromOpenLibrary(Map<String, dynamic> map) {
    final authorNames = map['author_name'];
    final coverId = map['cover_i'];

    return Book(
      title: (map['title'] as String?) ?? 'Untitled',
      author: authorNames is List && authorNames.isNotEmpty
          ? authorNames.first.toString()
          : 'Unknown Author',
      coverUrl: coverId == null
          ? ''
          : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg',
    );
  }

  static String _parseStatus(String? status) {
    if (BookStatus.values.contains(status)) {
      return status!;
    }

    return BookStatus.wantToRead;
  }
}
