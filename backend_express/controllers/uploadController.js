const { uploadImage, deleteImage } = require('../utils/cloudinaryUpload');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure multer for temporary storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const tempDir = path.join(__dirname, '../temp');
    
    // Create temp directory if it doesn't exist
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }
    
    cb(null, tempDir);
  },
  filename: (req, file, cb) => {
    // Create unique filename with original extension
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

// File filter to only accept images
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (extname && mimetype) {
    return cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'));
  }
};

// Initialize multer upload
const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Upload image controller
const uploadBookImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: 'No file uploaded' 
      });
    }

    // Upload to Cloudinary
    const result = await uploadImage(req.file.path, 'books');
    
    if (!result.success) {
      return res.status(500).json({ 
        success: false, 
        message: 'Failed to upload to Cloudinary',
        error: result.error
      });
    }

    // Return success with image URL
    return res.status(200).json({
      success: true,
      message: 'Image uploaded successfully',
      imageUrl: result.url,
      publicId: result.publicId
    });
  } catch (error) {
    console.error('Error in upload controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during upload',
      error: error.message
    });
  }
};

// Delete image controller
const deleteBookImage = async (req, res) => {
  try {
    const { publicId } = req.body;
    
    if (!publicId) {
      return res.status(400).json({
        success: false,
        message: 'Public ID is required'
      });
    }

    const result = await deleteImage(publicId);
    
    if (!result.success) {
      return res.status(500).json({
        success: false,
        message: 'Failed to delete from Cloudinary',
        error: result.error
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Image deleted successfully'
    });
  } catch (error) {
    console.error('Error in delete controller:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during deletion',
      error: error.message
    });
  }
};

module.exports = {
  upload,
  uploadBookImage,
  deleteBookImage
};
