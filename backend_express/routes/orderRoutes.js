const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

// Order routes
router.get('/', orderController.getAllOrders);           // Access at /api/orders
router.get('/:id', orderController.getOrderById);        // Access at /api/orders/:id
router.post('/', orderController.createOrder);           // Access at /api/orders
router.put('/:id', orderController.updateOrder);         // Access at /api/orders/:id
router.patch('/:id/status', orderController.updateOrderStatus);  // Access at /api/orders/:id/status
router.delete('/:id', orderController.deleteOrder);      // Access at /api/orders/:id

// Direct route to get order with details
router.get('/:id/with-details', orderController.getOrderWithDetails);  // Access at /api/orders/:id/with-details

// Order details routes
router.get('/:id/details', orderController.getOrderDetails);     // Access at /api/orders/:id/details
router.post('/:id/details', orderController.addOrderDetail);     // Access at /api/orders/:id/details

module.exports = router;
