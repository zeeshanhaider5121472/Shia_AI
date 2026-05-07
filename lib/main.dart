import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'services/favorites_service.dart';
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

  final dataService = DataService();
  await dataService.loadData();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: dataService),
      ChangeNotifierProvider.value(value: favService),
    ],
    child: const ShiaAIApp(),
  ));
}

class ShiaAIApp extends StatelessWidget {
  const ShiaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shia AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
