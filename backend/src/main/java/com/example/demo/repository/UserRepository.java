package com.example.demo.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> getUserByEmail(String email);

    Optional<User> findBySoDienThoai(String soDienThoai);

    List<User> findByRoles(Integer roles);

    @Query("SELECT u FROM User u WHERE u.roles = 1 AND (" +
            "LOWER(u.ten_khach_hang) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.soDienThoai) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    List<User> searchUsers(@Param("keyword") String keyword);

}
