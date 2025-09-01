class Reciter {
  final String name;
  final int id;

  String get audioBaseUrl =>
      'https://github.com/The-Quran-Project/Quran-Audio-Chapters/raw/refs/heads/main/Data/$id/';

  const Reciter({required this.name, required this.id});
}
