// controllers/cartController.js
const CartModel = require('../models/CartModel');

const cartController = {
    getUserCart: async (req, res) => {
        try {
            const userId = req.params.userId;
            const cart = await CartModel.getUserCart(userId);
            res.json({
                success: true,
                data: cart
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message
            });
        }
    },

    addToCart: async (req, res) => {
        try {
            const { userId, bookId, quantity } = req.body;
            const cartId = await CartModel.addToCart({ userId, bookId, quantity });
            res.json({
                success: true,
                data: { id: cartId }
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message
            });
        }
    },

    updateCartItem: async (req, res) => {
        try {
            const { cartId } = req.params;
            const { quantity } = req.body;
            const result = await CartModel.updateCartItem(cartId, quantity);
            res.json({
                success: true,
                data: { affectedRows: result }
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message
            });
        }
    },

    removeFromCart: async (req, res) => {
        try {
            const { cartId } = req.params;
            const result = await CartModel.removeFromCart(cartId);
            res.json({
                success: true,
                data: { affectedRows: result }
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message
            });
        }
    },

    clearCart: async (req, res) => {
        try {
            const { userId } = req.params;
            const result = await CartModel.clearCart(userId);
            res.json({
                success: true,
                data: { affectedRows: result }
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message
            });
        }
    }
};

module.exports = cartController;