import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserTypeProvider extends ChangeNotifier {
  String userType = '';

  void setUserType(String user) {
    userType = user;
    notifyListeners();
  }
}

final userTypeProvider = ChangeNotifierProvider((ref) => UserTypeProvider());
