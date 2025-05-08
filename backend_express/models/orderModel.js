const db = require('../config/database');

// Get all orders
exports.getAllOrders = async () => {
  try {
    const [rows] = await db.query(`
      SELECT o.ma_don_hang as id, o.ma_khach_hang as customerId, 
             o.ngay_dat as orderDate, o.tong_tien as totalAmount, 
             o.trang_thai as status, c.ten_khach_hang as customerName
      FROM orders o
      LEFT JOIN users c ON o.ma_khach_hang = c.ma_khach_hang
      ORDER BY o.ngay_dat DESC
    `);
    return rows;
  } catch (error) {
    console.error('Error getting all orders:', error);
    throw error;
  }
};

// Get a specific order by ID
exports.getOrderById = async (id) => {
  try {
    const [rows] = await db.query(`
      SELECT o.ma_don_hang as id, o.ma_khach_hang as customerId, 
             o.ngay_dat as orderDate, o.tong_tien as totalAmount, 
             o.trang_thai as status, c.ten_khach_hang as customerName
      FROM orders o
      LEFT JOIN users c ON o.ma_khach_hang = c.ma_khach_hang
      WHERE o.ma_don_hang = ?
    `, [id]);
    
    return rows.length ? rows[0] : null;
  } catch (error) {
    console.error('Error getting order by ID:', error);
    throw error;
  }
};

// Get a specific order by ID with details
exports.getOrderWithDetails = async (id) => {
  try {
    // First fetch the order
    const [orderRows] = await db.query(`
      SELECT o.ma_don_hang as id, o.ma_khach_hang as customerId, 
             o.ngay_dat as orderDate, o.tong_tien as totalAmount, 
             o.trang_thai as status, c.ten_khach_hang as customerName
      FROM orders o
      LEFT JOIN users c ON o.ma_khach_hang = c.ma_khach_hang
      WHERE o.ma_don_hang = ?
    `, [id]);
    
    if (orderRows.length === 0) {
      return null;
    }
    
    const order = orderRows[0];
    
    // Then fetch the order details
    const [detailRows] = await db.query(`
      SELECT d.ma_chi_tiet as id, d.ma_don_hang as orderId, 
             d.ma_sach as bookId, d.so_luong as quantity, 
             d.gia as price, b.ten_sach as bookTitle
      FROM oder_details d
      LEFT JOIN books b ON d.ma_sach = b.ma_sach
      WHERE d.ma_don_hang = ?
    `, [id]);
    
    // Add the details to the order
    order.orderDetails = detailRows;
    
    return order;
  } catch (error) {
    console.error('Error getting order with details:', error);
    throw error;
  }
};

// Create a new order
exports.createOrder = async (orderData) => {
  try {
    const { customerId, totalAmount, status = "chờ xử lý" } = orderData;
    orderData.orderDate = new Date();
    const [result] = await db.query(
      'INSERT INTO orders (ma_khach_hang, ngay_dat, tong_tien, trang_thai) VALUES (?, ?, ?, ?)',
      [customerId, orderData.orderDate, totalAmount, status]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error creating order:', error);
    throw error;
  }
};

// Update an existing order
exports.updateOrder = async (id, orderData) => {
  try {
    const { customerId, orderDate, totalAmount, status } = orderData;
    
    const [result] = await db.query(
      'UPDATE orders SET ma_khach_hang = ?, ngay_dat = ?, tong_tien = ?, trang_thai = ? WHERE ma_don_hang = ?',
      [customerId, new Date(orderDate), totalAmount, status, id]
    );
    
    return result.affectedRows;
  } catch (error) {
    console.error('Error updating order:', error);
    throw error;
  }
};

// Update just the order status
exports.updateOrderStatus = async (id, status) => {
  try {
    const [result] = await db.query(
      'UPDATE orders SET trang_thai = ? WHERE ma_don_hang = ?',
      [status, id]
    );
    
    return result.affectedRows;
  } catch (error) {
    console.error('Error updating order status:', error);
    throw error;
  }
};

// Delete an order
exports.deleteOrder = async (id) => {
  try {
    // First delete related order details
    await db.query('DELETE FROM oder_details WHERE ma_don_hang = ?', [id]);
    
    // Then delete the order
    const [result] = await db.query('DELETE FROM orders WHERE ma_don_hang = ?', [id]);
    
    return result.affectedRows;
  } catch (error) {
    console.error('Error deleting order:', error);
    throw error;
  }
};

// Get order details for a specific order
exports.getOrderDetails = async (orderId) => {
  try {
    const [rows] = await db.query(`
      SELECT d.ma_chi_tiet as id, d.ma_don_hang as orderId, 
             d.ma_sach as bookId, d.so_luong as quantity, 
             d.gia as price, b.ten_sach as bookTitle
      FROM oder_details d
      LEFT JOIN books b ON d.ma_sach = b.ma_sach
      WHERE d.ma_don_hang = ?
    `, [orderId]);
    
    return rows;
  } catch (error) {
    console.error('Error getting order details:', error);
    throw error;
  }
};

// Add a detail to an order
exports.addOrderDetail = async (orderId, detailData) => {
  try {
    const { bookId, quantity, price } = detailData;
    
    const [result] = await db.query(
      'INSERT INTO oder_details (ma_don_hang, ma_sach, so_luong, gia) VALUES (?, ?, ?, ?)',
      [orderId, bookId, quantity, price]
    );
    
    // Update the order's total amount
    await db.query(
      `UPDATE orders 
       SET tong_tien = (SELECT SUM(so_luong * gia) FROM oder_details WHERE ma_don_hang = ?)
       WHERE ma_don_hang = ?`,
      [orderId, orderId]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error adding order detail:', error);
    throw error;
  }
};
