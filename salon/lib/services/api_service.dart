import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/beauty_product_model.dart';

class ApiService {
  static const String baseUrl = 'https://makeup-api.herokuapp.com/api/v1/products.json';

  Future<List<BeautyProductModel>> getBeautyProducts() async {
    try {
      // Fetching products from a specific brand to limit results and ensure stability
      final response = await http.get(Uri.parse('$baseUrl?brand=maybelline'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<BeautyProductModel> products = body
            .map((dynamic item) => BeautyProductModel.fromJson(item))
            .toList();
        return products;
      } else {
        throw "Failed to load beauty products";
      }
    } catch (e) {
      throw "Error connecting to API: $e";
    }
  }
}
