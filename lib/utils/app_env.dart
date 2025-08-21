import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static final String apiKey = dotenv.env['API_KEY'] ?? '';
}
