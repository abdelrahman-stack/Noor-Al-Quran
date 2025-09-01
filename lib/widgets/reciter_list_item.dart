
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tilawah_app/core/utils/app_colors.dart';
import 'package:tilawah_app/model/local_reciter.dart';

class ReciterListItem extends StatelessWidget {
  final Reciter reciter;
  final Moshaf moshaf;
  final Function(Reciter, Moshaf) onReciterTap;
  final bool isArabic;
  final bool isFavorite;
  final Function(Reciter, Moshaf) onFavoriteToggle;

  const ReciterListItem({
    super.key,
    required this.reciter,
    required this.moshaf,
    required this.onReciterTap,
    required this.isArabic,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListTile(
        key: ValueKey('${reciter.id}-${moshaf.id}'),
        title: Text(
          reciter.name ?? '',
          style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          moshaf.name ?? '',
          style: GoogleFonts.tajawal(fontSize: 12),
        ),
        onTap: () => onReciterTap(reciter, moshaf),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : AppColors.primaryColor,
            size: 16,
          ),
          onPressed: () => onFavoriteToggle(reciter, moshaf),
        ),
      ),
    );
  }
}
