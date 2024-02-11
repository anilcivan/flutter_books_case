import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:book_project/src/feature/book/book_detail_view.dart';
import 'package:book_project/src/feature/book/book_model.dart';
import 'package:localstorage/localstorage.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final LocalStorage storage = LocalStorage('books');
  BookModel? bookModel;

  int _page = 1;
  int _totalPage = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getBook();
  }

  Future<void> getBook() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List favorites = storage.getItem("favorites") ?? [];
      String query = favorites.join(",");
      final response = await Dio()
          .get("https://api.itbook.store/1.0/search/$query?page=$_page");
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          bookModel = BookModel.fromJson(response.data);
          _totalPage = (int.parse(bookModel?.total ?? "0") / 10).ceil();
        });
      } else {
        setState(() {
          _isLoading = false;
          bookModel = null;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        bookModel = null;
      });
      debugPrint("Ağ hatası: $e");
    }
  }

  void _getNextPage() {
    if (_page < _totalPage) {
      setState(() {
        _page += 1;
      });
      getBook();
    }
  }

  void _getPreviousPage() {
    if (_page > 1) {
      setState(() {
        _page -= 1;
      });
      getBook();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text(
            "Favorilerim",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.separated(
                    itemCount: bookModel!.books.length,
                    itemBuilder: (context, index) {
                      final book = bookModel!.books[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetail(id: book.isbn13),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  book.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(128, 30)),
                  ),
                  onPressed: _getPreviousPage,
                  child: const Text("Previous"),
                ),
                Text("${_page.toString()} / ${_totalPage.toString()}"),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(128, 30)),
                  ),
                  onPressed: _getNextPage,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
