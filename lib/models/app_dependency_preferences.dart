// ignore_for_file: constant_identifier_names

import '../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  static const CONSUMET_URL_KEY = "consumetUrlKey";
  static const FLIXQUEST_LOGO_URL = "flixquestLogoUrl";
  static const OPENSUBTITLES_KEY = "opensubtitlesKey";
  static const STREAM_SERVER = "vidcloud";
  static const SHOWBOX_URL = "showbox_url";
  static const STREAM_ROUTE = "streamRoute";

  setConsumetUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CONSUMET_URL_KEY, value);
  }

  Future<String> getConsumetUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CONSUMET_URL_KEY) ?? 'https://consumet.beamlak.dev';
  }

  setFlixQuestUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(FLIXQUEST_LOGO_URL, value);
  }

  Future<String> getFlixQuestLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(FLIXQUEST_LOGO_URL) ?? 'default';
  }

  setOpenSubKey(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(OPENSUBTITLES_KEY, value);
  }

  Future<String> getOpenSubtitlesKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(OPENSUBTITLES_KEY) ?? openSubtitlesKey;
  }

  setStreamServer(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STREAM_SERVER, value);
  }

  Future<String> getStreamServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(STREAM_SERVER) ?? STREAMING_SERVER;
  }

  Future<bool> enableAD(bool enable) async {
    return enable;
  }

  Future<String> getShowboxUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SHOWBOX_URL) ?? "";
  }

  setShowboxUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SHOWBOX_URL, value);
  }

  Future<String> getStreamRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(STREAM_ROUTE) ?? 'flixHQ';
  }

  setStreamRoute(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STREAM_ROUTE, value);
  }
}
