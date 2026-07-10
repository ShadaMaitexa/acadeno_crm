import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color
  static const Color primary = Color(0xFF3582CB);

  // Background color
  static const Color background = Color(0xFFE8F1F8);

  // Tag colors (Hot leads, Follow ups, Reminders)
  static const Color hotLeads = Color(0xFFD67D3E);
  static const Color followUps = Color(0xFF1E9E90);
  static const Color reminders = Color(0xFF7E5C54);

  // Call status type colors
  // Outgoing
  static const Color callOutgoingBg = Color(0xFFE8F1F8);
  static const Color callOutgoingIcon = Color(0xFF3582CB);

  // Answered
  static const Color callAnsweredBg = Color(0xFFE8F8F0);
  static const Color callAnsweredIcon = Color(0xFF2E7D32);

  // Missed
  static const Color callMissedBg = Color(0xFFFDE8E8);
  static const Color callMissedIcon = Color(0xFFC62828);

  // Banners and Info containers
  static const Color infoBannerBg = Color(0xFFE3F2FD);
}
