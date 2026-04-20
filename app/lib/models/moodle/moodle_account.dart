/// Moodle hesap modeli — bir öğrencinin bağladığı tek bir Moodle instance'ını temsil eder.
/// Token bu modelde saklanmaz; flutter_secure_storage'da tutulur.
class MoodleAccount {
  final String id; // UUID — uygulama içi kimlik

  /// Üniversitenin Moodle base URL'i, örn. https://ninova.itu.edu.tr
  final String baseUrl;

  /// Moodle site adı — login sonrası core_webservice_get_site_info'dan alınır
  final String siteTitle;

  /// Moodle kullanıcı adı — yalnızca görüntüleme amaçlı
  final String username;

  /// Öğrencinin Moodle'daki tam adı
  final String fullName;

  /// Profil avatarı URL'i (nullable)
  final String? avatarUrl;

  /// Son başarılı senkronizasyon zamanı
  final DateTime lastSynced;

  /// Hesap aktif mi? (false = devre dışı bırakıldı ama silinmedi)
  final bool isActive;

  const MoodleAccount({
    required this.id,
    required this.baseUrl,
    required this.siteTitle,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.lastSynced,
    this.isActive = true,
  });

  MoodleAccount copyWith({
    String? id,
    String? baseUrl,
    String? siteTitle,
    String? username,
    String? fullName,
    String? avatarUrl,
    DateTime? lastSynced,
    bool? isActive,
  }) {
    return MoodleAccount(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      siteTitle: siteTitle ?? this.siteTitle,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSynced: lastSynced ?? this.lastSynced,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'baseUrl': baseUrl,
        'siteTitle': siteTitle,
        'username': username,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
        'lastSynced': lastSynced.toIso8601String(),
        'isActive': isActive ? 1 : 0,
      };

  factory MoodleAccount.fromMap(Map<String, dynamic> map) => MoodleAccount(
        id: map['id'] as String,
        baseUrl: map['baseUrl'] as String,
        siteTitle: map['siteTitle'] as String,
        username: map['username'] as String,
        fullName: map['fullName'] as String,
        avatarUrl: map['avatarUrl'] as String?,
        lastSynced: DateTime.parse(map['lastSynced'] as String),
        isActive: (map['isActive'] as int) == 1,
      );

  @override
  String toString() =>
      'MoodleAccount(id: $id, siteTitle: $siteTitle, username: $username)';
}
