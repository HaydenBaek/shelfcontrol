import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class BookProvider extends ChangeNotifier {
  BookProvider({ApiService? apiService, DatabaseService? databaseService})
    : _apiService = apiService ?? const ApiService(),
      _databaseService = databaseService ?? DatabaseService.instance;

  final ApiService _apiService;
  final DatabaseService _databaseService;

  List<Book> _searchResults = [];
  List<Book> _libraryBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get searchResults => _searchResults;
  List<Book> get libraryBooks => _libraryBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalBooks => _libraryBooks.length;
  int get readingCount =>
      _libraryBooks.where((book) => book.status == BookStatus.reading).length;
  int get finishedCount =>
      _libraryBooks.where((book) => book.status == BookStatus.finished).length;
  int get wantToReadCount => _libraryBooks
      .where((book) => book.status == BookStatus.wantToRead)
      .length;

  Future<void> initialize() async {
    await loadLibrary();
  }

  Future<void> loadLibrary() async {
    _setLoading(true);

    try {
      _libraryBooks = await _databaseService.getBooks();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to load your library.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _searchResults = await _apiService.searchBooks(query);
      _errorMessage = null;
    } catch (error) {
      _searchResults = [];
      _errorMessage = 'Search failed. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addBook(Book book) async {
    final duplicate = _libraryBooks.any(
      (savedBook) =>
          savedBook.title.toLowerCase() == book.title.toLowerCase() &&
          savedBook.author.toLowerCase() == book.author.toLowerCase(),
    );

    if (duplicate) {
      _errorMessage = 'This book is already in your library.';
      notifyListeners();
      return false;
    }

    try {
      final savedBook = await _databaseService.insertBook(book);
      _libraryBooks = [
        ..._libraryBooks,
        savedBook,
      ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Failed to save the book.';
      notifyListeners();
      return false;
    }
  }

  Future<void> updateBook(Book updatedBook) async {
    if (updatedBook.id == null) {
      return;
    }

    try {
      await _databaseService.updateBook(updatedBook);
      _libraryBooks =
          _libraryBooks
              .map((book) => book.id == updatedBook.id ? updatedBook : book)
              .toList()
            ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to update the book.';
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _databaseService.deleteBook(id);
      _libraryBooks = _libraryBooks.where((book) => book.id != id).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to delete the book.';
      notifyListeners();
    }
  }

  void clearMessage() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
