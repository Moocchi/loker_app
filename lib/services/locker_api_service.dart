import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/locker_status.dart';

class LockerApiService {
  LockerApiService({required this.baseUrl});

  final String baseUrl;

  Future<List<LockerStatus>> fetchLockers() async {
    final Uri url = Uri.parse('$baseUrl/api/lockers');
    final http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal ambil data locker (${response.statusCode})');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Format data backend tidak valid');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LockerStatus.fromJson)
        .toList();
  }
}
