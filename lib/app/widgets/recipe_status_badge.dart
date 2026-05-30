import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeStatusBadge extends StatelessWidget {
  final String status;

  const RecipeStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    String text;

    if (status == 'pending') {
      bgColor = Colors.orange.shade500;
      icon = Icons.hourglass_empty;
      text = 'Menunggu Approval';
    } else if (status == 'rejected') {
      bgColor = Colors.red.shade500;
      icon = Icons.close;
      text = 'Ditolak Admin';
    } else if (status == 'approved') {
      bgColor = Colors.green.shade500;
      icon = Icons.check;
      text = 'Disetujui';
    } else if (status == 'revision') {
      bgColor = Colors.blue.shade500;
      icon = Icons.edit_note;
      text = 'Dalam Revisi';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
