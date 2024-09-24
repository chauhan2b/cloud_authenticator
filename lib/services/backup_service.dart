import '../models/user_secret.dart';

class BackupService {
  // helper method when importing secrets
  UserSecret parseOtpUrl(String uri) {
    final parsedUri = Uri.parse(uri);
    final pathSegments = parsedUri.pathSegments;
    final queryParameters = parsedUri.queryParameters;

    final issuerAndEmail = pathSegments.last.split(':');
    final issuer = issuerAndEmail.first;
    final email = issuerAndEmail.length > 1 ? issuerAndEmail.last : '';

    return UserSecret(
      id: '', // will be set later when saving to firestore
      secret: queryParameters['secret']!,
      issuer: issuer,
      email: email,
    );
  }

  // helper method when exporting secrets
  String generateOtpUri(UserSecret secret) {
    final encodedIssuer = Uri.encodeComponent(secret.issuer);
    final encodedEmail = Uri.encodeComponent(secret.email);
    return 'otpauth://totp/$encodedIssuer:$encodedEmail?secret=${secret.secret}&issuer=$encodedIssuer';
  }
}
