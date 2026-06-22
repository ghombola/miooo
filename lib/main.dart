// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart' deferred as main_screen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تنظیم استایل نوار وضعیت و نویگیشن برای یکپارچگی با تم تاریک و پریمیوم
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050510),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SoraEliteApp());
}

class SoraEliteApp extends StatelessWidget {
  const SoraEliteApp({super.key});

  // استخراج تم به صورت استاتیک برای جلوگیری از ساخت مجدد در هر build (بهینه‌سازی حافظه و سرعت)
  static final ThemeData _appTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF667eea), // هماهنگ با رنگ اصلی گرادیانت MainScreen
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF050510),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sora Elite',
      theme: _appTheme,
      home: const _AppInitializer(),
    );
  }
}

/// ویجتی برای مدیریت لود Deferred بدون مسدود کردن UI
class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  late final Future<void> _libraryLoader;

  @override
  void initState() {
    super.initState();
    // شروع لود کتابخانه به صورت Async
    _libraryLoader = main_screen.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _libraryLoader,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _ErrorScreen(error: snapshot.error.toString());
          }
          // لود با موفقیت انجام شد، نمایش صفحه اصلی
          return main_screen.MainScreen();
        }
        
        // نمایش اسپلش اسکرین در حین لود شدن
        return const _SplashScreen();
      },
    );
  }
}

/// اسپلش اسکرین مدرن و مینیمال
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF050510),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.diamond_outlined,
              color: Color(0xFF667eea),
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              'Sora Elite',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// صفحه مدیریت خطا (در صورت عدم لود شدن کتابخانه)
class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              const Text(
                'خطا در بارگذاری اپلیکیشن',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop(); // بستن اپلیکیشن برای ریستارت
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                ),
                child: const Text('خروج و تلاش مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}