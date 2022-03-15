import 'package:flashcardo/app/home/models/settings.dart';
import 'package:flashcardo/common_widget/show_alert_dialog.dart';
import 'package:flashcardo/services/auth.dart';
import 'package:flashcardo/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _preferencesService = PreferencesService();

  Color _frontColor = Colors.grey[850];
  Color _backColor = Colors.grey[850];
  Color _selectFrontColor;
  Color _selectBackColor;

  @override
  initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _preferencesService.getSettings();
    setState(() {
      _frontColor = Color(settings.flashcardFrontColor ?? 4281348144);
      _backColor = Color(settings.flashcardBackColor ?? 4281348144);
    });
  }

  @override
  Widget build(BuildContext context) {
    _selectFrontColor = _frontColor;
    _selectBackColor = _backColor;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.lightGreen[400],
        elevation: 20,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.lightGreen[400], Colors.green[300]],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
        ),
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SettingsList(
            contentPadding: EdgeInsets.only(top: 10),
            shrinkWrap: true,
            darkBackgroundColor: Colors.grey[900],
            lightBackgroundColor: Colors.grey[900],
            sections: [
              SettingsSection(
                title: 'General',
                tiles: [
                  SettingsTile(
                    title: 'Flashcard Frontview Color',
                    leading: Icon(
                      Icons.color_lens,
                      color: Colors.white,
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _frontColor,
                      ),
                      width: 20,
                      height: 20,
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: (BuildContext context) {
                      pickFrontColor(context);
                    },
                  ),
                  SettingsTile(
                    title: 'Flashcard Backview Color',
                    leading: Icon(
                      Icons.color_lens,
                      color: Colors.white,
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _backColor,
                      ),
                      width: 20,
                      height: 20,
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: (BuildContext context) {
                      pickBackColor(context);
                    },
                  ),
                ],
              ),
              SettingsSection(title: 'Account', tiles: [
                SettingsTile(
                  title: 'Logout',
                  leading: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  titleTextStyle: TextStyle(
                    color: Colors.grey[350],
                    fontWeight: FontWeight.w600,
                  ),
                  subtitleTextStyle: TextStyle(
                    color: Colors.grey[350],
                    fontWeight: FontWeight.w500,
                  ),
                  onPressed: (BuildContext context) {
                    _confirmSignOut(context);
                  },
                ),
              ]),
            ],
          ),
        ),
        Center(
            child: ElevatedButton(
          onPressed: () {
            _saveSettings(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) {
                return Colors.lightGreen[400];
              },
            ),
            shadowColor: MaterialStateProperty.resolveWith(
              (states) {
                return Colors.lightGreen[200];
              },
            ),
            overlayColor: MaterialStateProperty.resolveWith(
              (states) {
                return states.contains(MaterialState.pressed)
                    ? Colors.lightGreenAccent[100]
                    : null;
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            )),
          ),
          child: Text("Save Settings",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              )),
        ))
      ],
    );
  }

  void pickFrontColor(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Pick A Color"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildColorPicker(true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text(
                          "Select",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () {
                          setState(() {
                            _frontColor = _selectFrontColor;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  void pickBackColor(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Pick A Color"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildColorPicker(false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text(
                          "Select",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () {
                          setState(() {
                            _backColor = _selectBackColor;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  Widget buildColorPicker(bool isFront) {
    return ColorPicker(
        pickerColor: isFront ? _frontColor : _backColor,
        enableAlpha: false,
        onColorChanged: (color) {
          if (isFront) {
            _selectFrontColor = color;
          } else {
            _selectBackColor = color;
          }
        });
  }

  Future<void> _saveSettings(BuildContext context) async {
    final confirmSaveSettings = await showAlertDialog(
      context,
      title: "Save Settings",
      content: "Confirm want to save new settings?",
      cancelActionText: "Cancel",
      defaultActionText: "Yes",
    );
    if (confirmSaveSettings == true) {
      String fColorToHexString =
          '#FF${_frontColor.value.toRadixString(16).substring(2, 8)}';

      String bColorToHexString =
          '#FF${_backColor.value.toRadixString(16).substring(2, 8)}';

      final frontHexString = fColorToHexString.replaceAll('#', '');
      final backHexString = bColorToHexString.replaceAll('#', '');

      final newSettings = Settings(
        flashcardFrontColor: int.parse(frontHexString, radix: 16),
        flashcardBackColor: int.parse(backHexString, radix: 16),
      );
      _preferencesService.saveSettings(newSettings);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings Updated!',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: "Logout",
      content: "Confirm want to logout?",
      cancelActionText: "Cancel",
      defaultActionText: "Logout",
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }
}
