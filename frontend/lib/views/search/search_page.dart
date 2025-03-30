import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/service/books/book_services.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    print("🔍 Searching for: $query"); // Log khi search
    if (query.isEmpty) {
      print("⚠️ Empty search query");
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      _searchResults = await BookService().searchBooks(query);
      print("✅ Search Results: ${_searchResults.length} books found");

      if (_searchResults.isEmpty) {
        print("⚠️ No books found!");
      }
    } catch (e) {
      print("❌ Search error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Enter book title or author...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                print("🔍 User typed: $value"); // Log nhập text
                _performSearch(value);
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                  child:
                      _searchResults.isEmpty
                          ? const Center(child: Text("No results found"))
                          : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final book = _searchResults[index];
                              return ListTile(
                                leading:
                                    book['imageUrl'] != null
                                        ? Image.network(
                                          book['imageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                        : const Icon(Icons.book),
                                title: Text(book['title']),
                                subtitle: Text("Author: ${book['author']}"),
                              );
                            },
                          ),
                ),
          ],
        ),
      ),
    );
  }
}
