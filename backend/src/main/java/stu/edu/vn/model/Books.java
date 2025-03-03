package stu.edu.vn.model;

import java.time.LocalDateTime;
import java.util.Locale.Category;

import lombok.Data;


@Data

public class Books {
     private Integer maSach;

    private String tenSach;
    private String urlAnh;
    private String tacGia;
    private Integer gia;
    private Integer soLuong;
    private String moTa;

    private Category category;


    private Publisher publisher;

    private LocalDateTime ngayTao;
    private LocalDateTime ngayCapNhat;
}
