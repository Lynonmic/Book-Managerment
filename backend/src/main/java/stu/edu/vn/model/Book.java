package stu.edu.vn.model;
import java.time.LocalDateTime;
import java.util.Locale.Category;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Entity
@Table(name = "books")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer maSach;

    private String tenSach;
    private String urlAnh;
    private String tacGia;
    private Integer gia;
    private Integer soLuong;
    private String moTa;

    @ManyToOne
    @JoinColumn(name = "ma_danh_muc")
    private Category category;

    @ManyToOne
    @JoinColumn(name = "ma_nha_xuat_ban")
    private Publisher publisher;

    private LocalDateTime ngayTao;
    private LocalDateTime ngayCapNhat;
}