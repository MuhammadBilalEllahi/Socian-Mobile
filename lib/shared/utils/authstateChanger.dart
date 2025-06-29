import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/secure_storage_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthStateChanger {
  static Future<void> updateAuthState(ref, String receivedData, String field1,
      {String field2 = '', String field3 = '', String field4 = ''}) async {
    final token = await SecureStorageService.instance.getToken();

    if (token != null) {
      final dataJSON = JwtDecoder.decode(token);
      // Update the specific field

      if (field1 != '' && field2 != '') {
        dataJSON[field1][field2] = receivedData;
      } else if (field1 != '' && field2 != '' && field3 != '') {
        dataJSON[field1][field2][field3] = receivedData;
      } else if (field1 != '' && field2 != '' && field3 != '' && field4 != '') {
        dataJSON[field1][field2][field3][field4] = receivedData;
      } else {
        dataJSON[field1] = receivedData;
      }

      final jwt = JWT(dataJSON);

      final convertedToJWT = jwt.sign(SecretKey(dotenv.get('JTM')));

      // Save the entire updated token
      await SecureStorageService.instance.saveToken(convertedToJWT);

      // Update Riverpod state using updateAuthState
      await ref
          .read(authProvider.notifier)
          .updateAuthState(dataJSON, convertedToJWT);
    }
  }
}
