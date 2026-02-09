import 'package:flutter/material.dart';
import 'routes.dart';
import 'themes/app_colors.dart';
import '../core/constants/app_constants.dart';

class ChestXRayApp extends StatelessWidget {
  const ChestXRayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.onSurfaceLight,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: 'Outfit',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.onSurfaceDark,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'Outfit',
      ),
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
