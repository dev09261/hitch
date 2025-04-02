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
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDflmd077PIsyR3\njKi3aKbn21/BBBN1s8gVQq7MXyTDa3ZQdrQvz69n4OHKN+UgtvFcIBI47lwU2RY3\nfKH6isTO1SB6BQo22Oo7m6mz0vyPh9DEfMfA6fxsJqmv0OTUDMIJdhPQzbZFLQ1B\nhgiA4teXTRr2J52fxfOxhFivl12BXT0m1Kls0C9RKEMraEba/yH/3I3CbXmjXd6M\nYMMYmlUSDJ+4vT5SythuDf6ZeaQhvCHLK7KONt13dE0Hk6nUhYFZmIYE9ajGAC8Z\n8HCm3HZV963GHS8H4HlVooBz/+37jTdiQOKhW+xH/hX6rWnTEZkmoPdsN6tuTZLu\nryKAK3XDAgMBAAECggEAM6fG7SA39AVXRntruzvlW6m2HJy5djb74dWPFs5gavmX\n0w0poeYkiyZMY/C38e/yISuTqi1/fp2M4XLc5UpMH9DjeO1TJ8rDitPyyAXVrb9d\n/xco+yvT0pS4HVNwmoD8Dz2FZHcyRhcbeejibAx8bIs20Gnko7YTEA8YgjDBPJKE\naud7xPvcLykLHNSGGy7XDm7M8dzv56wNvx9ArphBfN3hJOaBVb4Wm/0uK7afTKbu\njxZ051EO8Df5JhywJvxSv3o41UMZDHzvLM0GyTSxqaRqUJ/mLPXLGc4nkRitkFTE\nXSW2gxlx4GcXvnHcAdmNQvVOyVWvfL1GyzmOq8nb8QKBgQD1FuZcXPwcm8nRtJCH\nvLukn/YiFoCUiaCzdr3L9SLnr3S0lV3seL6Rz+jV27UjvDyrdofC47ue3Uh1K5yi\nmPo+IQgYPvRNSTVUCND3iEqkk3UaqgPkNoiuOx7JPfrYKNNUhc3NghUK4xRgWQnS\nwf0mzOIvNXnSoQ+Ie/oLqYthmwKBgQDpinZ/kwE/aYRYgrODrPLrm8GBLxSmIDcd\n4Gk6kbS7u8aIbz5HLcSUw5UaQM5XdU1/Df/lwwg3h7WikIrUyRISjAVxJZX87fTG\nlEXYAG6RqCqfEBc3SqxhuXW1s7Uzsu8Zl8kzCP5DG0e/chnnHOOQhbIbCLGgJ1Sr\n10Bxy8/y+QKBgQCPrgEWHJzf2KST/5rLOGV4uR3+FdsDOTuweegCbY8s67srMnWB\nb7eom44P8WFbtbqLek1Uf1U6aNdVeV+2IqBxU8P/Esj9lfFhdlmrA4deu+Nm4kyt\nuRqfqaD+sQshNa3OWzKvS5cybrU/VnNfzsGtwWbH7j2gsTL9/FA2DgrcCQKBgCYC\nHOsCV8+kMp/dFa42dYqW3NVTfj7TO2UnYrjfgdST6OnHgRFAh5/WfOu65FojgytM\ncftI1IuFELCWaaHb348ZLsGNZm21pIK1GvDekSAviFA+5ChhhNCayGd8Cd+SHYvC\nwkIGEquFQxYLUd/lObwJpkT0E0SHYiZdb+WVUBCxAoGBAJpufCIRPFLwolcaEiFf\nDOlgAGsskndzgW6wj3XitcbZ+YL53J7xxiZjgKsekRpJSJESZi3wmSaDcRpq2Egd\nl0UsmyQvGjJHmbZf5IsrTFnwC4LxCYNeVZHQqkybAxRtyRvFBoYIz39Wih088g7m\nC+x0WHs2MEd22lQ7DWyVxF/G\n-----END PRIVATE KEY-----\n",
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