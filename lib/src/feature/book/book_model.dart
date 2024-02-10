// To parse this JSON data, do
//
//     final bookModel = bookModelFromJson(jsonString);

import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
    String error;
    String total;
    String page;
    List<Book> books;

    BookModel({
        required this.error,
        required this.total,
        required this.page,
        required this.books,
    });

    factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        error: json["error"],
        total: json["total"],
        page: json["page"],
        books: List<Book>.from(json["books"].map((x) => Book.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error,
        "total": total,
        "page": page,
        "books": List<dynamic>.from(books.map((x) => x.toJson())),
    };
}

class Book {
    String title;
    String subtitle;
    String isbn13;
    String price;
    String image;
    String url;

    Book({
        required this.title,
        required this.subtitle,
        required this.isbn13,
        required this.price,
        required this.image,
        required this.url,
    });

    factory Book.fromJson(Map<String, dynamic> json) => Book(
        title: json["title"],
        subtitle: json["subtitle"],
        isbn13: json["isbn13"],
        price: json["price"],
        image: json["image"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "subtitle": subtitle,
        "isbn13": isbn13,
        "price": price,
        "image": image,
        "url": url,
    };
}