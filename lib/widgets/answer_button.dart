import 'package:flutter/material.dart';

import '../utils/color_util.dart';
import 'custom_text_widgets.dart';

class AnswerButton extends StatefulWidget {
  final String letter;
  final String answer;
  final void Function() onTap;
  final bool isSelected;
  const AnswerButton(
      {required this.letter,
      required this.answer,
      required this.onTap,
      required this.isSelected,
      super.key});

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            widget.isSelected ? CustomColors.midnightBlue : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.65,
          height: 50,
          child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  foregroundColor: Colors.white,
                  backgroundColor: CustomColors.midnightBlue),
              child: interText(widget.answer,
                  textAlign: TextAlign.center, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
