import 'dart:io';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason | $formattedEpisode";
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted && !status.isPermanentlyDenied) {
    Permission.notification.request();
  }
}

Future<bool> checkConnection() async {
  bool? isInternetWorking;
  try {
    final response = await InternetAddress.lookup('google.com');

    isInternetWorking = response.isNotEmpty;
  } on SocketException catch (e) {
    debugPrint(e.toString());
    isInternetWorking = false;
  }

  return isInternetWorking;
}

String removeCharacters(String input) {
  String charactersToRemove = ",.?\"'";
  String pattern = '[$charactersToRemove]';
  String result = input.replaceAll(RegExp(pattern), '');
  return result;
}

Future<bool> clearTempCache() async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("Failed to clear temp files");
  }
}

Future<bool> clearCache() async {
  try {
    Directory cacheDir = await getApplicationCacheDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("Failed to clear cache");
  }
}

void fileDelete() async {
  for (int i = 0; i < appNames.length; i++) {
    File file =
        File("${(await getApplicationCacheDirectory()).path}${appNames[i]}");
    if (file.existsSync()) {
      file.delete();
    }
  }
}

int totalStreamingDuration = 0; // Keep track of the total streaming duration

// Function to update and log the aggregate streaming duration
void updateAndLogTotalStreamingDuration(int durationInSeconds) {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  totalStreamingDuration += durationInSeconds;

  // Log the new total duration as a custom event for tracking purposes
  analytics.logEvent(
    name: 'total_streaming_duration',
    parameters: <String, dynamic>{
      'duration_seconds': totalStreamingDuration,
    },
  );
}

String generateCacheKey() {
  Random random = Random();

  List<String> characters = [];
  String generatedChars = "";

  for (var i = 0; i < 26; i++) {
    characters.add(String.fromCharCode(97 + i)); // Lowercase letters a-z
  }

  for (var i = 0; i < 26; i++) {
    characters.add(String.fromCharCode(65 + i)); // Uppercase letters A-Z
  }

  for (var i = 0; i < 10; i++) {
    characters.add(i.toString()); // Numbers 0-9
  }

  characters.add('-');

  int min = 0;
  int max = characters.length - 1;
  int randomInt;

  for (int i = 0; i < 50; i++) {
    randomInt = min + random.nextInt(max - min + 1);
    generatedChars += characters[randomInt];
  }

  return generatedChars;
}
