import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tragos_data.dart';

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';

  // Search shows by query
  Future<List<Trago>> searchShows(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search/shows?q=$query'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Trago>((item) => Trago.fromJson(item['show'])).toList();
    } else {
      throw Exception('Failed to load shows');
    }
  }

  // Lookup show by thetvdb id
  Future<Trago> lookupShowByTvdb(int tvdbId) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup/shows?thetvdb=$tvdbId'));
    if (response.statusCode == 200) {
      return Trago.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to lookup show');
    }
  }

  // Get show by id
  Future<Trago> getShowById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$id'));
    if (response.statusCode == 200) {
      return Trago.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get show');
    }
  }

  // Get images for a show by id
  Future<List<MediaImage>> getShowImages(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$id/images'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<MediaImage>((item) => MediaImage.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get show images');
    }
  }
}
