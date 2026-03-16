import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/book_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ShelfControlApp());
}

class ShelfControlApp extends StatelessWidget {
  const ShelfControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookProvider()..initialize(),
      child: MaterialApp(
        title: 'ShelfControl',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8A5A44),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F1EA),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
