const express = require('express');
const router = express.Router();
const { upload, uploadBookImage, deleteBookImage } = require('../controllers/uploadController');

// Route for uploading book images
router.post('/book-image', upload.single('image'), uploadBookImage);

// Route for deleting book images
router.delete('/book-image', deleteBookImage);

module.exports = router;
