import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Book Card'),
      ),
    );
  }
}
