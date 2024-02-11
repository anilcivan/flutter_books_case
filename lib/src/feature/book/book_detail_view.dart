import 'package:book_project/src/feature/book/book_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

final unescape = HtmlUnescape();

class BookDetail extends StatefulWidget {
  final String id;
  const BookDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  BookDetailModel? bookDetailModel;
  final LocalStorage storage = LocalStorage('books');
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    getBookDetails();
    super.initState();
  }

  void onFavoritePress() {
    List favorites = storage.getItem("favorites") ?? [];

    _isFavorite = favorites.contains(widget.id);

    if (_isFavorite) {
      favorites = favorites.where((i) => i != widget.id).toList();
    } else {
      favorites.add(widget.id);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    storage.setItem("favorites", favorites);
  }

  Future<void> getBookDetails() async {
    List favorites = await storage.getItem("favorites") ?? [];

    setState(() {
      _isFavorite = favorites.contains(widget.id);
      _isLoading = true;
    });

    final response =
        await Dio().get("https://api.itbook.store/1.0/books/${widget.id}");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        bookDetailModel = BookDetailModel.fromJson(response.data);
      });
    } else {
      setState(() {
        _isLoading = false;
        bookDetailModel = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 0),
            const Text(
              "Book Detail",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: onFavoritePress,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookDetailModel?.title ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        bookDetailModel?.authors ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        bookDetailModel?.price ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        bookDetailModel?.subtitle ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    color: Colors.grey[50],
                  ),
                  child: Image.network(
                    bookDetailModel?.image ?? "",
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(width: 180, height: 210),
                    fit: BoxFit.cover,
                    width: 180,
                  ),
                )
              ],
            ),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            Text(
              unescape.convert(bookDetailModel?.desc ?? ""),
              style: const TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
