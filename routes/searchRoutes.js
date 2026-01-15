const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const { checkOllamaStatus } = require("../services/fileProcessingService");
const { searchByTags } = require("../services/aiSearchService");
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

/**
 * @desc    Search by tags - البحث عن طريق التاغ
 * @route   POST /api/v1/search/tags
 * @access  Private
 */
router.post(
  "/tags",
  protect,
  async (req, res) => {
    const userId = req.user._id;
    const { tag, limit = 20 } = req.body;

    if (!tag || tag.trim().length === 0) {
      return res.status(400).json({
        message: "Tag is required",
      });
    }

    try {
      const results = await searchByTags(userId, tag.trim(), {
        limit: parseInt(limit, 10),
      });

      res.status(200).json({
        message: "Tag search completed successfully",
        tag,
        resultsCount: results.length,
        results: results.map((r) => ({
          type: r.type,
          _id: r.item._id,
          name: r.item.name,
          category: r.item.category || null,
          size: r.item.size || 0,
          tags: r.item.tags || [],
          description: r.item.description || "",
          relevanceScore: Math.round(r.score * 100) / 100,
          searchType: r.searchType,
          createdAt: r.item.createdAt,
          updatedAt: r.item.updatedAt,
        })),
      });
    } catch (error) {
      console.error("Error in tag search:", error);
      res.status(500).json({
        message: "Error searching by tags",
        error: error.message,
      });
    }
  }
);

module.exports = router;

