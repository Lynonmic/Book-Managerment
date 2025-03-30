package com.example.demo.repository;

import java.util.List;
import java.util.Optional;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> getUserByEmail(String email);
    Optional<User> findBySoDienThoai(String soDienThoai);
    Optional<User> findByEmail(String email);
    List<User> findByRoles(int roles);
    
}