import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  double? latitude;
  double? longitude;
  String cityName = '';
  Map<String, String> prayerTimes = {};
  double? qiblaDirection;
  double? distanceToKaaba;
  bool loading = false;
  String error = '';

  bool get hasLocation => latitude != null && longitude != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('loc_lat');
    final lng = prefs.getDouble('loc_lng');
    if (lat != null && lng != null) {
      latitude = lat;
      longitude = lng;
      cityName = prefs.getString('loc_city') ?? '';
      final saved = prefs.getString('loc_prayer');
      if (saved != null) {
        prayerTimes =
            Map<String, String>.from(json.decode(saved) as Map);
      }
      _calculateQibla();
      notifyListeners();
    }
  }

  Future<void> detectLocation() async {
    loading = true;
    error = '';
    notifyListeners();

    try {
      LocationPermission perm;
      try {
        perm = await Geolocator.checkPermission();
      } catch (e) {
        _fail('Location service unavailable');
        return;
      }

      if (perm == LocationPermission.denied) {
        try {
          perm = await Geolocator.requestPermission();
        } catch (e) {
          _fail('Location permission error');
          return;
        }
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _fail('Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      latitude = pos.latitude;
      longitude = pos.longitude;

      await _reverseGeocode();
      await _fetchPrayerTimes();
      _calculateQibla();

      // Save to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('loc_lat', latitude!);
      await prefs.setDouble('loc_lng', longitude!);
      await prefs.setString('loc_city', cityName);
      await prefs.setString('loc_prayer', json.encode(prayerTimes));

      loading = false;
      error = '';
    } catch (e) {
      debugPrint('[LocationService] Error: $e');
      _fail('Unable to detect location');
    }
    notifyListeners();
  }

  void _fail(String msg) {
    error = msg;
    loading = false;
    notifyListeners();
  }

  Future<void> _reverseGeocode() async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$latitude&lon=$longitude&format=json&zoom=10',
      );
      final resp = await http.get(url, headers: {
        'User-Agent': 'ShiaAI-Flutter/2.0',
      }).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final addr = data['address'] ?? {};
        cityName = addr['city'] ??
            addr['town'] ??
            addr['village'] ??
            addr['municipality'] ??
            addr['state'] ??
            addr['country'] ??
            '';
      }
    } catch (e) {
      debugPrint('[LocationService] Geocode error: $e');
    }

    if (cityName.isEmpty) {
      cityName =
          '${latitude!.toStringAsFixed(2)}\u00B0, ${longitude!.toStringAsFixed(2)}\u00B0';
    }
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$ts'
        '?latitude=$latitude&longitude=$longitude&method=0',
      );
      final resp =
          await http.get(url).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final t = data['data']['timings'];
        prayerTimes = {
          'Fajr': _cleanTime(t['Fajr'] ?? ''),
          'Sunrise': _cleanTime(t['Sunrise'] ?? ''),
          'Dhuhr': _cleanTime(t['Dhuhr'] ?? ''),
          'Asr': _cleanTime(t['Asr'] ?? ''),
          'Maghrib': _cleanTime(t['Maghrib'] ?? ''),
          'Isha': _cleanTime(t['Isha'] ?? ''),
        };
      }
    } catch (e) {
      debugPrint('[LocationService] Prayer API error: $e');
    }
  }

  String _cleanTime(String raw) {
    return raw.replaceAll(RegExp(r'\s*$$.*$$'), '').trim();
  }

  void _calculateQibla() {
    if (latitude == null || longitude == null) return;

    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    final lat1 = latitude! * pi / 180;
    final lon1 = longitude! * pi / 180;
    final lat2 = kaabaLat * pi / 180;
    final lon2 = kaabaLon * pi / 180;

    final dLon = lon2 - lon1;
    final y = sin(dLon);
    final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

    var q = atan2(y, x) * 180 / pi;
    if (q < 0) q += 360;
    qiblaDirection = q;

    final dLat = lat2 - lat1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distanceToKaaba = 6371 * c;
  }
}
