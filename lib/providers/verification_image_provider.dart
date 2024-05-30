import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker_web/image_picker_web.dart';

class VerificationImageNotifier extends ChangeNotifier {
  Uint8List? verificationImage;

  Future setVerificationImage() async {
    final selectedXFile = await ImagePickerWeb.getImageAsBytes();
    if (selectedXFile == null) {
      return;
    }
    verificationImage = selectedXFile;
    notifyListeners();
  }

  void resetVerificationImage() {
    verificationImage = null;
    notifyListeners();
  }
}

final verificationImageProvider =
    ChangeNotifierProvider<VerificationImageNotifier>(
        (ref) => VerificationImageNotifier());
