import 'package:flutter/material.dart';
import 'package:tilawah_app/generated/l10n.dart';

class BuildSearchRow extends StatefulWidget {
  const BuildSearchRow({super.key});

  @override
  State<BuildSearchRow> createState() => _BuildSearchRowState();
}

bool _isSearching = false;
String? searchArabicInput = "";
final TextEditingController _searchTextEditingController =
    TextEditingController();

class _BuildSearchRowState extends State<BuildSearchRow> {
  @override
  void _clearSearch() {
    _searchTextEditingController.clear();
  }

  void addTypingLetters(String newSearchedValue) {
    setState(() {
      searchArabicInput = newSearchedValue;
    });
  }

  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Row(
        children: <Widget>[
          if (_isSearching)
            SizedBox(
              width: 50,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _clearSearch();
                  });
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.clear, color: Colors.white),
              ),
            ),
          _isSearching
              ? Expanded(
                  child: SizedBox(
                    height: 40,
                    width: 200,
                    child: Directionality(
                      textDirection:
                          Localizations.localeOf(context).languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: TextField(
                        cursorWidth: 1.0,
                        textDirection: TextDirection.rtl,
                        cursorColor: Colors.black,
                        autofocus: true,
                        controller: _searchTextEditingController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            bottom: 5,
                            right: 15,
                          ),
                          hintText: S.of(context).search,
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 202, 200, 200),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onChanged: (searchedValue) {
                          setState(() {});
                          addTypingLetters(searchedValue);
                        },
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(width: 20),
        ],
      ),
    );
    ;
  }
}
