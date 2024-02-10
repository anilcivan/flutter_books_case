import 'package:book_project/src/feature/book/book_favorites.dart';
import 'package:book_project/src/feature/book/book_view.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

void main() {
  new LocalStorage('books');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Book Project',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BookView(),
    );
  }
}
