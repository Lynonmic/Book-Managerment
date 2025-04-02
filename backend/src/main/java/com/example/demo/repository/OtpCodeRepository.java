package com.example.demo.repository;

import java.util.Optional;

import org.springframework.data.jdbc.repository.query.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.OtpCode;

import jakarta.transaction.Transactional;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, Integer> {
    Optional<OtpCode> findByEmailAndOtp(String email, String otp);

    @Modifying
    @Transactional
    @Query("DELETE FROM OtpEntity o WHERE o.email = :email")
    void deleteByEmail(String email);
}
