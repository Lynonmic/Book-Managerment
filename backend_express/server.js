const express = require('express');
const cors = require('cors');
const path = require('path');
const bookRoutes = require('./routes/bookRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const orderRoutes = require('./routes/orderRoutes');
const reviewRoutes = require('./routes/reviewRoutes'); // Import review routes
const uploadRoutes = require('./routes/uploadRoutes'); // Import upload routes
const seriesRoutes = require('./routes/seriesRoutes'); // Import series routes
const db = require('./config/database');

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: '*', // Allow all origins during development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/books', bookRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/reviews', reviewRoutes); // Add reviews routes
app.use('/api/uploads', uploadRoutes); // Add upload routes
app.use('/api/series', seriesRoutes); // Add series routes

// Create temp directory for file uploads if it doesn't exist
const tempDir = path.join(__dirname, 'temp');
if (!require('fs').existsSync(tempDir)) {
  require('fs').mkdirSync(tempDir, { recursive: true });
}

// Root route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Book Management API' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'production' ? null : err.message
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});