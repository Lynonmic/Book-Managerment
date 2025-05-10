const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');

// Lấy giỏ hàng của user
router.get('/user/:userId', cartController.getUserCart);

// Thêm sách vào giỏ hàng
router.post('/add', cartController.addToCart);

// Cập nhật số lượng sách trong giỏ hàng
router.put('/:cartId', cartController.updateCartItem);

// Xóa một sản phẩm khỏi giỏ hàng
router.delete('/:cartId', cartController.removeFromCart);

// Xóa toàn bộ giỏ hàng của user
router.delete('/user/:userId', cartController.clearCart);

module.exports = router;