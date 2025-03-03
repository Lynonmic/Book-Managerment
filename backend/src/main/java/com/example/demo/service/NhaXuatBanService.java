package com.example.demo.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.NhaXuatBan;
import com.example.demo.repository.NhaXuatBanRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class NhaXuatBanService {
    @Autowired
    private NhaXuatBanRepository nhaXuatBanRepository;

    public List<NhaXuatBan> getAllNhaXuatBan() {
        return nhaXuatBanRepository.findAll();
    }

    public NhaXuatBan addNhaXuatBan(NhaXuatBan nhaXuatBan) {
        return nhaXuatBanRepository.save(nhaXuatBan);
    }

    public void deleteNhaXuatBan(Integer id) {
        if (!nhaXuatBanRepository.existsById(id)) {
            throw new EntityNotFoundException("Không tìm thấy nhà xuất bản.");
        }
        nhaXuatBanRepository.deleteById(id);
    }
}