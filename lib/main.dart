import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'screens/main_menu.dart';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatefulWidget {
  final bool enableUpdateCheck;

  const MemoryGameApp({
    super.key,
    this.enableUpdateCheck = true,
  });

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp> {
  final AppSettingsController _settingsController = AppSettingsController();

  @override
  void initState() {
    super.initState();
    _settingsController.load();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settingsController,
      child: MaterialApp(
        title: 'Kids Memory Trainer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3F8CFF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFF7DA),
          fontFamily: 'SF Pro Display',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFF7DA),
            foregroundColor: Color(0xFF22304A),
            centerTitle: true,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF22304A),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A59),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          segmentedButtonTheme: SegmentedButtonThemeData(
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedBackgroundColor: const Color(0xFF3F8CFF),
              selectedForegroundColor: Colors.white,
              foregroundColor: const Color(0xFF22304A),
              side: const BorderSide(color: Color(0xFFBDD6FF), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFBDD6FF), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFBDD6FF), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF3F8CFF), width: 3),
            ),
          ),
        ),
        home: MainMenu(enableUpdateCheck: widget.enableUpdateCheck),
      ),
    );
  }
}
