package com.example.demo.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.NhaXuatBan;
import com.example.demo.service.NhaXuatBanService;

@RestController
@RequestMapping("/quanly_sach/nha-xuat-ban")
public class NhaXuatBanController {
    @Autowired
    private NhaXuatBanService nhaXuatBanService;

    @GetMapping
    public List<NhaXuatBan> getAllNhaXuatBan() {
        return nhaXuatBanService.getAllNhaXuatBan();
    }

    @PostMapping
    public ResponseEntity<NhaXuatBan> createNhaXuatBan(@RequestBody NhaXuatBan nhaXuatBan) {
        return ResponseEntity.ok(nhaXuatBanService.addNhaXuatBan(nhaXuatBan));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteNhaXuatBan(@PathVariable Integer id) {
        nhaXuatBanService.deleteNhaXuatBan(id);
        return ResponseEntity.ok("Nhà xuất bản đã được xóa.");
    }
}
