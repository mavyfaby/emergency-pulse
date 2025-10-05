import 'package:emergency_pulse/controllers/settings.controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogAbout extends StatelessWidget {
  const DialogAbout({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return AlertDialog(
      title: Text("About"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse("https://mavyfaby.com/apps/pulse"));
            },
            child: Text(
              "Pulse",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text("Version ${settingsCtrl.packageInfo?.version}"),

          const SizedBox(height: 16),

          SelectableText(
            "Pulse is your one-tap emergency app. Send alerts instantly to anyone using the app, track users in need on the built-in map, and rest assured—alerts go through even if your phone has no mobile load, as long as mobile data is on. Built with high-availability technology to ensure your alerts always get delivered. Quick, simple, and lifesaving!",
          ),

          const SizedBox(height: 16),

          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(text: "Developed by"),
                const WidgetSpan(child: SizedBox(width: 4)),
                TextSpan(
                  text: "Maverick Fabroa",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse("https://mavyfaby.com"));
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            spacing: 8,
            children: [
              Icon(
                Icons.email_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              SelectableText("maverickfabroa@gmail.com"),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            spacing: 8,
            children: [
              Icon(
                Icons.link_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              SelectableText("https://mavyfaby.com/apps/pulse"),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
