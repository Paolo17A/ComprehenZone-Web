import 'package:flutter/material.dart';

class BoolChoicesRadioWidget extends StatefulWidget {
  final bool? initialBool;
  final void Function(bool?) choiceSelectCallback;

  const BoolChoicesRadioWidget(
      {super.key,
      required this.initialBool,
      required this.choiceSelectCallback});

  @override
  State<BoolChoicesRadioWidget> createState() => BoolChoicesRadioWidgetState();
}

class BoolChoicesRadioWidgetState extends State<BoolChoicesRadioWidget> {
  bool? _choice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _choice = widget.initialBool;
    });
  }

  void resetChoice() {
    setState(() {
      _choice = null;
    });
  }

  void setChoice(bool choice) {
    setState(() {
      _choice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _choice,
                  onChanged: (bool? value) {
                    setState(() {
                      _choice = value;
                      widget.choiceSelectCallback(_choice);
                    });
                  },
                  activeColor: Colors.black,
                ),
                const Text('TRUE', textAlign: TextAlign.center)
              ],
            ),
            Column(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _choice,
                  onChanged: (bool? value) {
                    setState(() {
                      _choice = value;
                      widget.choiceSelectCallback(_choice);
                    });
                  },
                  activeColor: Colors.black,
                ),
                const Text('FALSE', textAlign: TextAlign.center)
              ],
            )
          ]),
    );
  }
}
