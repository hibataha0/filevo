const axios = require("axios");
const fs = require("fs");
const path = require("path");

// ✅ إعدادات Ollama
const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || "http://localhost:11434";
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || "llama3";

/**
 * ✅ التحقق من حالة Ollama
 */
async function checkOllamaStatus() {
  try {
    console.log("🔍 [FileProcessing] Checking Ollama status...");
    const response = await axios.get(`${OLLAMA_BASE_URL}/api/tags`, {
      timeout: 5000,
    });

    const models = response.data?.models || [];
    const hasModel = models.some(
      (m) => m.name === OLLAMA_MODEL || m.name.startsWith(OLLAMA_MODEL)
    );

    console.log(
      `✅ [FileProcessing] Ollama is running. Models: ${models
        .map((m) => m.name)
        .join(", ")}`
    );
    console.log(
      `✅ [FileProcessing] Required model (${OLLAMA_MODEL}) ${
        hasModel ? "is available" : "is NOT available"
      }`
    );

    return {
      isRunning: true,
      hasModel: hasModel,
      models: models.map((m) => m.name),
    };
  } catch (error) {
    console.error(
      "❌ [FileProcessing] Ollama is not running or not accessible:",
      error.message
    );
    return {
      isRunning: false,
      hasModel: false,
      error: error.message,
    };
  }
}

/**
 * ✅ استخراج النص من الملف
 */
async function extractTextFromFile(filePath, fileType) {
  try {
    console.log(`📝 [FileProcessing] Extracting text from file: ${filePath}`);
    console.log(`📝 [FileProcessing] File type: ${fileType}`);

    const ext = path.extname(filePath).toLowerCase();
    let text = "";

    // ✅ استخراج النص حسب نوع الملف
    if (ext === ".txt" || ext === ".md") {
      // ✅ ملفات نصية
      text = fs.readFileSync(filePath, "utf-8");
    } else if (ext === ".pdf") {
      // ✅ PDF - يحتاج مكتبة pdf-parse
      try {
        const pdfParse = require("pdf-parse");
        const dataBuffer = fs.readFileSync(filePath);
        const data = await pdfParse(dataBuffer);
        text = data.text;
      } catch (error) {
        console.warn(
          `⚠️ [FileProcessing] Could not extract text from PDF: ${error.message}`
        );
        text = ""; // ✅ إذا فشل استخراج النص، نستخدم اسم الملف فقط
      }
    } else if ([".doc", ".docx"].includes(ext)) {
      // ✅ Word documents - يحتاج مكتبة mammoth أو docx
      try {
        const mammoth = require("mammoth");
        const result = await mammoth.extractRawText({ path: filePath });
        text = result.value;
      } catch (error) {
        console.warn(
          `⚠️ [FileProcessing] Could not extract text from Word: ${error.message}`
        );
        text = "";
      }
    } else if (ext === ".xlsx" || ext === ".xls") {
      // ✅ Excel - يحتاج مكتبة xlsx
      try {
        const XLSX = require("xlsx");
        const workbook = XLSX.readFile(filePath);
        const sheetNames = workbook.SheetNames;
        text = sheetNames
          .map((name) => {
            const sheet = workbook.Sheets[name];
            return XLSX.utils.sheet_to_txt(sheet);
          })
          .join("\n");
      } catch (error) {
        console.warn(
          `⚠️ [FileProcessing] Could not extract text from Excel: ${error.message}`
        );
        text = "";
      }
    } else {
      // ✅ للملفات الأخرى (صور، فيديو، إلخ)، نستخدم اسم الملف فقط
      const fileName = path.basename(filePath, ext);
      text = fileName;
      console.log(`ℹ️ [FileProcessing] Using file name as text: ${fileName}`);
    }

    // ✅ تنظيف النص
    text = text.trim();

    console.log(
      `📝 [FileProcessing] Extracted text length: ${text.length} characters`
    );
    if (text.length > 0) {
      console.log(
        `📝 [FileProcessing] Text preview: ${text.substring(0, 100)}...`
      );
    } else {
      console.warn(`⚠️ [FileProcessing] No text extracted from file`);
    }

    return text;
  } catch (error) {
    console.error(
      `❌ [FileProcessing] Error extracting text: ${error.message}`
    );
    return "";
  }
}

/**
 * ✅ توليد embedding باستخدام Ollama
 */
async function generateEmbedding(text, fileName) {
  try {
    console.log(`🔄 [FileProcessing] Generating embedding for: ${fileName}`);
    console.log(`🔄 [FileProcessing] Text length: ${text.length} characters`);

    if (!text || text.trim().length === 0) {
      console.warn(`⚠️ [FileProcessing] Empty text, cannot generate embedding`);
      return null;
    }

    // ✅ التحقق من حالة Ollama أولاً
    const ollamaStatus = await checkOllamaStatus();
    if (!ollamaStatus.isRunning) {
      console.error(`❌ [FileProcessing] Ollama is not running`);
      return null;
    }

    if (!ollamaStatus.hasModel) {
      console.error(
        `❌ [FileProcessing] Required model (${OLLAMA_MODEL}) is not available`
      );
      console.error(
        `❌ [FileProcessing] Please run: ollama pull ${OLLAMA_MODEL}`
      );
      return null;
    }

    // ✅ استخدام Ollama API لتوليد embedding
    // ✅ ملاحظة: Ollama لا يدعم embeddings مباشرة، نحتاج استخدام generate ثم استخراج embedding
    // ✅ أو استخدام مكتبة مثل @langchain/ollama

    try {
      // ✅ محاولة استخدام Ollama embeddings endpoint (إن كان متاحاً)
      const response = await axios.post(
        `${OLLAMA_BASE_URL}/api/embeddings`,
        {
          model: OLLAMA_MODEL,
          prompt: text.substring(0, 2000), // ✅ تحديد طول النص
        },
        {
          timeout: 30000, // ✅ 30 ثانية timeout
        }
      );

      const embedding = response.data?.embedding;

      if (embedding && Array.isArray(embedding) && embedding.length > 0) {
        console.log(
          `✅ [FileProcessing] Generated embedding successfully (dimension: ${embedding.length})`
        );
        return embedding;
      } else {
        console.warn(
          `⚠️ [FileProcessing] Empty embedding returned from Ollama`
        );
        return null;
      }
    } catch (error) {
      console.error(
        `❌ [FileProcessing] Error generating embedding: ${error.message}`
      );
      console.error(
        `❌ [FileProcessing] Error details:`,
        error.response?.data || error.message
      );

      // ✅ إذا كان الخطأ بسبب عدم دعم embeddings endpoint، نحاول طريقة بديلة
      if (
        error.response?.status === 404 ||
        error.message.includes("not found")
      ) {
        console.warn(
          `⚠️ [FileProcessing] Ollama embeddings endpoint not available, trying alternative method...`
        );
        // ✅ يمكن استخدام generate ثم استخراج embedding من النتيجة
        // ✅ أو استخدام مكتبة أخرى
        return null;
      }

      return null;
    }
  } catch (error) {
    console.error(
      `❌ [FileProcessing] Unexpected error generating embedding: ${error.message}`
    );
    return null;
  }
}

/**
 * ✅ معالجة ملف تلقائياً بعد الرفع
 */
async function processFile(fileId, filePath, fileName, fileType) {
  try {
    console.log("═══════════════════════════════════════════════════════");
    console.log(`🔄 [FileProcessing] Processing file: ${fileName}`);
    console.log(`🔄 [FileProcessing] File ID: ${fileId}`);
    console.log(`🔄 [FileProcessing] File path: ${filePath}`);
    console.log(`🔄 [FileProcessing] File type: ${fileType}`);

    // ✅ 1. استخراج النص من الملف
    const text = await extractTextFromFile(filePath, fileType);

    if (!text || text.trim().length === 0) {
      console.warn(
        `⚠️ [FileProcessing] No text extracted, using file name only`
      );
      // ✅ إذا لم يتم استخراج نص، نستخدم اسم الملف فقط
      const fileNameWithoutExt = path.basename(
        fileName,
        path.extname(fileName)
      );
      const searchText = fileNameWithoutExt;

      // ✅ توليد embedding من اسم الملف
      const embedding = await generateEmbedding(searchText, fileName);

      return {
        success: embedding !== null,
        embedding: embedding,
        searchText: searchText,
        error:
          embedding === null
            ? "No text extracted and embedding generation failed"
            : null,
      };
    }

    // ✅ 2. إنشاء نص البحث (اسم الملف + محتوى الملف)
    const searchText = `${fileName}\n${text}`.substring(0, 2000); // ✅ تحديد طول النص
    console.log(
      `📝 [FileProcessing] Search text length: ${searchText.length} characters`
    );

    // ✅ 3. توليد embedding
    const embedding = await generateEmbedding(searchText, fileName);

    if (embedding === null) {
      console.error(`❌ [FileProcessing] Failed to generate embedding`);
      return {
        success: false,
        embedding: null,
        searchText: searchText,
        error: "Failed to generate embedding",
      };
    }

    console.log(`✅ [FileProcessing] File processed successfully`);
    console.log("═══════════════════════════════════════════════════════");

    return {
      success: true,
      embedding: embedding,
      searchText: searchText,
      error: null,
    };
  } catch (error) {
    console.error(
      `❌ [FileProcessing] Error processing file: ${error.message}`
    );
    console.error(`❌ [FileProcessing] Stack trace:`, error.stack);
    console.log("═══════════════════════════════════════════════════════");

    return {
      success: false,
      embedding: null,
      searchText: null,
      error: error.message,
    };
  }
}

module.exports = {
  processFile,
  checkOllamaStatus,
  extractTextFromFile,
  generateEmbedding,
};

