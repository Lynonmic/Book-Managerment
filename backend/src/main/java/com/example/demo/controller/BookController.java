package com.example.demo.controller;

import com.example.demo.model.Book;
import com.example.demo.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*") // For development, consider restricting in production
public class BookController {
    
    private final BookService bookService;
    
    @Autowired
    public BookController(BookService bookService) {
        this.bookService = bookService;
    }
    
    @GetMapping("/home")
    public ResponseEntity<Map<String, Object>> getHomePageBooks() {
        // Get recent books for the home screen
        List<Book> recentBooks = bookService.getRecentBooks();
        
        Map<String, Object> response = new HashMap<>();
        response.put("recentBooks", recentBooks);
        // You can add more sections like featured books, bestsellers, etc.
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping
    public ResponseEntity<List<Book>> getAllBooks() {
        return ResponseEntity.ok(bookService.getAllBooks());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Book> getBookById(@PathVariable Long id) {
        return bookService.getBookById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<Book> createBook(
            @RequestPart("book") Book book,
            @RequestPart(value = "image", required = false) MultipartFile image) {
        Book createdBook = bookService.createBook(book, image);
        return new ResponseEntity<>(createdBook, HttpStatus.CREATED);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Book> updateBook(
            @PathVariable Long id,
            @RequestPart("book") Book bookDetails,
            @RequestPart(value = "image", required = false) MultipartFile image) {
        try {
            Book updatedBook = bookService.updateBook(id, bookDetails, image);
            return ResponseEntity.ok(updatedBook);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Book>> searchBooks(@RequestParam String query) {
        List<Book> results = bookService.searchBooks(query);
        return ResponseEntity.ok(results);
    }
    
    @PostMapping("/{id}/rate")
    public ResponseEntity<Book> rateBook(@PathVariable Long id, @RequestBody Map<String, Double> ratingData) {
        Double rating = ratingData.get("rating");
        if (rating == null || rating < 0 || rating > 5) {
            return ResponseEntity.badRequest().build();
        }
        
        try {
            Book updatedBook = bookService.updateBookRating(id, rating);
            return ResponseEntity.ok(updatedBook);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
