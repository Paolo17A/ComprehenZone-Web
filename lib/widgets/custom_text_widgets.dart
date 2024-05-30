import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text interText(String label,
    {double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: overflow,
    style: GoogleFonts.inter(
        fontSize: fontSize, fontWeight: fontWeight, color: color),
  );
}

Text whiteInterRegular(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration}) {
  return Text(label,
      textAlign: textAlign,
      style: GoogleFonts.inter(
          fontSize: fontSize,
          color: Colors.white,
          decoration: textDecoration,
          decorationColor: Colors.white));
}

Text whiteInterBold(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration}) {
  return Text(label,
      textAlign: textAlign,
      style: GoogleFonts.inter(
          fontSize: fontSize,
          color: Colors.white,
          decoration: textDecoration,
          fontWeight: FontWeight.bold));
}

Text blackInterBold(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? overflow,
    TextDecoration? textDecoration}) {
  return Text(label,
      textAlign: textAlign,
      overflow: overflow,
      style: GoogleFonts.inter(
          fontSize: fontSize,
          color: Colors.black,
          decoration: textDecoration,
          fontWeight: FontWeight.bold));
}

Text blackInterRegular(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? overflow,
    TextDecoration? textDecoration}) {
  return Text(label,
      textAlign: textAlign,
      overflow: overflow,
      style: GoogleFonts.inter(
          fontSize: fontSize, color: Colors.black, decoration: textDecoration));
}
