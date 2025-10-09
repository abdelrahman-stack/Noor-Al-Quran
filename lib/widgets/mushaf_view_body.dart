import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  // البحث عن كلمة
  void searchInQuran(String query) {
    if (query.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final results = Map<String, dynamic>.from(searchWords(query));

    setState(() {
      searchResults = List<Map<String, dynamic>>.from(
        results["result"].map((e) => Map<String, dynamic>.from(e)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> surahNames = List.generate(
      totalSurahCount,
      (index) => getSurahNameArabic(index + 1),
    );

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "ابحث في القرآن...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchResults = [];
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: searchInQuran,
            ),
          ),
          SizedBox(height: 20),

          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final surah = searchResults[index]["suraNumber"];
                  final verse = searchResults[index]["verseNumber"];
                  return ListTile(
                    title: QcfVerse(
                      surahNumber: surah,
                      verseNumber: verse,
                      fontSize: 20,
                      textColor: Colors.green.shade800,
                    ),
                    subtitle: Text(
                      "سورة ${getSurahNameArabic(surah)} - آية $verse",
                      textAlign: TextAlign.right,
                    ),
                    onTap: () {
                      final page = getPageNumber(surah, verse);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SurahView(surahIndex: surah, initialPage: page),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: totalSurahCount,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        surahNames[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        final firstPage = getPageNumber(index + 1, 1);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahView(
                              surahIndex: index + 1,
                              initialPage: firstPage,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class SurahView extends StatefulWidget {
  final int surahIndex;
  final int initialPage;

  const SurahView({
    super.key,
    required this.surahIndex,
    required this.initialPage,
  });

  @override
  State<SurahView> createState() => _SurahViewState();
}

class _SurahViewState extends State<SurahView> {
  late int currentPage;
  late String currentSurah;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt("lastPage");
    final savedSurah = prefs.getInt("lastSurah");

    if (savedPage != null && savedSurah != null) {
      setState(() {
        currentPage = savedPage;
        currentSurah = getSurahNameArabic(savedSurah);
        isLoading = false;
      });
    } else {
      setState(() {
        currentPage = widget.initialPage;
        currentSurah = getSurahNameArabic(widget.surahIndex);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: PageviewQuran(
            initialPageNumber: currentPage,
            textColor: Colors.black,
            pageBackgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
