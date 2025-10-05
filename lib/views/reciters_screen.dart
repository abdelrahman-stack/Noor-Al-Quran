import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tilawah_app/bloc/bloc_local_Reciters/local_reciters_bloc.dart';
import 'package:tilawah_app/bloc/bloc_local_Reciters/local_reciters_event.dart';
import 'package:tilawah_app/bloc/bloc_local_Reciters/local_reciters_state.dart';
import 'package:tilawah_app/bloc/bloc_quran/quran_bloc.dart';
import 'package:tilawah_app/bloc/internet_bloc/internet_bloc.dart';
import 'package:tilawah_app/bloc/internet_bloc/internet_state.dart';
import 'package:tilawah_app/bloc/localization_bloc/localization_bloc.dart';
import 'package:tilawah_app/bloc/localization_bloc/localization_event.dart';
import 'package:tilawah_app/bloc/localization_bloc/localization_state.dart';
import 'package:tilawah_app/core/utils/app_colors.dart';
import 'package:tilawah_app/database_helper.dart';
import 'package:tilawah_app/generated/l10n.dart';
import 'package:tilawah_app/model/local_reciter.dart';
import 'package:tilawah_app/repository/quran_repository_arb.dart';
import 'package:tilawah_app/views/azkar_view.dart';
import 'package:tilawah_app/views/prayer_times_view.dart';
import 'package:tilawah_app/views/quran_page.dart';
import 'package:tilawah_app/views/mushaf_view.dart';
import 'package:tilawah_app/widgets/favorite_reciter_list_item.dart';
import 'package:tilawah_app/widgets/reciter_list_item.dart';
import 'language_selection_dialog.dart';

class RecitersScreen extends StatefulWidget {
  static const routeName = 'reciters-screen';
  const RecitersScreen({super.key});
  static String? server;
  static String? recitersName;
  static String? rewayatName;
  static Moshaf? listMoshaf;
  static String? reiterId;
  static String? moshafTypeRewaya;
  static Directory? directory;
  static String? surahList;

  @override
  State<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends State<RecitersScreen> {
  List<Reciter> reciters = [];
  List<String> riwayatNames = [];
  String? searchArabicInput = "";
  final TextEditingController _searchTextEditingController =
      TextEditingController();
  bool _isSearching = false;
  String? _selectedRiwayat;
  bool? lastConnectionState;
  SnackBar? currentSnackbar;
  bool languageSelected = false;
  int _selectedIndex = 0; // For bottom navigation bar
  List<Map<String, String>> favoriteReciterIds = [];
  int? _selectedRiwayatId;
  OverlayEntry? _currentOverlayEntry;

  @override
  void initState() {
    super.initState();
    _checkLanguageSelection();
  }

  void _checkLanguageSelection() async {
    final savedLanguage = await DatabaseHelper.instance.getLanguage();
    if (savedLanguage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LanguageSelectionDialog(),
        ).then((_) {
          setState(() {
            languageSelected = true;
            _loadInitialData();
          });
        });
      });
    } else {
      setState(() {
        languageSelected = true;
        _loadInitialData();
      });
    }
  }

  void _loadInitialData() {
    loadReciters();
    loadFavorites();
  }

  void loadReciters() async {
    final language = context.read<LocalizationBloc>().state.locale.languageCode;

    context.read<LocalRecitersBloc>().add(LoadLocalRecitersEvent(language));
  }

  Future<void> loadFavorites() async {
    List<Map<String, String>> favoritesData = await DatabaseHelper.instance
        .getFavorites();

    setState(() {
      favoriteReciterIds = favoritesData
          .map(
            (data) => {
              'reciterId': data['reciterId']!,
              'moshafId': data['moshafId']!,
            },
          )
          .toList();
    });
  }

  //////

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeSelectedRiwayat();
  }

  void _initializeSelectedRiwayat() {
    _selectedRiwayat = S.of(context).rewayatDefault;
    RecitersScreen.rewayatName = _selectedRiwayat;
  }

  Future<String> get _localPath async {
    RecitersScreen.directory = await getApplicationDocumentsDirectory();
    return RecitersScreen.directory!.path;
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _navigateLocallyToShowTextField();
  }

  void _stopSearch() {
    _clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchTextEditingController.clear();
  }

  void addTypingLetters(String newSearchedValue) {
    setState(() {
      searchArabicInput = newSearchedValue;
    });
  }

  Future<void> _navigateLocallyToShowTextField() async {
    setState(() => _isSearching = true);
    ModalRoute.of(context)?.addLocalHistoryEntry(
      LocalHistoryEntry(
        onRemove: () {
          setState(() {
            addTypingLetters('');
            _isSearching = false;
          });
        },
      ),
    );
  }

  void _showCustomOverlay(
    BuildContext context,
    ContentType type,
    String title,
    String message,
  ) {
    _dismissCurrentOverlay();

    if (type == ContentType.binary) {
      _currentOverlayEntry = _createOverlayEntry(context, type, title, message);
      Overlay.of(context).insert(_currentOverlayEntry!);
    }
  }

  void _dismissCurrentOverlay() {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(
    BuildContext context,
    ContentType type,
    String title,
    String message,
  ) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top:
                MediaQuery.of(context).size.height / 2 +
                150, // 100 pixels below the center
            left: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.primaryColor,
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            message,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshContent() async {
    loadReciters();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: (_selectedIndex == 0 || _selectedIndex == 1)
            ? buildAppBar()
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: S.of(context).recitersList,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: S.of(context).Favorites,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: S.of(context).moshaf,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              loadReciters();
              loadFavorites();
            });
          },
          selectedItemColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        body: languageSelected
            ? buildBody()
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildBody() {
    if (_selectedIndex == 0) {
      return Column(
        children: [
          BlocListener<InternetBloc, InternetState>(
            listener: (context, state) {
              bool isConnected = state is InternetConnected;
              if (state is InternetDisconnected ||
                  state is InternetNoConnection) {
                _dismissCurrentOverlay();
                _showCustomOverlay(
                  context,
                  ContentType.binary,
                  S.of(context).alert,
                  S.of(context).internetConnectionState,
                );
              } else if (state is InternetConnected) {
                _dismissCurrentOverlay();
              }
              lastConnectionState = isConnected;
            },
            child: Container(),
          ),
          BlocListener<LocalizationBloc, LocalizationState>(
            listener: (context, state) {
              setState(() {
                _selectedRiwayat = S.of(context).rewayatDefault;
              });
              loadReciters();
              loadFavorites();
            },
            child: Container(),
          ),
          Expanded(
            child: BlocBuilder<LocalRecitersBloc, LocalRecitersState>(
              builder: (context, localState) {
                if (localState is LoadingLocalReciters) {
                  return const Center(child: CircularProgressIndicator());
                } else if (localState is LoadedLocalReciters) {
                  reciters = localState.localreciters;
                  riwayatNames = _getUniqueRiwayatNames(reciters);
                  return _buildRecitersList();
                } else if (localState is ErrorInLoadLocalReciters) {
                  return Center(child: Text(localState.errorMsg));
                } else {
                  return const Center(child: Text('Unknown state'));
                }
              },
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      return Column(
        children: [
          Expanded(
            child: BlocBuilder<LocalRecitersBloc, LocalRecitersState>(
              builder: (context, localState) {
                if (localState is LoadingLocalReciters) {
                  return const Center(child: CircularProgressIndicator());
                } else if (localState is LoadedLocalReciters) {
                  reciters = localState.localreciters;
                  List<Map<String, dynamic>> favoriteRecitersAndMoshaf = [];
                  for (var reciter in reciters) {
                    for (var moshaf in reciter.moshaf) {
                      if (favoriteReciterIds.any(
                        (favorite) =>
                            favorite['reciterId'] == reciter.id.toString() &&
                            favorite['moshafId'] == moshaf.id.toString(),
                      )) {
                        favoriteRecitersAndMoshaf.add({
                          'reciter': reciter,
                          'moshaf': moshaf,
                        });
                      }
                    }
                  }
                  return _buildFavoriteRecitersList(favoriteRecitersAndMoshaf);
                } else if (localState is ErrorInLoadLocalReciters) {
                  return Center(child: Text(localState.errorMsg));
                } else {
                  return const Center(child: Text('Unknown state'));
                }
              },
            ),
          ),
        ],
      );
    } else {
      return MushafView();
    }
  }

  List<String> _getUniqueRiwayatNames(List<Reciter> reciters) {
    Set<String> uniqueRiwayatNames = {};
    for (var reciter in reciters) {
      for (var moshaf in reciter.moshaf) {
        if (moshaf.name != null && moshaf.name!.isNotEmpty) {
          uniqueRiwayatNames.add(moshaf.name!);
        }
      }
    }
    return uniqueRiwayatNames.toList();
  }

  List<String> _getallFavNames(List<Reciter> reciters) {
    Set<String> uniqueRiwayatNames = {};
    for (var reciter in reciters) {
      for (var moshaf in reciter.moshaf) {
        if (moshaf.name != null && moshaf.name!.isNotEmpty) {
          uniqueRiwayatNames.add(moshaf.name!);
        }
      }
    }
    return uniqueRiwayatNames.toList();
  }

  Widget _buildRecitersList() {
    // Sort the reciters list alphabetically by reciter's name
    reciters.sort((a, b) => a.name!.compareTo(b.name!));

    // Filter the reciters list based on the selected riwayat and search input
    List<Reciter> filteredReciters = reciters.where((reciter) {
      return reciter.moshaf.any((moshaf) {
        return moshaf.name == _selectedRiwayat &&
            reciter.name!.toLowerCase().startsWith(
              searchArabicInput!.toLowerCase(),
            );
      });
    }).toList();

    return RefreshIndicator(
      onRefresh: _refreshContent,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: filteredReciters.length,
          itemBuilder: (context, index) {
            final reciter = filteredReciters[index];
            return Column(
              children: reciter.moshaf.map((moshaf) {
                if (moshaf.name != _selectedRiwayat) {
                  return SizedBox.shrink();
                }
                final isFavorite = favoriteReciterIds.any(
                  (favorite) =>
                      favorite['reciterId'] == reciter.id.toString() &&
                      favorite['moshafId'] == moshaf.id.toString(),
                );

                return ReciterListItem(
                  reciter: reciter,
                  moshaf: moshaf,
                  onReciterTap: _onReciterTap,
                  isArabic:
                      Localizations.localeOf(context).languageCode == 'ar',
                  isFavorite: isFavorite,
                  onFavoriteToggle: _toggleFavorite,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _onReciterTap(Reciter reciter, Moshaf moshaf) async {
    RecitersScreen.recitersName = reciter.name.toString();
    RecitersScreen.server = moshaf.server.toString();
    RecitersScreen.rewayatName = moshaf.name.toString();
    RecitersScreen.reiterId = reciter.id.toString();
    RecitersScreen.moshafTypeRewaya = moshaf.moshafType.toString();
    RecitersScreen.directory = Directory(await _localPath);
    String languageCode = Localizations.localeOf(context).languageCode;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return RepositoryProvider<AudioQuranRepository>(
            create: (context) => AudioQuranRepository(),
            child: BlocProvider<AudioQuranBloc>(
              create: (context) =>
                  AudioQuranBloc(context.read<AudioQuranRepository>())
                    ..add(LoadAudioQuranEvent(languageCode: languageCode)),
              child: QuranPage(),
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      backgroundColor: AppColors.primaryColor,
      toolbarHeight: 140,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      ),
      title: buildAppBarTitle(),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Column(
          children: [
            buildSearchRow(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildLanguageButtons(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: AppColors.lightPrimaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AzkarScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      
                      
                      Text(
                        'أذكار',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.nights_stay,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: AppColors.lightPrimaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrayerTimesView(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      
                
                      Text(
                        'مواقيت الصلاة 🕌',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedIndex != 1)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                ),
                height: 10.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchRow() {
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
              ? Expanded(child: _buildTextFieldSearch())
              : const SizedBox.shrink(),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Center buildAppBarTitle() {
    return Center(
      child: SizedBox(
        child: Row(
          children: [
            Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    !_isSearching
                        ? Shimmer.fromColors(
                            baseColor: Colors.black26,
                            highlightColor: Colors.white,
                            child: Image.asset(
                              "assets/ayah.png",
                              color: Colors.black,
                              height: 110,
                              width: 110,
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(
                      width: 150,
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            S.of(context).recitersList,
                            style: GoogleFonts.tajawal(
                              textStyle: const TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 200, child: buildRiwayatFilter()),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      height: 50,
                      child: Row(
                        children: [
                          if (!_isSearching)
                            IconButton(
                              onPressed: _startSearch,
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            )
                          else
                            const SizedBox.square(),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldSearch() {
    return SizedBox(
      height: 40,
      width: 200,
      child: Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: TextField(
          cursorWidth: 1.0,
          textDirection: TextDirection.rtl,
          cursorColor: Colors.black,
          autofocus: true,
          controller: _searchTextEditingController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 5, right: 15),
            hintText: S.of(context).search,
            hintStyle: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
              color: Colors.black26,
            ),
            filled: true,
            fillColor: const Color(0xFFE8E6E6),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (searchedValue) {
            setState(() {});
            addTypingLetters(searchedValue);
          },
        ),
      ),
    );
  }

  Widget buildLanguageButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton(
            icon: Icon(Icons.language, color: Colors.white, size: 18),
            onSelected: (value) async {
              if (value == 'eng') {
                // Update the locale
                context.read<LocalizationBloc>().add(
                  ChangeLocale(const Locale('eng')),
                );
                setState(() {
                  _selectedRiwayat = S.of(context).rewayatDefault;
                });
                // Save the selected language in the database
                await DatabaseHelper.instance.saveLanguage('eng');
              } else if (value == 'ar') {
                // Update the locale
                context.read<LocalizationBloc>().add(
                  ChangeLocale(const Locale('ar')),
                );
                setState(() {
                  _selectedRiwayat = S.of(context).rewayatDefault;
                });
                // Save the selected language in the database
                await DatabaseHelper.instance.saveLanguage('ar');
              } else if (value == 'fr') {
                // Update the locale
                context.read<LocalizationBloc>().add(
                  ChangeLocale(const Locale('fr')),
                );
                setState(() {
                  _selectedRiwayat = S.of(context).rewayatDefault;
                });
                // Save the selected language in the database
                await DatabaseHelper.instance.saveLanguage('fr');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: 'eng',
                child: Row(
                  children: [Text('English', style: GoogleFonts.tajawal())],
                ),
              ),
              PopupMenuItem(
                value: 'ar',
                child: Row(
                  children: [Text('العربية', style: GoogleFonts.tajawal())],
                ),
              ),
              PopupMenuItem(
                value: 'fr',
                child: Row(
                  children: [Text('Français', style: GoogleFonts.tajawal())],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRiwayatFilter() {
    return PopupMenuButton<String>(
      onSelected: (String newValue) {
        setState(() {
          RecitersScreen.rewayatName = newValue;
          _selectedRiwayat = newValue;
        });
      },
      itemBuilder: (BuildContext context) {
        return riwayatNames.map<PopupMenuItem<String>>((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Flexible(
                  child: Directionality(
                    textDirection:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Text(
                      value,
                      style: GoogleFonts.tajawal(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                _selectedRiwayat ?? S.of(context).recitersList,
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22),
          ],
        ),
      ),
      color: AppColors.lightPrimaryColor,
    );
  }

  Widget _buildFavoriteRecitersList(
    List<Map<String, dynamic>> favoriteRecitersAndMoshaf,
  ) {
    if (favoriteRecitersAndMoshaf.isEmpty) {
      return Center(
        child: Text(
          S.of(context).Nofavorites,
          style: GoogleFonts.tajawal(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshContent,
      child: ListView.builder(
        itemCount: favoriteRecitersAndMoshaf.length,
        itemBuilder: (context, index) {
          final reciter =
              favoriteRecitersAndMoshaf[index]['reciter'] as Reciter;
          final moshaf = favoriteRecitersAndMoshaf[index]['moshaf'] as Moshaf;

          return FavoriteReciterListItem(
            reciter: reciter,
            moshaf: moshaf,
            onReciterTap: _onReciterTap,
            isArabic: Localizations.localeOf(context).languageCode == 'ar',
            isFavorite: true,
            onFavoriteToggle: (reciter, moshaf) =>
                _toggleFavorite(reciter, moshaf),
          );
        },
      ),
    );
  }

  ///////

  void _toggleFavorite(Reciter reciter, Moshaf moshaf) async {
    String reciterId = reciter.id.toString();
    String moshafId = moshaf.id.toString();

    var favorite = favoriteReciterIds.firstWhere(
      (fav) => fav['reciterId'] == reciterId && fav['moshafId'] == moshafId,
      orElse: () => {},
    );

    if (favorite.isNotEmpty) {
      await DatabaseHelper.instance.removeFavorite(reciterId, moshafId);

      favoriteReciterIds.remove(favorite);
    } else {
      await DatabaseHelper.instance.addFavorite(reciterId, moshafId);

      favoriteReciterIds.add({'reciterId': reciterId, 'moshafId': moshafId});
    }

    setState(() {});
  }
}
