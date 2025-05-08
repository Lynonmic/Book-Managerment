const SeriesModel = require("../models/seriesModel");

const formatSeriesResponse = (series) => {
  if (!series) return null;

  return {
    id: series.id,
    name: series.name
  };
};

// Get all series
exports.getAllSeries = async (req, res) => {
  try {
    const seriesList = await SeriesModel.getAllSeries();
    res.status(200).json({
      success: true,
      data: seriesList.map((series) => formatSeriesResponse(series)),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch series",
      error: error.message,
    });
  }
};

// Get a single series by ID
exports.getSeriesById = async (req, res) => {
  try {
    const series = await SeriesModel.getSeriesById(req.params.id);
    if (!series) {
      return res.status(404).json({
        success: false,
        message: "Series not found",
      });
    }
    res.status(200).json({
      success: true,
      data: formatSeriesResponse(series),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch series",
      error: error.message,
    });
  }
};

// Create a new series
exports.createSeries = async (req, res) => {
  try {
    const seriesId = await SeriesModel.createSeries(req.body);
    res.status(201).json({
      success: true,
      message: "Series created successfully",
      data: { id: seriesId },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to create series",
      error: error.message,
    });
  }
};

// Update a series
exports.updateSeries = async (req, res) => {
  try {
    const affected = await SeriesModel.updateSeries(req.params.id, req.body);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: "Series not found or no changes made",
      });
    }
    res.status(200).json({
      success: true,
      message: "Series updated successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to update series",
      error: error.message,
    });
  }
};

// Delete a series
exports.deleteSeries = async (req, res) => {
  try {
    const affected = await SeriesModel.deleteSeries(req.params.id);
    if (affected === 0) {
      return res.status(404).json({
        success: false,
        message: "Series not found",
      });
    }
    res.status(200).json({
      success: true,
      message: "Series deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to delete series",
      error: error.message,
    });
  }
};

// Get books in a series
exports.getBooksInSeries = async (req, res) => {
  try {
    const books = await SeriesModel.getBooksInSeries(req.params.id);
    res.status(200).json({
      success: true,
      data: books,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch books in series",
      error: error.message,
    });
  }
};
