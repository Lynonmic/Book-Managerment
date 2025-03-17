package com.example.demo.service;

import com.example.demo.model.Book;
import com.example.demo.repository.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

@Service
public class BookService {
    
    private final BookRepository bookRepository;
    private final CloudinaryService cloudinaryService;
    
    @Autowired
    public BookService(BookRepository bookRepository, CloudinaryService cloudinaryService) {
        this.bookRepository = bookRepository;
        this.cloudinaryService = cloudinaryService;
    }
    
    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }
    
    public List<Book> getRecentBooks() {
        return bookRepository.findTop10ByOrderByCreatedAtDesc();
    }
    
    public Optional<Book> getBookById(Long id) {
        return bookRepository.findById(id);
    }
    
    public Book createBook(Book book, MultipartFile image) {
        if (image != null && !image.isEmpty()) {
            String imageUrl = cloudinaryService.uploadFile(image);
            book.setImageUrl(imageUrl);
        }
        return bookRepository.save(book);
    }
    
    public Book updateBook(Long id, Book bookDetails, MultipartFile image) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Book not found with id " + id));
        
        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setDescription(bookDetails.getDescription());
        book.setPrice(bookDetails.getPrice());
        book.setPublisher(bookDetails.getPublisher());
        book.setPageCount(bookDetails.getPageCount());
        book.setIsbn(bookDetails.getIsbn());
        
        if (image != null && !image.isEmpty()) {
            String imageUrl = cloudinaryService.uploadFile(image);
            book.setImageUrl(imageUrl);
        }
        
        return bookRepository.save(book);
    }
    
    public Book updateBookRating(Long id, Double newRating) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Book not found with id " + id));
        
        // Initialize if first rating
        if (book.getRatingCount() == null) {
            book.setRatingCount(0);
        }
        if (book.getRating() == null) {
            book.setRating(0.0);
        }
        
        // Calculate new average rating
        double totalRatingPoints = book.getRating() * book.getRatingCount();
        int newCount = book.getRatingCount() + 1;
        double newAverageRating = (totalRatingPoints + newRating) / newCount;
        
        // Update the book with new rating data
        book.setRatingCount(newCount);
        book.setRating(Math.round(newAverageRating * 10.0) / 10.0); // Round to 1 decimal place
        
        return bookRepository.save(book);
    }
    
    public void deleteBook(Long id) {
        bookRepository.deleteById(id);
    }
    
    public List<Book> searchBooks(String keyword) {
        List<Book> titleResults = bookRepository.findByTitleContainingIgnoreCase(keyword);
        List<Book> authorResults = bookRepository.findByAuthorContainingIgnoreCase(keyword);
        
        // Combine results without duplicates
        for (Book book : authorResults) {
            if (!titleResults.contains(book)) {
                titleResults.add(book);
            }
        }
        
        return titleResults;
    }
}
