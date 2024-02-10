import 'package:book_project/src/feature/book/book_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';

class BookDetail extends StatefulWidget {
  final String id;
  const BookDetail({super.key, required this.id});
  

  @override
  State<BookDetail> createState() => _BookDetailState();
}


class _BookDetailState extends State<BookDetail> {
  BookDetailModel? bookDetailModel;
  final LocalStorage storage = new LocalStorage('books');

  @override
  void initState() {
    getBookDetails();
    super.initState();
  }

  bool _isFavorite = false;

  void onFavoritePress() {

    List favorites = storage.getItem("favorites") ?? [];

    _isFavorite = favorites.contains(widget.id);

    if(_isFavorite) {
      favorites = favorites.where((i) => i != widget.id).toList();
    } else {
      favorites.add(widget.id);
    }

     setState(() {
      _isFavorite = !_isFavorite;
    });

    storage.setItem("favorites",favorites);
  }

  Future<void> getBookDetails() async {

    List favorites = await storage.getItem("favorites") ?? [];
    print(favorites);
     setState(() {
        _isFavorite = favorites.contains(widget.id);
     });

    final response =
        await Dio().get("https://api.itbook.store/1.0/books/${widget.id}");

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Book Detail View",
                  style: TextStyle(color: Colors.white),
                ),
                InkWell(
                  onTap: onFavoritePress,
                  child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_outline),
                ),
              ],
            ),
            backgroundColor: Colors.indigoAccent),
        body: Column(
          children: [
            Text(bookDetailModel?.title ?? ""),
            Image.network(
              bookDetailModel?.image ?? "",
              errorBuilder: (context, error, stackTrace) => Text(""),
            )
          ],
        ));
  }
}
