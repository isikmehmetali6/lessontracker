import 'package:supabase_flutter/supabase_flutter.dart' show User;

/// Backend'den bağımsız oturum kullanıcısı. UI yalnızca bu modeli görür.
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
  });

  factory AppUser.fromSupabase(User user) {
    final name = user.userMetadata?['name'];
    return AppUser(
      uid: user.id,
      email: user.email,
      displayName: name is String && name.isNotEmpty ? name : null,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}
