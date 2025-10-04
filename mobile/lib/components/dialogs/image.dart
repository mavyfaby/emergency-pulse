import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:widget_zoom/widget_zoom.dart';

class DialogImage extends StatelessWidget {
  final String imageUrl;

  const DialogImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("View Image"),
      content: WidgetZoom(
        heroAnimationTag: 'tag',
        zoomWidget: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
