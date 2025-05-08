const cloudinary = require('../config/cloudinary');
const fs = require('fs');

/**
 * Upload an image to Cloudinary
 * @param {string} imagePath - Path to the image file
 * @param {string} folder - Optional folder name in Cloudinary
 * @returns {Promise<Object>} - Cloudinary upload result
 */
const uploadImage = async (imagePath, folder = 'books') => {
  try {
    // Upload the image to Cloudinary
    const result = await cloudinary.uploader.upload(imagePath, {
      folder: folder,
      resource_type: 'auto',
    });
    
    // If the image was a temporary file, remove it
    if (imagePath.includes('temp')) {
      fs.unlinkSync(imagePath);
    }
    
    return {
      success: true,
      url: result.secure_url,
      publicId: result.public_id
    };
  } catch (error) {
    console.error('Error uploading to Cloudinary:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

/**
 * Delete an image from Cloudinary
 * @param {string} publicId - Public ID of the image to delete
 * @returns {Promise<Object>} - Cloudinary deletion result
 */
const deleteImage = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    return {
      success: true,
      result
    };
  } catch (error) {
    console.error('Error deleting from Cloudinary:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

module.exports = {
  uploadImage,
  deleteImage
};
