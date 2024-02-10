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
  TextEditingController _searchController =
      TextEditingController(text: "google");
  int _page = 1;
  int _totalPage = 0;

  @override
  void initState() {
    super.initState();
    // Varsayılan arama sorgusu ile kitapları getir
    getBook(_searchController.text);
  }

  Future<void> onChanged(String value) async {
    // Yeni arama sorgusu ile kitapları getir
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

      print("https://api.itbook.store/1.0/search/$query?page=$_page");

      if (response.statusCode == 200) {
        setState(() {
          // Başarılı yanıtı alınca kitap modelini güncelle
          bookModel = BookModel.fromJson(response.data);
          _totalPage = (int.parse(bookModel?.total ?? "0") / 10).ceil();
        });
      } else {
        // Başarısız yanıt durumunda kitap modelini null yap
        setState(() {
          bookModel = null;
        });
      }
    } catch (e) {
      // Hata durumunda kitap modelini null yap
      setState(() {
        bookModel = null;
      });
      print("Ağ hatası: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: AppBar(
          backgroundColor: Colors.purple,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
            onChanged: onChanged,
          ),
        ),
      ),
      body: bookModel == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: bookModel!.books.length + 1,
              itemBuilder: (context, index) {
                if (index == bookModel!.books.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _getPreviousPage,
                          child: Text("Previous"),
                        ),
                        Text(_page.toString() + "/" + _totalPage.toString()),
                        ElevatedButton(
                          onPressed: _getNextPage,
                          child: Text("Next"),
                        ),
                      ],
                    ),
                  );
                } else {
                  final book = bookModel!.books[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetail(id: book?.isbn13 ?? ""),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              book.title ?? "",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  );
                }
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
    );
  }
}
