import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode themeMode) {
    emit(themeMode);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final theme = json['themeMode'];

    if (theme == 'light') {
      return ThemeMode.light;
    }

    if (theme == 'dark') {
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {
      'themeMode': state.name,
    };
  }
}