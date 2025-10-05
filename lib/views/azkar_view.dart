import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:tilawah_app/core/utils/app_colors.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  List<dynamic> categories = [];
  bool isLoading = true;

  Future<void> fetchAzkar() async {
    try {
      const url =
          'https://raw.githubusercontent.com/Alsarmad/Adhkar-json/main/adhkar.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data;
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل البيانات');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("خطأ في تحميل الأذكار: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAzkar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "أذكار المسلم",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(child: Text("لا توجد أذكار حالياً"))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      category['category'],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_back_ios_new),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AzkarDetailsScreen(
                            categoryName: category['category'],
                            azkarList: category['array'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AzkarDetailsScreen extends StatelessWidget {
  final String categoryName;
  final List<dynamic> azkarList;

  const AzkarDetailsScreen({
    super.key,
    required this.categoryName,
    required this.azkarList,
  });

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();

    return Scaffold(
      appBar: AppBar(title: Text(categoryName), centerTitle: true),
      body: ListView.builder(
        itemCount: azkarList.length,
        itemBuilder: (context, index) {
          final item = azkarList[index];
          final text = item['text'] ?? '';
          final count = item['count'] ?? 1;
          final audioPath = item['audio'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "عدد التكرار: $count",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (audioPath != null && audioPath.toString().isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.green),
                      onPressed: () async {
                        final url =
                            "https://raw.githubusercontent.com/Alsarmad/Adhkar-json/main$audioPath";
                        await player.play(UrlSource(url));
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
