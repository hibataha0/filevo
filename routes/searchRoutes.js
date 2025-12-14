const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const { checkOllamaStatus } = require("../services/fileProcessingService");
const File = require("../models/fileModel");

/**
 * @route   GET /api/v1/search/ollama-status
 * @desc    التحقق من حالة Ollama
 * @access  Private
 */
router.get("/ollama-status", protect, async (req, res) => {
  try {
    const status = await checkOllamaStatus();
    res.status(200).json({
      success: true,
      ollama: status,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error checking Ollama status",
      error: error.message,
    });
  }
});

module.exports = router;

