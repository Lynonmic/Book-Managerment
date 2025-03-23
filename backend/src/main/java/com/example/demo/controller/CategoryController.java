package com.example.demo.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.Category;
import com.example.demo.service.CategoryService;

import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/auth/categories")
public class CategoryController {
    @Autowired
    private CategoryService categoryService;

    @GetMapping(produces = "application/json; charset=UTF-8")
    List<Category> getAllCategories() {
        return categoryService.getAllCategories();
    }
    @PostMapping(produces = "application/json; charset=UTF-8")
    public ResponseEntity<Map<String,Object>> createNhaXuatBan(@RequestBody Category category) {
        Map<String,Object> result=categoryService.addCate(category);
        if(!(boolean) result.get("success")){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
        }
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteCategory(@PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        try{
            categoryService.deleteCategory(id);
            response.put("success", true);
            response.put("message", "Category đã được xóa.");
            return ResponseEntity.ok(response);
        }catch(EntityNotFoundException e){
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }catch (Exception e) {
            response.put("success", false);
            response.put("message", "Lỗi hệ thống, vui lòng thử lại.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updatePub(@PathVariable Integer id,
            @RequestBody Category updaCategory) {
        try {
            Map<String, Object> result = categoryService.updateCate(id, updaCategory);
            return ResponseEntity.ok(result);
        } catch (EntityNotFoundException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Lỗi hệ thống, vui lòng thử lại.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
