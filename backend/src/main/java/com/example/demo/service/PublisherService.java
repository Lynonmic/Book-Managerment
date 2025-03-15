package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.Publisher;
import com.example.demo.repository.PublisherRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class PublisherService {
    @Autowired
    private PublisherRepository nhaXuatBanRepository;

    public List<Publisher> getAllNhaXuatBan() {
        return nhaXuatBanRepository.findAll();
    }

    public Publisher addNhaXuatBan(Publisher nhaXuatBan) {
        return nhaXuatBanRepository.save(nhaXuatBan);
    }

    public void deleteNhaXuatBan(Integer id) {
        if (!nhaXuatBanRepository.existsById(id)) {
            throw new EntityNotFoundException("Không tìm thấy nhà xuất bản.");
        }
        nhaXuatBanRepository.deleteById(id);
    }
}