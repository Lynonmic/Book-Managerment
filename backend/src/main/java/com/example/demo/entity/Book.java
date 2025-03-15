package com.example.demo.entity;

import java.time.LocalDateTime;

import jakarta.persistence.ForeignKey;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@Table(name = "books")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_sach")
    private Integer maSach;

    @Column(name = "ten_sach", nullable = false)
    private String tenSach;

    @Column(name = "url_anh", nullable = false)
    private String urlAnh;

    private String tacGia;
    private Integer gia;
    private Integer soLuong;

    @Column(columnDefinition = "TEXT")
    private String moTa;

    @Column(name = "ngay_tao", updatable = false)
    private LocalDateTime ngayTao;

    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;

    @ManyToOne
    @JoinColumn(name = "ma_danh_muc", referencedColumnName = "id", foreignKey = @ForeignKey(name = "fk_sach_danhmuc"))
    private Category category;

    @ManyToOne
    @JoinColumn(name = "ma_nha_xuat_ban", referencedColumnName = "maNhaXuatBan", foreignKey = @ForeignKey(name = "fk_sach_nxb"))
    private Publisher nhaXuatBan;
}
