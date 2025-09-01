import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tilawah_app/core/utils/app_colors.dart';
import 'package:tilawah_app/views/download_widget/directory.dart';
import 'package:tilawah_app/views/reciters_screen.dart';

class DownloadWidget extends StatefulWidget {
  final String suraNoDownloading;
  const DownloadWidget({
    super.key,
    required this.suraNoDownloading,
  });

  @override
  State<DownloadWidget> createState() =>
      _DownloadWidgetState(suraNoDownloading);
}
class _DownloadWidgetState extends State<DownloadWidget> {
  final String suraNoDownloading;
  bool dowloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  CancelToken? cancelToken;
  var getPathFile = DirectoryPath();

  _DownloadWidgetState(this.suraNoDownloading);

  Future<void> startDownload() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';

    if (!mounted) return;
    setState(() {
      dowloading = true;
      progress = 0;
    });

    try {
      await Dio().download(
        RecitersScreen.server.toString() + suraNoDownloading,
        filePath,
        onReceiveProgress: (count, total) {
          if (!mounted) return;
          setState(() {
            progress = (count / total);
          });
        },
        cancelToken: cancelToken,
      );

      if (!mounted) return;
      setState(() {
        dowloading = false;
        fileExists = true;
      });
    } catch (e) {
      
      if (!mounted) return;
      setState(() {
        dowloading = false;
      });
    }
  }

  void cancelDownload() {
    cancelToken?.cancel();
    if (!mounted) return;
    setState(() {
      dowloading = false;
    });
  }

  Future<void> checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    bool fileExistCheck = await File(filePath).exists();
    if (!mounted) return;
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  @override
  void initState() {
    super.initState();
    fileName =
        '${RecitersScreen.reiterId}_${RecitersScreen.moshafTypeRewaya}_${suraNoDownloading}';
    checkFileExit();
  }

  @override
  void dispose() {
    cancelToken?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (fileExists && !dowloading)
            InkWell(
              child: const Icon(
                Icons.file_download_done,
                color: Colors.transparent,
                size: 25,
              ),
              onTap: () {},
            )
          else if (!dowloading && !fileExists)
            InkWell(
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.cloud_download_outlined,
                  color: Color.fromARGB(255, 43, 216, 130),
                  size: 30,
                ),
              ),
              onTap: () {
                startDownload();
              },
            )
          else if (dowloading)
            InkWell(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularPercentIndicator(
                  radius: 15.0,
                  lineWidth: 5.0,
                  percent: progress,
                  center: progress == 0
                      ?  Text("")
                      : Text(
                          ((progress * 100).toStringAsFixed(0)),
                          style:  TextStyle(fontSize: 9),
                        ),
                  progressColor: AppColors.primaryColor,
                ),
              ),
              onTap: cancelDownload,
            ),
        ],
      ),
    );
  }
}
