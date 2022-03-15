import 'package:flashcardo/app/home/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveSettings(Settings settings) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt(
        "flashcardFrontColor", settings.flashcardFrontColor);
    await preferences.setInt("flashcardBackColor", settings.flashcardBackColor);
  }

  Future<Settings> getSettings() async {
    final preferences = await SharedPreferences.getInstance();

    final flashcardFrontColor = preferences.getInt("flashcardFrontColor");
    final flashcardBackColor = preferences.getInt("flashcardBackColor");

    return Settings(
        flashcardFrontColor: flashcardFrontColor,
        flashcardBackColor: flashcardBackColor);
  }
}
