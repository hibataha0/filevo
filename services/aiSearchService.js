const File = require("../models/fileModel");
const Folder = require("../models/folderModel");

/**
 * البحث عن طريق التاغ (Tags) - للملفات والمجلدات
 */
async function searchByTags(userId, tagQuery, options = {}) {
  const { limit = 20 } = options;

  try {
    // البحث في tags - يمكن أن يكون tag واحد أو عدة tags
    // إذا كان tagQuery عبارة عن نص، نبحث عنه في جميع tags
    // إذا كان array، نبحث عن أي tag يطابق
    const tagSearchRegex = new RegExp(
      tagQuery.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
      "i"
    );

    // البحث في ملفات
    const files = await File.find({
      userId,
      isDeleted: false,
      tags: { $in: [tagSearchRegex] },
    })
      .limit(limit)
      .lean();

    // البحث في مجلدات
    const folders = await Folder.find({
      userId,
      isDeleted: false,
      tags: { $in: [tagSearchRegex] },
    })
      .limit(limit)
      .lean();

    // دمج النتائج
    const results = [
      ...files.map((file) => ({
        type: "file",
        item: file,
        score: 0.95, // score عالي لأن البحث في tags دقيق
        searchType: "tags",
      })),
      ...folders.map((folder) => ({
        type: "folder",
        item: folder,
        score: 0.95, // score عالي لأن البحث في tags دقيق
        searchType: "tags",
      })),
    ];

    // ترتيب حسب score (من الأعلى للأقل)
    results.sort((a, b) => b.score - a.score);

    return results.slice(0, limit);
  } catch (error) {
    console.error("Error searching by tags:", error);
    throw error;
  }
}

module.exports = {
  searchByTags,
};
