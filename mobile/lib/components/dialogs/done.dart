import 'dart:io';

import 'package:emergency_pulse/controllers/location.controller.dart';
import 'package:emergency_pulse/model/alert.dart';
import 'package:emergency_pulse/network/request.dart';
import 'package:emergency_pulse/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class DialogDone extends StatefulWidget {
  final AlertModel alert;

  const DialogDone({super.key, required this.alert});

  @override
  State<DialogDone> createState() => _DialogDoneState();
}

class _DialogDoneState extends State<DialogDone> {
  final Rx<File?> _imageFile = Rx<File?>(null);
  final TextEditingController _remarksController = TextEditingController();
  final locationCtrl = Get.find<LocationController>();
  final isCompleting = false.obs;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _imageFile.value = File(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Completion"),
      content: SingleChildScrollView(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile.value != null)
                Image.memory(
                  _imageFile.value!.readAsBytesSync(),
                  height: 200,
                  fit: BoxFit.cover,
                ),

              if (_imageFile.value != null) SizedBox(height: 16),

              Obx(
                () => Flex(
                  direction: Axis.horizontal,
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isCompleting.value
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text("Select Image"),
                    ),
                    OutlinedButton.icon(
                      onPressed: isCompleting.value
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt_outlined),
                      label: Text("Take Photo"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              Text(
                "Note: Before marking this emergency as resolved, please take or upload a photo as proof of assistance. This helps verify and document the response.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),

              SizedBox(height: 16),

              Obx(
                () => TextField(
                  controller: _remarksController,
                  minLines: 2,
                  maxLines: 3,
                  enabled: !isCompleting.value,
                  canRequestFocus: true,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Remarks (optional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                    hintText: 'Enter your remarks',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Obx(
          () => TextButton(
            onPressed: isCompleting.value ? null : () => Navigator.pop(context),
            child: const Text("No, Cancel"),
          ),
        ),
        Obx(
          () => FilledButton(
            onPressed: _imageFile.value != null && !isCompleting.value
                ? () async {
                    isCompleting.value = true;

                    final result = await markAsDone(
                      widget.alert.hashId,
                      _remarksController.text.trim(),
                      await _imageFile.value!.readAsBytes(),
                    );

                    isCompleting.value = false;

                    if (result) {
                      await showAlertDialog(
                        "Success",
                        "Alert marked as done successfully!",
                      );

                      Get.back();
                      Get.back();
                      locationCtrl.refreshKey.currentState?.show();

                      return;
                    }

                    showAlertDialog(
                      "Uh oh!",
                      "Something went wrong. Please try again or contact support.",
                    );
                  }
                : null,
            child: Text(
              isCompleting.value ? "Marking..." : "Yes, Mark as done",
            ),
          ),
        ),
      ],
    );
  }
}
