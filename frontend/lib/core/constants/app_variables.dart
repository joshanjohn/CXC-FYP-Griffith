import 'package:flutter_dotenv/flutter_dotenv.dart';

final String beUri = dotenv.get('BE_URI', fallback: "");
final String beUriMobile = dotenv.get('BE_URI_MOBILE', fallback: "");
