// import 'package:googleapis_auth/auth_io.dart';

// class GetServerKey {
//   Future<String> getServerKeyToken() async {
//     final scopes = [
//       'https://www.googleapis.com/auth/userinfo.email',
//       'https://www.googleapis.com/auth/userinfo.profile',
//     ];
//     final client = await clientViaServiceAccount(
//       ServiceAccountCredentials.fromJson({
//         "type": "service_account",
//         "project_id": "signup-login-page-4dc42",
//         "private_key_id": "75f56e9160a42d224c43b92573a4cffc8bf57be3",
//         "private_key":
//             "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCYMj/FzOrIN8c1\nf02th2sQjlxP7XIcZPMU8TflhbCpCmMg5wHcXpFmvraviCer93r8uSECJ+ZOD5T4\nngR/PVQAH8OD5VZqZ26nPRNlPjOBjcXIRmvX79mble/MyenlSsG1XLhUeMe2HmSU\nNcrMqcLWWlD/oTxsyFbkBDqirHWHM+CRiwCqusPNG6IQDKG76K6GBbBdCX8Zh+tE\nmm6NWM1yvE4eAidrbilAlaLSBEdpDYhmyFHqNl3S7Qt8Tqm/tBU7SydpbSzmDsYa\nwkaeA73EGetqpBnkIedtBBETpLpDq0zQoGPEmbyjf+zvsxnpyLD6GaiZSezbAKTs\nVjNDj3IzAgMBAAECggEAFuGVwTTzEUHYLbyjXtTZQvvGzhoVH0a1XZnRp6ycksq7\nJ32uGRrl7Ov8MXycoO0hLNs0/ArSmZFxz0ThHoiyVx3EulDMLU1lOeMOm5h+jC+B\nI4B5gyqN7ScIDnecC1BcugROuXMPwgYPZKbdA+hRIK0jDfjddD9UV43Oi5lg8VVJ\nxyA6gP8P+aokEFFbqwcDrjJXCKS5YK0HQlCFWVzDbMGRlj3JnmsCFAbPobCipeSM\nMIHpwkDPkhZKAULHfmJR2SnF6Rf/a8ZJIyYd7eB4xveIHvbWB8OAIdYpUMkIQ5WD\ncDTxF9maRUFO8vyXl7xS2IAXqwsSAqMywY/wDFmVnQKBgQDG/BlvaK8QE1V8TaeF\nfg2lrMp+hHUG2Sy5eBP8laee9aXSDOGefW50HsnTzIl4m4X6PLO/6bU7uee61Wrq\n4nPYIfVj0OJb8LNIB+2aA+F4xRAc9NkS38634yYOOc9lX9XYEeO03R+Rt0tafQjQ\n2DZ8Y+R2H68Z3juhSkvCKFvffQKBgQDDziDaqByFpPWIjdfjSFbOC4LL0ExBaNbW\ncdSsgkVAg/tjnAPJ/RC54a3ILM5GrRb68CrUjkrye713kWCj+zNRw5lDq7g5cZzb\nlfheHj+Gp8FngUzQV9KlGrc2Dylp4pIfRBg93D00n0PiJCQbJjZCpdVequIAYcDZ\n4rFhSdunbwKBgFrXNkltMhaVrP4deW/w9wv+kUcm80IYHVninsU+ERL5tCTrqoiv\nXKB4ec1OYCgGYCi4U5s2d313xnm9+pyWmyo9foh+EQjGHyKwM+GPCf0Xgd6mTP9X\n20iJ05LFA5CVKswEhr7IACSG2EjMMh0dx+oLtH3Uwxx9Hx3oDCPsRt0FAoGAEEAI\nK/1tuI2zLu0OsLctNRZxeXbFDVylD9EMpHB/TNZnQ6IMEnRlMfgP0yAc0nLFCHhs\nJY3VnIA2fjjbe2B6ptuD2cDjnijWqsasgSsjfIppm6x4coYHXlp0QBFMD5SVKfEd\nzex8S+S33om/UV1/fVKD/cJS1VNHjQ2qSPe3OhMCgYEAuY4COGLeFVRlM1CbOzGQ\nJlYxnHTmKIXiM9SHG/O5yStWMYFSCyDI3srRB23aOiYzGsDlXgQ3kXeGfSeeGf6K\nI0wYb6SZt2aLbkF5T3Kd+3ztU43VppsKEFODjf2wLoD+8VGYHEaCCEgVS05IPYEj\nMSG/2HxJzn2X8SGeViFz3V0=\n-----END PRIVATE KEY-----\n",
//         "client_email":
//             "firebase-adminsdk-fbsvc@signup-login-page-4dc42.iam.gserviceaccount.com",
//         "client_id": "101007297164604601402",
//         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//         "token_uri": "https://oauth2.googleapis.com/token",
//         "auth_provider_x509_cert_url":
//             "https://www.googleapis.com/oauth2/v1/certs",
//         "client_x509_cert_url":
//             "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40signup-login-page-4dc42.iam.gserviceaccount.com",
//         "universe_domain": "googleapis.com",
//       }),
//       scopes,
//     );
//     final accressSercerKey = client.credentials.accessToken.data;
//     return accressSercerKey;
//   }
// }
