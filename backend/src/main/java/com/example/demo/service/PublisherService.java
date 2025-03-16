package com.example.demo.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    public Map<String, Object> addNhaXuatBan(Publisher nhaXuatBan) {
        Map<String, Object> response = new HashMap<>();

        // Kiểm tra trùng tên, email, số điện thoại
        boolean existsTen = nhaXuatBanRepository.existsByTenNhaXuatBan(nhaXuatBan.getTenNhaXuatBan());
        boolean existsEmail = nhaXuatBanRepository.existsByEmail(nhaXuatBan.getEmail());
        boolean existsSDT = nhaXuatBanRepository.existsBySoDienThoai(nhaXuatBan.getSoDienThoai());

        if (existsTen) {
            response.put("success", false);
            response.put("message", "Tên nhà xuất bản đã tồn tại!");
            return response;
        }

        if (existsEmail) {
            response.put("success", false);
            response.put("message", "Email đã tồn tại!");
            return response;
        }

        if (existsSDT) {
            response.put("success", false);
            response.put("message", "Số điện thoại đã tồn tại!");
            return response;
        }

        // Nếu không trùng, tiến hành lưu
        Publisher savedPublisher = nhaXuatBanRepository.save(nhaXuatBan);
        response.put("success", true);
        response.put("message", "Tạo nhà xuất bản thành công!");
        response.put("data", savedPublisher);
        return response;
    }

    public void deleteNhaXuatBan(Integer id) {
        System.out.println("Kiểm tra ID: " + id);

        if (!nhaXuatBanRepository.existsById(id)) {
            System.out.println("Lỗi: Không tìm thấy nhà xuất bản ID = " + id);
            throw new EntityNotFoundException("Không tìm thấy nhà xuất bản ID = " + id);
        }

        nhaXuatBanRepository.deleteById(id);
        System.out.println("Đã xóa nhà xuất bản ID: " + id);
    }

    public Map<String, Object> update(Integer id, Publisher updatePublisher) {
        Map<String, Object> response = new HashMap<>();
        Publisher existingPublisher = nhaXuatBanRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhà xuất bản ID = " + id));
        existingPublisher.setTenNhaXuatBan(updatePublisher.getTenNhaXuatBan());
        existingPublisher.setEmail(updatePublisher.getEmail());
        existingPublisher.setSoDienThoai(updatePublisher.getSoDienThoai());
        existingPublisher.setDiaChi(updatePublisher.getDiaChi());

        Publisher savePub = nhaXuatBanRepository.save(existingPublisher);
        response.put("success", true);
        response.put("message", "Cập nhật nhà xuất bản thành công!");
        response.put("data", savePub);
        return response;
    }
}