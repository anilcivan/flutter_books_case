import 'package:book_project/src/feature/book/book_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BookDetail extends StatefulWidget {
  final String id;
  const BookDetail({super.key, required this.id});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  BookDetailModel? bookDetailModel;
  @override
  void initState() {
    getBookDetails();
    super.initState();
  }

  Future<void> getBookDetails() async {
    final response = await Dio()
        .get("https://api.itbook.store/1.0/books/${widget.id}");

    if (response.statusCode == 200) {      
      setState(() {
        bookDetailModel = BookDetailModel.fromJson(response.data);
      });
      print(bookDetailModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Detail View", style:  TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigoAccent),
      body: Column(children: [
          Text(bookDetailModel?.title ?? ""),
          Image.network(bookDetailModel?.image ??"", errorBuilder:(context, error, stackTrace) => Text(""),)
        ],)
 
    );
  }
}
