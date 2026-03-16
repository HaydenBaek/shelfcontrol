import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, _) {
        final books = provider.libraryBooks;

        return books.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Your library is empty. Save a book from the Search tab.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];

                  return BookCard(
                    book: book,
                    subtitle: book.author,
                    statusChip: _StatusChip(status: book.status),
                    onTap: () => _editBook(context, provider, book),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _editBook(context, provider, book);
                          return;
                        }

                        if (book.id != null) {
                          final deleted = await provider.deleteBook(book.id!);
                          if (!context.mounted) {
                            return;
                          }

                          final message = deleted
                              ? '${book.title} removed from your library.'
                              : (provider.libraryMessage ??
                                    'Unable to delete the book.');
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              );
      },
    );
  }

  Future<void> _editBook(
    BuildContext context,
    BookProvider provider,
    Book book,
  ) {
    return _showEditDialog(context, book).then((updatedBook) async {
      if (updatedBook == null) {
        return;
      }

      final updated = await provider.updateBook(updatedBook);
      if (!context.mounted) {
        return;
      }

      final message = updated
          ? '${updatedBook.title} updated.'
          : (provider.libraryMessage ?? 'Unable to update the book.');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<Book?> _showEditDialog(BuildContext context, Book book) {
    return showDialog<Book>(
      context: context,
      builder: (context) {
        return _BookEditDialog(book: book, statusLabel: _statusLabel);
      },
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case BookStatus.reading:
        return 'Reading';
      case BookStatus.finished:
        return 'Finished';
      default:
        return 'Want to Read';
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookStatus.reading => ('Reading', const Color(0xFFC38D4D)),
      BookStatus.finished => ('Finished', const Color(0xFF5E7A66)),
      _ => ('Want to Read', const Color(0xFF6A7F9B)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BookEditDialog extends StatefulWidget {
  const _BookEditDialog({required this.book, required this.statusLabel});

  final Book book;
  final String Function(String status) statusLabel;

  @override
  State<_BookEditDialog> createState() => _BookEditDialogState();
}

class _BookEditDialogState extends State<_BookEditDialog> {
  late final TextEditingController _notesController;
  late String _selectedStatus;
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.book.notes);
    _selectedStatus = widget.book.status;
    _selectedRating = widget.book.rating;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Reading status',
                border: OutlineInputBorder(),
              ),
              items: BookStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(widget.statusLabel(status)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Rating', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 4,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedRating = star;
                    });
                  },
                  icon: Icon(
                    star <= _selectedRating ? Icons.star : Icons.star_border,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              widget.book.copyWith(
                status: _selectedStatus,
                notes: _notesController.text.trim(),
                rating: _selectedRating.clamp(0, 5),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
