import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.trailing,
    this.onTap,
    this.subtitle,
    this.statusChip,
  });

  final Book book;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? statusChip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 72,
            child: book.coverUrl.isEmpty
                ? Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.menu_book_outlined),
                  )
                : CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
        ),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle ?? book.author,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (statusChip != null) ...[const SizedBox(height: 6), statusChip!],
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
