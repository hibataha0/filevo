/// ✅ أدوات للتحقق من نوع الملف
class FileTypeUtils {
  /// ✅ التحقق من أن الملف يفتح داخل التطبيق
  /// الملفات التي تفتح داخل التطبيق:
  /// - PDF
  /// - الصور (jpg, jpeg, png, gif, bmp, webp)
  /// - الفيديو (mp4, mov, mkv, avi, wmv)
  /// - الصوت (mp3, wav, aac, ogg, m4a, wma, flac)
  /// - النصوص (txt, json, xml, csv, html, css, js, dart, py, java, cpp, c, h, php, rb, go, rs, swift, kotlin, sh, md, yaml, yml, etc.)
  static bool opensInsideApp(String fileName) {
    if (fileName.isEmpty) {
      print('⚠️ [FileTypeUtils] fileName is empty');
      return false;
    }

    // ✅ تنظيف اسم الملف وإزالة المسافات
    final name = fileName.trim().toLowerCase();

    if (name.isEmpty) {
      print('⚠️ [FileTypeUtils] fileName is empty after trim');
      return false;
    }

    print('🔍 [FileTypeUtils] Checking file: $name');

    // ✅ PDF
    if (name.endsWith('.pdf')) {
      print('✅ [FileTypeUtils] PDF file detected');
      return true;
    }

    // ✅ الصور
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.svg',
      '.ico',
    ];
    for (final ext in imageExtensions) {
      if (name.endsWith(ext)) {
        print('✅ [FileTypeUtils] Image file detected: $ext');
        return true;
      }
    }

    // ✅ الفيديو
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.mkv',
      '.avi',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
      '.3gp',
    ];
    for (final ext in videoExtensions) {
      if (name.endsWith(ext)) {
        print('✅ [FileTypeUtils] Video file detected: $ext');
        return true;
      }
    }

    // ✅ الصوت
    final audioExtensions = [
      '.mp3',
      '.wav',
      '.aac',
      '.ogg',
      '.m4a',
      '.wma',
      '.flac',
      '.opus',
      '.amr',
    ];
    for (final ext in audioExtensions) {
      if (name.endsWith(ext)) {
        print('✅ [FileTypeUtils] Audio file detected: $ext');
        return true;
      }
    }

    // ✅ النصوص (استخدام نفس القائمة من TextViewerPage)
    final textExtensions = [
      'txt',
      'json',
      'xml',
      'csv',
      'html',
      'htm',
      'css',
      'js',
      'dart',
      'py',
      'java',
      'cpp',
      'c',
      'h',
      'php',
      'rb',
      'go',
      'rs',
      'swift',
      'kt',
      'sh',
      'bash',
      'zsh',
      'md',
      'markdown',
      'yaml',
      'yml',
      'ini',
      'conf',
      'config',
      'log',
      'sql',
      'ts',
      'tsx',
      'jsx',
      'vue',
      'svelte',
      'r',
      'm',
      'pl',
      'pm',
      'lua',
      'scala',
      'clj',
      'hs',
      'elm',
      'ex',
      'exs',
      'erl',
      'hrl',
      'ml',
      'mli',
      'fs',
      'fsx',
      'vb',
      'vbs',
      'asm',
      's',
      'lock',
      'toml',
      'env',
      'gitignore',
      'dockerfile',
      'makefile',
      'cmake',
    ];

    for (final ext in textExtensions) {
      if (name.endsWith('.$ext')) {
        print('✅ [FileTypeUtils] Text file detected: .$ext');
        return true;
      }
    }

    print('❌ [FileTypeUtils] File opens outside app: $name');
    return false;
  }

  /// ✅ التحقق من أن الملف يفتح خارج التطبيق
  /// الملفات التي تفتح خارج التطبيق:
  /// - Office files (docx, xlsx, pptx, doc, xls, ppt)
  /// - ملفات مضغوطة (zip, rar, 7z, tar, gz)
  /// - ملفات تنفيذية (apk, exe, dmg, pkg)
  /// - ملفات أخرى
  static bool opensOutsideApp(String fileName) {
    return !opensInsideApp(fileName);
  }

  /// ✅ التحقق من أن الملف يمكن مشاركته لمرة واحدة
  /// فقط الملفات التي تفتح داخل التطبيق يمكن مشاركتها لمرة واحدة
  /// ✅ الصور (jpg, jpeg, png, gif, bmp, webp) - تفتح داخل التطبيق ✅
  /// ✅ الفيديو (mp4, mov, mkv, avi, wmv) - تفتح داخل التطبيق ✅
  /// ✅ الصوت (mp3, wav, aac, ogg, m4a, wma, flac) - تفتح داخل التطبيق ✅
  /// ✅ PDF - يفتح داخل التطبيق ✅
  /// ✅ النصوص (txt, json, xml, csv, html, css, js, dart, py, etc.) - تفتح داخل التطبيق ✅
  static bool canBeOneTimeShared(String fileName) {
    return opensInsideApp(fileName);
  }
}
