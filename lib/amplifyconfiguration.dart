import 'package:flutter_dotenv/flutter_dotenv.dart';

String get amplifyconfig => '''{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "CognitoUserPool": {
          "Default": {
            "PoolId": "${dotenv.env['COGNITO_USERPOOL_ID']}",
            "AppClientId": "${dotenv.env['COGNITO_WEBCLIENT_ID']}",
            "Region": "${dotenv.env['COGNITO_REGION']}"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "${dotenv.env['COGNITO_DOMAIN']}",
              "AppClientId": "${dotenv.env['COGNITO_WEBCLIENT_ID']}",
              "SignInRedirectURI": "${dotenv.env['COGNITO_REDIRECT_SIGNIN']}",
              "SignOutRedirectURI": "${dotenv.env['COGNITO_REDIRECT_SIGNOUT']}",
              "Scopes": ["openid", "profile", "email", "offline_access", "User.Read"]
            }
          }
        }
      }
    }
  }
}''';
