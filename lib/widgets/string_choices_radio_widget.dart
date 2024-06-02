import 'package:flutter/material.dart';

import '../utils/color_util.dart';

class StringChoicesRadioWidget extends StatefulWidget {
  final String? initialString;
  final void Function(String?) choiceSelectCallback;
  final List<String> choiceLetters;

  const StringChoicesRadioWidget(
      {super.key,
      required this.initialString,
      required this.choiceSelectCallback,
      required this.choiceLetters});

  @override
  State<StringChoicesRadioWidget> createState() => ChoicesRadioWidgetState();
}

class ChoicesRadioWidgetState extends State<StringChoicesRadioWidget> {
  String? _choice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _choice = widget.initialString;
    });
  }

  void resetChoice() {
    setState(() {
      _choice = null;
    });
  }

  void setChoice(String choice) {
    setState(() {
      _choice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.choiceLetters.map((thisChoice) {
            return Row(children: [
              Text(
                thisChoice,
                textAlign: TextAlign.center,
              ),
              Radio<String>(
                value: thisChoice,
                groupValue: _choice,
                onChanged: (String? value) {
                  setState(() {
                    _choice = value;
                    widget.choiceSelectCallback(_choice);
                  });
                },
                activeColor: CustomColors.midnightBlue,
              )
            ]);
          }).toList()),
    );
  }
}
