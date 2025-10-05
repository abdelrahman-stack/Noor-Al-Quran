import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tilawah_app/core/utils/app_colors.dart';

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  final TextEditingController _cityController = TextEditingController(
    text: "Cairo",
  );
  final TextEditingController _countryController = TextEditingController(
    text: "Egypt",
  );
  Map<String, dynamic>? prayerTimes;
  bool isLoading = false;

  Future<void> fetchPrayerTimes() async {
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    if (city.isEmpty) return;

    setState(() => isLoading = true);

    final url =
        "https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=5";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          prayerTimes = data["data"]["timings"];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("لم يتم العثور على المدينة")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء جلب البيانات")));
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🕌 مواقيت الصلاة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPrayerTimes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "اسم المدينة ",
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: "اسم الدولة ",
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: fetchPrayerTimes,
              icon: const Icon(Icons.search, color: Colors.white, size: 24),
              label: const Text(
                "عرض المواقيت",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🕰 عرض المواقيت
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : prayerTimes == null
                  ? const Center(child: Text("أدخل اسم المدينة لعرض المواقيت"))
                  : ListView(
                      children: prayerTimes!.entries.map((e) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              e.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            trailing: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
