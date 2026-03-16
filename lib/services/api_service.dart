import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';

class ApiService {
  const ApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  static const String _baseUrl = 'https://openlibrary.org/search.json';

  Future<List<Book>> searchBooks(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeQueryComponent(trimmedQuery)}',
    );
    final client = _client ?? http.Client();

    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Open Library request failed: ${response.statusCode}');
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final docs = body['docs'];
      if (docs is! List) {
        return [];
      }

      return docs
          .whereType<Map>()
          .map((doc) => Book.fromOpenLibrary(Map<String, dynamic>.from(doc)))
          .where((book) => book.title.isNotEmpty)
          .toList();
    } catch (error) {
      throw Exception('Unable to search books: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
