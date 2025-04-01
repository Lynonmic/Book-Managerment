// routes/categoryRoutes.js
const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

// Define routes for categories
router.get('/', categoryController.getAllCategories);         // Access at /api/categories
router.get('/:id', categoryController.getCategoryById);       // Access at /api/categories/:id
router.post('/', categoryController.createCategory);          // Access at /api/categories
router.put('/:id', categoryController.updateCategory);        // Access at /api/categories/:id
router.delete('/:id', categoryController.deleteCategory);     // Access at /api/categories/:id

module.exports = router;