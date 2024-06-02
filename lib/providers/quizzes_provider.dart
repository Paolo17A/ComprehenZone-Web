import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizzesNotifier extends ChangeNotifier {
  List<DocumentSnapshot> quizDocs = [];

  void setQuizDocs(List<DocumentSnapshot> quizzes) {
    quizDocs = quizzes;
    notifyListeners();
  }
}

final quizzesProvider =
    ChangeNotifierProvider<QuizzesNotifier>((ref) => QuizzesNotifier());
