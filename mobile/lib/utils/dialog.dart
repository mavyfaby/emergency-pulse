import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackBarType { success, error, warning, info }

/// Show an alert dialog
Future<void> showAlertDialog(
  String title,
  String message, {
  dismissible = false,
  cancelLabel = "Cancel",
  cancelAction,
  confirmLabel = "OK",
  confirmAction,
}) async {
  await Get.dialog(
    AlertDialog(
      // title: Text(title, style: Get.textTheme.headlineSmall!.copyWith(
      //   letterSpacing: 0,
      //   fontFamily: "Poppins",
      //   color: Get.theme.colorScheme.onSurface,
      //   fontWeight: FontWeight.w500
      // )),
      title: Text(title),
      content: Text(
        message,
        style: Get.textTheme.bodyMedium!.copyWith(letterSpacing: 0),
      ),
      actions: [
        if (cancelAction != null)
          TextButton(
            onPressed: () {
              Get.back();
              if (cancelAction != null) {
                cancelAction();
              }
            },
            child: Text(cancelLabel),
          ),
        if (confirmAction != null)
          TextButton(
            onPressed: () {
              Get.back();
              if (confirmAction != null) {
                confirmAction();
              }
            },
            child: Text(confirmLabel),
          ),
        if (cancelAction == null && confirmAction == null)
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("OK"),
          ),
      ],
    ),
    barrierDismissible: dismissible,
  );
}

/// Show a dialog with a loading indicator
Future<void> showLoadingDialog(String message) async {
  await Get.dialog(
    AlertDialog(
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    ),
  );
}

/// Show a snackbar
void showSnackbar(
  String message, {
  String? actionLabel,
  Function? action,
  int? seconds,
  SnackBarType type = SnackBarType.info,
}) {
  if (Get.context == null) return;

  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Get.theme.colorScheme.primary;
      break;
    case SnackBarType.error:
      backgroundColor = Get.theme.colorScheme.error;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange;
      break;
    case SnackBarType.info:
      backgroundColor = Get.theme.colorScheme.onSurface;
      break;
  }

  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      duration: Duration(seconds: seconds ?? 3),
      action: actionLabel != null && action != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: () {
                action();
              },
            )
          : null,
    ),
  );
}
