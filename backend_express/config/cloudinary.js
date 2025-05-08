const cloudinary = require('cloudinary').v2;

// Configure Cloudinary with your credentials
cloudinary.config({
  cloud_name: 'BookManagement',
  api_key: '474278343933674',
  api_secret: 'pDwSeDQP9vP5Q-jDjFhJ5eYRiC8'
});

module.exports = cloudinary;
