package com.example.demo.repository;

import com.example.demo.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {
    // Find featured books for home screen
    List<Book> findTop10ByOrderByCreatedAtDesc();
    
    // Find books by title containing the search term
    List<Book> findByTitleContainingIgnoreCase(String title);
    
    // Find books by author
    List<Book> findByAuthorContainingIgnoreCase(String author);
}