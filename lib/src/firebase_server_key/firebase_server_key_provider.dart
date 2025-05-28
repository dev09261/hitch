import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class FirebaseServerKeyProvider {
  static Future<String> getServerKey()async{
    final String firebaseProjectAppID = dotenv.env['FIREBASE_PROJECT_ID']!;
    final String serverPrivateKeyID = dotenv.env['FIREBASE_SERVER_KEY_PRIVATEID']!;
    final String serverClientID = dotenv.env['FIREBASE_SERVER_CLIENT_ID']!;
    final String serverClientEmail = dotenv.env['FIREABSE_SERVER_CLIENT_EMAIL']!;


    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging'
    ];

    final client = await clientViaServiceAccount(ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": firebaseProjectAppID,
          "private_key_id": serverPrivateKeyID,
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCnw9k1vmAT+vHI\n2/BFLiT6/yAyJ/WzxHHw2hvs81KDaJHmjgWlIunTZoH9lT9h/4vCUj+0NkevQVYm\n+Rljc2utHFcCzyU39Ae8DWzPKxbHP25+BHxa7CAFkX8Uqt5UF/Tp3eIz2RKdZc4m\nSOiUtwhIdTAGBkhEAROu2RqjX6/jTennPVwrPByTEoGZZuhJJRnThPVe6oG8KDTC\nHzjUkkMd2nkt7UdI166imKlgyXXbjyRqvv/VUVBxXuwigJQBZPUs71VH35uis+f8\nc4sUChVZAYkD74ZijHqjPy0euH56lP0Ko/cIsHYBVoNG9oSxWpH3vPgPLIoiDpQM\nsOPgY0JLAgMBAAECggEACWHBdujzlIp3FQV/tU60ULkNwuBLNEdrG84Gu8SLu7+Q\nUTVmCWsfamwUHutGxSM2XKKe32QdtCZSPBG4IsCkp+Sq1QRij3N9Lz4M9LTzLCdW\n9YMotSj5TXZqhexcTJWeY6m96apdCSJVWfy/zPlDZFHxYpTdW7g3spJ/k91ZB7wP\nZPJlfIwbGwOIxH+jYqLxyZBmhOHqM3CMRux05cc4MmgbiepumzDMjxYW+6Rs5zsH\n15cOZuqo+KTyYg/s3/nPG33tY2FOQLPAK34umvzQhHxHi3DSwet35XmFl4WwVTBF\nCkfisdPOeZmOrvg2e227hZQaM4xANgrVVTpDKp2ZuQKBgQDm8H3GsQUvrV0eipks\nQxSbGeYFv2kodT/GY6CfMi9yNJiIJevUuuY9u899yIsFW7FGekVbYM2ZZoJYr7zF\n7nHJ+B3L5SUOwThOE04hS3EtTFSmN96FaaxXZRtzGHUxJU/qAtwxTqtLzs/Cpcq1\nyk5B9vY+dwuaaQ4rEh1OK9oCDwKBgQC5+F6aF2fGVO9OzI686ZzLPr3frXHn9KRq\nxhm/02mX3rBgyh7jP67SWaTGDTbJpuranPEWGlV7cG3cpoCLPAsw+5vmeWGoMQqp\nrgdNEDvmoa3ue0tQjJelcm2NqquHP0t8C9Y7p0PwVU8ztJi+F/92rZx7LD+v7d/5\nNvSCS6NIBQKBgQDDTZ8Q6aP5LiQSMCRZymEiykQ9mCLWlFHa9WZhO4/khZZ5jZhj\nz6vniW1wcqkfXuwNLlp5bORzVr3lQrniqkSRCcQpKyCr2bxESw9IGQUdye/MonMN\nYNDfGCKes5Bof6WVwdV13ZIACmaptow4MV79al3VddfaPf49bpRaB7vXAQKBgFK7\n8DpVV1Ggz6Ya0xWwSJUTIJ22KAqth8gIwcPZZgyugYFN6lfnKPtj7i4+CrXDkJAZ\nahgPNyBncDjNyjonSENObJkoPw34Y2oBhjX+lueP3jVOnL8FDSIJujtgRlcxDX/u\nNCztyQfOrCGwopNPUdOWgRs7IEpAZXgVvsmIpOeRAoGAI0W06z1IL+GR/Kf0LiLm\nywKPFN2AGT/yb+J2sRihyLO+ktDV6pJuIdnQ14QB8WjfmYsq+yqEbprJzQiVqYxG\ngR2OPQZPfNrNzkfNF2hm1ueQ+2Shfvs2RIzCGof7ubWFHeFqn7kZJzC8c+dCkioN\nkfXZ1eTfhcvkDBekDxX9br0=\n-----END PRIVATE KEY-----\n",
          "client_email": serverClientEmail,
          "client_id": serverClientID,
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-eni9s%40hitches-mobile-app.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
    ), scopes);

    return client.credentials.accessToken.data;
  }

}