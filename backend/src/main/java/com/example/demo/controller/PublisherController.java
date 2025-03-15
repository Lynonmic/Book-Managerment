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

import com.example.demo.entity.Publisher;
import com.example.demo.service.PublisherService;

@RestController
@RequestMapping("/auth/nha-xuat-ban")
public class PublisherController {
    @Autowired
    private PublisherService nhaXuatBanService;

    @GetMapping(produces = "application/json; charset=UTF-8")
    public List<Publisher> getAllNhaXuatBan() {
        return nhaXuatBanService.getAllNhaXuatBan();
    }

    @PostMapping
    public ResponseEntity<Publisher> createNhaXuatBan(@RequestBody Publisher nhaXuatBan) {
        return ResponseEntity.ok(nhaXuatBanService.addNhaXuatBan(nhaXuatBan));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteNhaXuatBan(@PathVariable Integer id) {
        nhaXuatBanService.deleteNhaXuatBan(id);
        return ResponseEntity.ok("Nhà xuất bản đã được xóa.");
    }
}
