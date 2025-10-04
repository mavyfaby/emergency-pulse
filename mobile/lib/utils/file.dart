import 'dart:typed_data';

String getImageExtension(Uint8List bytes) {
  if (bytes.length < 12) return 'unknown';

  // JPEG
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return 'jpg';
  }

  // PNG
  if (bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'png';
  }

  // GIF
  if (bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38) {
    return 'gif';
  }

  // WEBP (RIFF....WEBP)
  if (bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'webp';
  }

  // BMP
  if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
    return 'bmp';
  }

  return 'unknown';
}
