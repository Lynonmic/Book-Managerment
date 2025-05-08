const express = require('express');
const router = express.Router();
const seriesController = require('../controllers/seriesController');

// Get all series
router.get('/', seriesController.getAllSeries);

// Get a single series by ID
router.get('/:id', seriesController.getSeriesById);

// Create a new series
router.post('/', seriesController.createSeries);

// Update a series
router.put('/:id', seriesController.updateSeries);

// Delete a series
router.delete('/:id', seriesController.deleteSeries);

// Get books in a series
router.get('/:id/books', seriesController.getBooksInSeries);

module.exports = router;
