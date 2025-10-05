import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tilawah_app/core/utils/app_colors.dart';
import 'package:tilawah_app/widgets/mushaf_view_body.dart';

class MushafView extends StatelessWidget {
  const MushafView({super.key});
  static const routeName = 'suraView';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              ' المصحف الشريف',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor:  Colors.green,
              child: Text(
                'لا تنسونا من دعائكم',
                style: TextStyle(color: Colors.white),
              ),
            ),
            
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 10,
      ),
      body: SurahListScreen(),
    );
  }
}
