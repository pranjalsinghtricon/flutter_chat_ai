const amplifyconfig = '''{
  "UserAgent": "aws-amplify/cli",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "eu-west-1_ge1RMFrf6",
            "AppClientId": "1pii8vb7lqo9j6st8p9ke8rjsd",
            "Region": "eu-west-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "usernameAttributes": ["email"],
            "signupAttributes": ["email", "name"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": []
            },
            "OAuth": {
              "WebDomain": "idp.dev.iris.informa.com",
              "AppClientId": "1pii8vb7lqo9j6st8p9ke8rjsd",
              "SignInRedirectURI": "com.informa.elysia.dev://auth",
              "SignOutRedirectURI": "com.informa.elysia.dev://logout",
              "Scopes": [
                "openid",
                "iris.apis/ai",
                "email"
              ]
            }
          }
        }
      }
    }
  }
}''';
