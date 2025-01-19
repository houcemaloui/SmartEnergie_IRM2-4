import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://localhost:7067";

  // Méthode pour récupérer les données depuis l'API
  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/api/Home/MobileData"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // Retourne les données JSON
      } else if (response.statusCode == 404) {
        throw Exception("Aucune donnée disponible.");
      } else {
        throw Exception("Erreur : ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
}
