import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModulesNotifier extends ChangeNotifier {
  List<DocumentSnapshot> moduleDocs = [];

  void setModuleDocs(List<DocumentSnapshot> modules) {
    moduleDocs = modules;
    notifyListeners();
  }
}

final modulesProvider =
    ChangeNotifierProvider<ModulesNotifier>((ref) => ModulesNotifier());
