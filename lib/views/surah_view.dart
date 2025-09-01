import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tilawah_app/core/utils/app_colors.dart';

class SurahView extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahView({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahView> createState() => _SurahViewState();
}

class _SurahViewState extends State<SurahView> {
  List<dynamic> ayahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSurah();
  }

  Future<void> fetchSurah() async {
    final url = Uri.parse(
      "https://api.alquran.cloud/v1/surah/${widget.surahNumber}/quran-uthmani",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ayahs = data["data"]["ayahs"];
        isLoading = false;
      });
    } else {
      throw Exception("فشل في جلب السورة");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFFFF1D6),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 251, 236, 205),
          title: Text(widget.surahName, style: TextStyle(color: AppColors.primaryColor)),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF8E7), Color(0xFFFFF1D6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text.rich(
                    TextSpan(
                      children: ayahs.map((ayah) {
                        bool isBasmala = ayah["text"].contains(
                          "",
                        );

                        return TextSpan(
                          children: [
                            TextSpan(
                              text: ayah["text"] + " ",
                              style: TextStyle(
                                fontSize: 26,
                                
                                height: 2,
                                fontFamily: 'UthmanicHafs1',
                                color: isBasmala
                                    ? Colors.green.shade700
                                    : Colors.black,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.brown,
                                    width: 1.5,
                                  ),
                                  color: Colors.amber.shade100,
                                ),
                                child: Text(
                                  "${ayah["numberInSurah"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
    );
  }
}
