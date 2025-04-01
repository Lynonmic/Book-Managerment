const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');

// Reviews routes
router.get('/', reviewController.getAllReviews);                   // Access at /api/reviews
router.get('/:id', reviewController.getReviewById);                // Access at /api/reviews/:id
router.post('/', reviewController.createReview);                   // Access at /api/reviews
router.put('/:id', reviewController.updateReview);                 // Access at /api/reviews/:id
router.delete('/:id', reviewController.deleteReview);              // Access at /api/reviews/:id

// Book-specific review routes
router.get('/book/:bookId', reviewController.getReviewsByBookId);         // Access at /api/reviews/book/:bookId
router.get('/book/:bookId/rating', reviewController.getBookAverageRating); // Access at /api/reviews/book/:bookId/rating

// Customer-specific review routes
router.get('/customer/:customerId', reviewController.getReviewsByCustomerId); // Access at /api/reviews/customer/:customerId

module.exports = router;
