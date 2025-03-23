package com.example.demo.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.demo.entity.Category;
import com.example.demo.repository.CategoryRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class CategoryService {
    @Autowired
    private CategoryRepository categoryRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    public Map<String,Object> addCate(Category cate) {
        Map<String,Object> respone=new HashMap<>();
        boolean existsName=categoryRepository.existsByTen(cate.getTen());
        if(existsName){
            respone.put("success", false);
            respone.put("message", "Catelogy đã tồn tại");
            return respone;
        }

        Category savCategory=categoryRepository.save(cate);
        respone.put("success", true);
        respone.put("message", "Catelogy thêm thành công");
        respone.put("data", savCategory);
        return respone;
    }

    public void deleteCategory(Integer id) {
        if (!categoryRepository.existsById(id)) {
            throw new EntityNotFoundException("Không tìm thấy danh mục.");
        }
        categoryRepository.deleteById(id);
    }

    public Map<String, Object> updateCate(Integer id, Category updateCate){
        Map<String,Object> respone=new HashMap<>();
        Category exCategory=categoryRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Không tìm thấy nhà xuất bản này"));
        exCategory.setTen(updateCate.getTen());
        Category savCategory=categoryRepository.save(exCategory);
        respone.put("success", true);
        respone.put("message", "Catelogy cập nhật thành công");
        respone.put("data", savCategory);
        return respone;
    }
}
