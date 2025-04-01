const OrderModel = require('../models/orderModel');

// Helper function to format order response
const formatOrderResponse = (order) => {
  if (!order) return null;
  
  return {
    id: order.id,
    customerId: order.customerId,
    orderDate: order.orderDate,
    totalAmount: order.totalAmount,
    status: order.status,
    customerName: order.customerName
  };
};

// Get all orders
exports.getAllOrders = async (req, res) => {
  try {
    const orders = await OrderModel.getAllOrders();
    res.status(200).json({
      success: true,
      data: orders.map(order => formatOrderResponse(order))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders',
      error: error.message
    });
  }
};

// Get a single order by ID
exports.getOrderById = async (req, res) => {
  try {
    let order;
    
    // Check if details should be included
    if (req.query.include_details === 'true') {
      order = await OrderModel.getOrderWithDetails(req.params.id);
    } else {
      order = await OrderModel.getOrderById(req.params.id);
    }
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: order
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order',
      error: error.message
    });
  }
};

// Create a new order
exports.createOrder = async (req, res) => {
  try {
    // Validate required fields
    const { customerId, orderDate, totalAmount } = req.body;
    
    if (!customerId || !orderDate || totalAmount === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: customerId, orderDate, totalAmount'
      });
    }
    
    const orderId = await OrderModel.createOrder(req.body);
    const newOrder = await OrderModel.getOrderById(orderId);
    
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: formatOrderResponse(newOrder)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create order',
      error: error.message
    });
  }
};

// Update an order
exports.updateOrder = async (req, res) => {
  try {
    // Validate required fields
    const { customerId, orderDate, totalAmount, status } = req.body;
    
    if (!customerId || !orderDate || totalAmount === undefined || !status) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: customerId, orderDate, totalAmount, status'
      });
    }
    
    const affected = await OrderModel.updateOrder(req.params.id, req.body);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or no changes made'
      });
    }
    
    const updatedOrder = await OrderModel.getOrderById(req.params.id);
    
    res.status(200).json({
      success: true,
      message: 'Order updated successfully',
      data: formatOrderResponse(updatedOrder)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update order',
      error: error.message
    });
  }
};

// Update order status
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Status is required'
      });
    }
    
    const affected = await OrderModel.updateOrderStatus(req.params.id, status);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    const updatedOrder = await OrderModel.getOrderById(req.params.id);
    
    res.status(200).json({
      success: true,
      message: 'Order status updated successfully',
      data: formatOrderResponse(updatedOrder)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update order status',
      error: error.message
    });
  }
};

// Delete an order
exports.deleteOrder = async (req, res) => {
  try {
    const affected = await OrderModel.deleteOrder(req.params.id);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    res.status(200).json({
      success: true,
      message: 'Order deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete order',
      error: error.message
    });
  }
};

// Get order details
exports.getOrderDetails = async (req, res) => {
  try {
    const details = await OrderModel.getOrderDetails(req.params.id);
    res.status(200).json({
      success: true,
      data: details
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order details',
      error: error.message
    });
  }
};

// Add detail to order
exports.addOrderDetail = async (req, res) => {
  try {
    const { bookId, quantity, price } = req.body;
    
    if (!bookId || !quantity || price === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: bookId, quantity, price'
      });
    }
    
    const detailId = await OrderModel.addOrderDetail(req.params.id, req.body);
    
    // Get the updated order to reflect new total amount
    const updatedOrder = await OrderModel.getOrderById(req.params.id);
    
    res.status(201).json({
      success: true,
      message: 'Order detail added successfully',
      data: {
        detailId: detailId,
        order: formatOrderResponse(updatedOrder)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to add order detail',
      error: error.message
    });
  }
};

// Get order with details
exports.getOrderWithDetails = async (req, res) => {
  try {
    const order = await OrderModel.getOrderWithDetails(req.params.id);
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: order
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order with details',
      error: error.message
    });
  }
};
