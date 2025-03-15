package com.example.demo.entity;

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
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "nha_xuat_ban")
public class Publisher {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer maNhaXuatBan;

    @Column(name = "ten_nha_xuat_ban", unique = true, nullable = false)
    private String tenNhaXuatBan;

    @Column(name = "dia_chi", nullable = false)
    private String diaChi;
    @Column(name = "so_dien_thoai", unique = true, nullable = false)
    private String soDienThoai;
    @Column(name = "email", unique = true, nullable = false)
    private String email;
}
