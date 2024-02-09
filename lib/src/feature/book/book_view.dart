import 'package:book_project/src/feature/book/book_detail_view.dart';
import 'package:book_project/src/feature/book/book_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BookView extends StatefulWidget {
  const BookView({super.key});

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  BookModel? bookModel;

  @override
  void initState() {
    getBook();
    super.initState();
  }

  Future<void> getBook() async {
    final response = await Dio().get(
        "https://www.googleapis.com/books/v1/volumes?q=Tolkien&maxResults=20&startIndex=20&orderBy=relevance");

    if (response.statusCode == 200) {
      setState(() {
         bookModel = BookModel.fromJson(response.data);
      });
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "Book List",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: ListView.separated(
        itemCount: bookModel?.items.length ?? 0,
        itemBuilder: (context, index){
        return InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> BookDetail(id: bookModel?.items[index].id ?? "")));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(bookModel?.items[index].volumeInfo.title ?? "", overflow: TextOverflow.ellipsis,)),
                const Icon(Icons.chevron_right)
              ],
            ),
          ),
        );
      }, separatorBuilder: (BuildContext context, int index) { return const Divider(); },),
    );
  }
}
