import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

Widget dropdownWidget(
    String selectedOption,
    Function(String?) onDropdownValueChanged,
    List<String> dropdownItems,
    String label,
    bool searchable) {
  return DropdownSearch<String>(
    dropdownButtonProps: const DropdownButtonProps(color: Colors.black),
    dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            labelStyle: TextStyle(color: Colors.black)),
        baseStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    popupProps: PopupProps.menu(
      fit: FlexFit.loose,
      showSelectedItems: false,
      showSearchBox: searchable,
      menuProps: MenuProps(
          backgroundColor: Colors.white,
          borderRadius: BorderRadius.circular(10)),
    ),
    items: dropdownItems,
    onChanged: onDropdownValueChanged,
    selectedItem: label,
  );
}

Widget userDocumentSnapshotDropdownWidget(
  BuildContext context,
  String selectedOption,
  Function(String?) onDropdownValueChanged,
  List<DocumentSnapshot> dropdownDocuments,
) {
  return DropdownButton<String>(
    value: selectedOption,
    items: dropdownDocuments.map((doc) {
      final docData = doc.data() as Map<dynamic, dynamic>;
      String formattedName = '${docData['firstName']} ${docData['lastName']}';
      return DropdownMenuItem<String>(
          value: doc.id, child: blackInterRegular(formattedName, fontSize: 12));
    }).toList(),
    onChanged: onDropdownValueChanged,
  );
}

Widget sectionDocumentSnapshotDropdownWidget(
  String selectedOption,
  Function(String?) onDropdownValueChanged,
  List<DocumentSnapshot> dropdownDocuments,
) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
        border: Border.all(), borderRadius: BorderRadius.circular(10)),
    child: DropdownButton<String>(
      isExpanded: true,
      value: selectedOption,
      items: dropdownDocuments.map((doc) {
        final docData = doc.data() as Map<dynamic, dynamic>;
        String sectionName = docData[SectionFields.name];
        return DropdownMenuItem<String>(
            value: doc.id,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: interText(sectionName),
              ),
            ));
      }).toList(),
      onChanged: onDropdownValueChanged,
    ),
  );
}
