import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  SharedPreferences? _prefs;
  final Set<String> _ids = {};

  Set<String> get ids => _ids;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonStr = _prefs?.getString('favorites') ?? '[]';
    final List<dynamic> list = json.decode(jsonStr);
    _ids.addAll(list.cast<String>());
  }

  bool isFav(String id) => _ids.contains(id);

  void toggle(String id) {
    _ids.contains(id) ? _ids.remove(id) : _ids.add(id);
    _prefs?.setString('favorites', json.encode(_ids.toList()));
    notifyListeners();
  }
}
