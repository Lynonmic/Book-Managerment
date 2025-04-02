const ReviewModel = require('../models/reviewModel');

// Helper function to format review response
const formatReviewResponse = (review) => {
  if (!review) return null;
  
  return {
    id: review.id,
    bookId: review.bookId,
    customerId: review.customerId,
    rating: review.rating,
    comment: review.comment,
    createdAt: review.createdAt,
    bookTitle: review.bookTitle,
    customerName: review.customerName
  };
};

// Get all reviews
exports.getAllReviews = async (req, res) => {
  try {
    const reviews = await ReviewModel.getAllReviews();
    res.status(200).json({
      success: true,
      data: reviews.map(review => formatReviewResponse(review))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error.message
    });
  }
};

// Get reviews by book ID
exports.getReviewsByBookId = async (req, res) => {
  try {
    const reviews = await ReviewModel.getReviewsByBookId(req.params.bookId);
    res.status(200).json({
      success: true,
      data: reviews.map(review => formatReviewResponse(review))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews for this book',
      error: error.message
    });
  }
};

// Get reviews by customer ID
exports.getReviewsByCustomerId = async (req, res) => {
  try {
    const reviews = await ReviewModel.getReviewsByCustomerId(req.params.customerId);
    res.status(200).json({
      success: true,
      data: reviews.map(review => formatReviewResponse(review))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews for this customer',
      error: error.message
    });
  }
};

// Get a single review by ID
exports.getReviewById = async (req, res) => {
  try {
    const review = await ReviewModel.getReviewById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }
    res.status(200).json({
      success: true,
      data: formatReviewResponse(review)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch review',
      error: error.message
    });
  }
};

// Create a new review
exports.createReview = async (req, res) => {
  try {
    // Validate required fields
    const { bookId, customerId, rating } = req.body;
    
    if (!bookId || !customerId || rating === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: bookId, customerId, rating'
      });
    }
    
    // Validate rating is between 1 and 5
    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }
    
    const reviewId = await ReviewModel.createReview(req.body);
    const newReview = await ReviewModel.getReviewById(reviewId);
    
    // Update the book's average rating
    const averageRating = await ReviewModel.getBookAverageRating(bookId);
    
    res.status(201).json({
      success: true,
      message: 'Review created successfully',
      data: formatReviewResponse(newReview),
      bookRating: averageRating
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create review',
      error: error.message
    });
  }
};

// Update a review
exports.updateReview = async (req, res) => {
  try {
    // Validate required fields
    const { rating, comment } = req.body;
    
    if (rating === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Rating is required'
      });
    }
    
    // Validate rating is between 1 and 5
    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }
    
    const affected = await ReviewModel.updateReview(req.params.id, req.body);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Review not found or no changes made'
      });
    }
    
    const updatedReview = await ReviewModel.getReviewById(req.params.id);
    
    // Update the book's average rating
    const averageRating = await ReviewModel.getBookAverageRating(updatedReview.bookId);
    
    res.status(200).json({
      success: true,
      message: 'Review updated successfully',
      data: formatReviewResponse(updatedReview),
      bookRating: averageRating
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update review',
      error: error.message
    });
  }
};

// Delete a review
exports.deleteReview = async (req, res) => {
  try {
    // First get the review to know which book's rating to update
    const review = await ReviewModel.getReviewById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }
    
    const bookId = review.bookId;
    
    // Delete the review
    const affected = await ReviewModel.deleteReview(req.params.id);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }
    
    // Update the book's average rating
    const averageRating = await ReviewModel.getBookAverageRating(bookId);
    
    res.status(200).json({
      success: true,
      message: 'Review deleted successfully',
      bookRating: averageRating
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete review',
      error: error.message
    });
  }
};

// Get book average rating
exports.getBookAverageRating = async (req, res) => {
  try {
    const averageRating = await ReviewModel.getBookAverageRating(req.params.bookId);
    res.status(200).json({
      success: true,
      data: averageRating
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch book average rating',
      error: error.message
    });
  }
};
