package com.example.demo.entity;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer ma_khach_hang;

    @Column(nullable = false)
    private String ten_khach_hang;

    @Column(nullable = false)
    private String url_avata;

    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    @JsonIgnore
    private String password; // Lưu mật khẩu đã mã hóa
    @Column
    private String 	so_dien_thoai;

    @Column
    private String dia_chi;

    @Column(nullable = false, updatable = false)
    private LocalDateTime ngay_tao = LocalDateTime.now();

}
