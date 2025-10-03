import 'dart:io';

import 'package:emergency_pulse/controllers/info.controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DialogInfo extends StatefulWidget {
  final bool isUpdate;

  const DialogInfo({super.key, this.isUpdate = false});

  @override
  State<DialogInfo> createState() => _DialogInfoState();
}

class _DialogInfoState extends State<DialogInfo> {
  final Rx<File?> _imageFile = Rx<File?>(null);

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _imageFile.value = File(pickedFile.path);
    }
  }

  @override
  void initState() {
    super.initState();
    Get.find<InfoController>().load();
    Get.find<InfoController>().checkLocationPermission();
  }

  @override
  void dispose() {
    _imageFile.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final infoCtrl = Get.find<InfoController>();
    final addressCtrl = TextEditingController(text: infoCtrl.address.value);
    final nameCtrl = TextEditingController(text: infoCtrl.name.value);
    final contactNoCtrl = TextEditingController(text: infoCtrl.contactNo.value);

    return AlertDialog(
      title: widget.isUpdate
          ? const Text('Update Information')
          : const Text('Add Information'),
      content: SingleChildScrollView(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Name',
                  icon: Icon(Icons.person_outline),
                  hintText: 'Enter your name',
                ),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Full Address',
                  icon: Icon(Icons.location_on_outlined),
                  hintText: 'Enter your full address',
                ),
              ),
              TextField(
                controller: contactNoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Contact Number',
                  icon: Icon(Icons.phone_outlined),
                  hintText: 'Enter your contact number',
                ),
              ),

              if (_imageFile.value != null || infoCtrl.picture.value.isNotEmpty)
                Image.memory(
                  _imageFile.value?.readAsBytesSync() ?? infoCtrl.picture.value,
                  height: 200,
                  fit: BoxFit.cover,
                ),

              Flex(
                direction: Axis.horizontal,
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text("Select Image"),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt_outlined),
                    label: Text("Take Photo"),
                  ),
                ],
              ),
              Text(
                "Optional: Select or take a picture of your place or surroundings so that rescuers and emergency services can precisely locate you.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await infoCtrl.save(
              nameCtrl.text,
              addressCtrl.text,
              contactNoCtrl.text,
              _imageFile.value,
            );

            infoCtrl.load();
            Get.back();
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
          ),
          child: const Text('Save Information'),
        ),
      ],
    );
  }
}
