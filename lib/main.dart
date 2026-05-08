import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'services/favorites_service.dart';
import 'services/settings_service.dart';
import 'services/location_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final favService = FavoritesService();
  await favService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  final locationService = LocationService();
  await locationService.init();

  final dataService = DataService();
  await dataService.loadData();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: dataService),
      ChangeNotifierProvider.value(value: favService),
      ChangeNotifierProvider.value(value: settingsService),
      ChangeNotifierProvider.value(value: locationService),
    ],
    child: const ShiaAIApp(),
  ));
}

class ShiaAIApp extends StatelessWidget {
  const ShiaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (ctx, settings, _) {
        AppColors.isDark = settings.isDark;
        AppStyles.fontScale = settings.fontScale;
        AppStyles.fontFamily = settings.fontFamily;
        AppStyles.arabicFontFamily = settings.arabicFontFamily;

        return MaterialApp(
          title: 'Shia AI',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const HomeScreen(),
        );
      },
    );
  }
}
