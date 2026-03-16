import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, _) {
        final results = provider.searchResults;

        return Column(
          children: [
            const _ScreenHeader(
              title: 'Discover Your Next Read',
              subtitle:
                  'Search Open Library by title or author and add books to your shelf.',
            ),
            BookSearchBar(
              controller: _controller,
              onSubmitted: provider.searchBooks,
            ),
            if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
            if (provider.searchErrorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  provider.searchErrorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Search for a book to start building your library.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final book = results[index];

                        return BookCard(
                          book: book,
                          trailing: FilledButton(
                            onPressed: () async {
                              final saved = await provider.addBook(book);
                              if (!context.mounted) {
                                return;
                              }

                              final message = saved
                                  ? '${book.title} added to your library.'
                                  : (provider.libraryMessage ??
                                        'Unable to add the book.');
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                            },
                            child: const Text('Add'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEADCCB),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
