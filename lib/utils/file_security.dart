import 'dart:io';
import 'dart:convert';

/// 🔐 Dangerous file extensions that should be blocked or converted to text
const List<String> DANGEROUS_EXTENSIONS = [
  '.exe',  // Windows executable
  '.sh',   // Shell script
  '.bat',  // Batch file
  '.cmd',  // Command file
  '.msi',  // Windows installer
  '.bin',  // Binary file
  '.scr',  // Screen saver (can be executable)
];

/// 🔐 Check if a file has a dangerous extension
bool isDangerousExtension(String fileName) {
  if (fileName.isEmpty) return false;
  
  final extension = fileName.toLowerCase();
  for (var dangerousExt in DANGEROUS_EXTENSIONS) {
    if (extension.endsWith(dangerousExt.toLowerCase())) {
      return true;
    }
  }
  return false;
}

/// 🔐 Convert dangerous file extension to .txt
String convertToSafeTextFile(String fileName) {
  if (fileName.isEmpty) return 'file.txt';
  
  // Find the last dot
  final lastDotIndex = fileName.lastIndexOf('.');
  if (lastDotIndex == -1) {
    return '$fileName.txt';
  }
  
  // Replace extension with .txt
  final nameWithoutExt = fileName.substring(0, lastDotIndex);
  return '$nameWithoutExt.txt';
}

/// 🔐 Convert dangerous file to safe text file
/// This reads the binary file and converts it to a hex string representation
Future<File> convertDangerousFileToText({
  required File originalFile,
  required String originalFileName,
}) async {
  try {
    // Read binary content
    final bytes = await originalFile.readAsBytes();
    
    // Convert to hex string
    final hexContent = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    
    // Get original extension
    final originalExt = originalFileName.contains('.')
        ? originalFileName.substring(originalFileName.lastIndexOf('.'))
        : '';
    
    // Create safe text content
    final safeContent = '''⚠️ SECURITY: This file was converted from $originalExt to text format for safety.

Original filename: $originalFileName
File size: ${bytes.length} bytes
Original extension: $originalExt

Hex representation:
$hexContent''';
    
    // Write safe content to file
    await originalFile.writeAsString(safeContent, encoding: utf8);
    
    return originalFile;
  } catch (e) {
    throw Exception('Error converting dangerous file to text: $e');
  }
}

/// 🔐 Get list of dangerous files from a list of file names
List<String> getDangerousFiles(List<String> fileNames) {
  return fileNames.where((fileName) => isDangerousExtension(fileName)).toList();
}

/// 🔐 Check if any file in a list has dangerous extension
bool hasDangerousFiles(List<String> fileNames) {
  return fileNames.any((fileName) => isDangerousExtension(fileName));
}




