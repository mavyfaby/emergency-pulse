/// Sanitize a string by trimming and removing multiple spaces
String sanitize(String text) {
  // Trim
  text = text.trim();

  // Replace multiple spaces with a single space
  text = text.replaceAll(RegExp(r'\s+'), ' ');

  return text;
}
