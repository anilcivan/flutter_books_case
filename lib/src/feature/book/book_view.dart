import 'package:book_project/src/feature/book/book_favorites.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:book_project/src/feature/book/book_detail_view.dart';
import 'package:book_project/src/feature/book/book_model.dart';

class BookView extends StatefulWidget {
  const BookView({Key? key}) : super(key: key);

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  BookModel? bookModel;
  final TextEditingController _searchController =
      TextEditingController(text: "google");
  int _page = 1;
  int _totalPage = 0;

  @override
  void initState() {
    super.initState();
    getBook(_searchController.text);
  }

  Future<void> onChanged(String value) async {
    setState(() {
      _page = 1;
      _totalPage = 0;
    });
    getBook(value);
  }

  Future<void> getBook(String query) async {
    try {
      final response = await Dio()
          .get("https://api.itbook.store/1.0/search/$query?page=$_page");
      if (response.statusCode == 200) {
        setState(() {
          bookModel = BookModel.fromJson(response.data);
          _totalPage = (int.parse(bookModel?.total ?? "0") / 10).ceil();
        });
      } else {
        setState(() {
          bookModel = null;
        });
      }
    } catch (e) {
      setState(() {
        bookModel = null;
      });
      debugPrint("Ağ hatası: $e");
    }
  }

  void _getNextPage() {
    setState(() {
      if (_page < _totalPage) {
        _page += 1;
      }
    });
    getBook(_searchController.text);
  }

  void _getPreviousPage() {
    setState(() {
      if (_page > 1) {
        _page -= 1;
      }
    });
    getBook(_searchController.text);
  }

  void _onSearchButtonPressed() {
    getBook(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: AppBar(
          backgroundColor: Colors.purple,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    suffixIcon: IconButton(
                      onPressed: _onSearchButtonPressed,
                      icon: const Icon(Icons.search),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all<double>(0),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero), // Boşluğu kaldırır
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.purple), // Arkaplanı saydam yapar
                    // Diğer stil özellikleri buraya eklenebilir
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesView(),
                      ),
                    );
                  },
                  child: Column(
                      children: [Icon(Icons.favorite), Text("Favorites")])),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: bookModel == null
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
                  onPressed: _getPreviousPage,
                  child: const Text("Previous"),
                ),
                Text("${_page.toString()} / ${_totalPage.toString()}"),
                ElevatedButton(
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
