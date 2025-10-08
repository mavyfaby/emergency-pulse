import 'package:emergency_pulse/controllers/info.controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogInfo extends StatefulWidget {
  final bool isUpdate;

  const DialogInfo({super.key, this.isUpdate = false});

  @override
  State<DialogInfo> createState() => _DialogInfoState();
}

class _DialogInfoState extends State<DialogInfo> {
  @override
  void initState() {
    super.initState();
    Get.find<InfoController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final infoCtrl = Get.find<InfoController>();
    final addressCtrl = TextEditingController(text: infoCtrl.address.value);
    final nameCtrl = TextEditingController(text: infoCtrl.name.value);
    final contactNoCtrl = TextEditingController(text: infoCtrl.contactNo.value);
    final notesCtrl = TextEditingController(text: infoCtrl.notes.value);

    return AlertDialog(
      title: widget.isUpdate
          ? const Text('Update Information')
          : const Text('Add Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Name',
                icon: Icon(Icons.person_outline),
                hintText: 'Enter your name',
              ),
            ),
            TextField(
              controller: addressCtrl,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Full Address',
                icon: Icon(Icons.location_on_outlined),
                hintText: 'Enter your full address',
              ),
            ),
            TextField(
              controller: contactNoCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Contact Number',
                icon: Icon(Icons.phone_outlined),
                hintText: 'Enter your contact number',
              ),
            ),
            TextField(
              controller: notesCtrl,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Additional Message',
                icon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            nameCtrl.clear();
            addressCtrl.clear();
            contactNoCtrl.clear();
            notesCtrl.clear();
          },
          child: Text("Clear"),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await infoCtrl.checkLocationPermission();
                await infoCtrl.save(
                  nameCtrl.text,
                  addressCtrl.text,
                  contactNoCtrl.text,
                  notesCtrl.text,
                );

                infoCtrl.load();
                Get.back();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 22,
                ),
              ),
              icon: const Icon(Icons.save_outlined),
              label: Text(
                'Save',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
