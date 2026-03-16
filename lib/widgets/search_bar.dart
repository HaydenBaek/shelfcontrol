import 'package:flutter/material.dart';

class BookSearchBar extends StatelessWidget {
  const BookSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search by title or author',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () => onSubmitted(controller.text),
            icon: const Icon(Icons.arrow_forward),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
