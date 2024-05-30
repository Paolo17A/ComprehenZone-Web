import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SectionsNotifier extends ChangeNotifier {
  List<DocumentSnapshot> sectionDocs = [];

//  SELECTED SECTION VARIABLES
  String assignedTeacherName = '';
  List<DocumentSnapshot> availableTeacherDocs = [];
  List<DocumentSnapshot> sectionStudentDocs = [];
  List<DocumentSnapshot> studentsWithNoSectionDocs = [];

  void setSectionDocs(List<DocumentSnapshot> sections) {
    sectionDocs = sections;
    notifyListeners();
  }

  void setAssignedTeacherName(String name) {
    assignedTeacherName = name;
    notifyListeners();
  }

  void setAvailableTeacherDocs(List<DocumentSnapshot> teachers) {
    availableTeacherDocs = teachers;
    notifyListeners();
  }

  void setSectionStudentDocs(List<DocumentSnapshot> students) {
    sectionStudentDocs = students;
    notifyListeners();
  }

  void setStudentsWithNoSectionDocs(List<DocumentSnapshot> students) {
    studentsWithNoSectionDocs = students;
    notifyListeners();
  }
}

final sectionsProvider =
    ChangeNotifierProvider<SectionsNotifier>((ref) => SectionsNotifier());
