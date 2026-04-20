/// Moodle'dan gelen bir mesajı temsil eder.
/// core_message_get_messages API'sinden türetilir.
class MoodleMessage {
  /// Mesaj ID
  final int id;

  /// Hangi MoodleAccount'a ait
  final String accountId;

  /// Gönderen kullanıcı ID'si
  final int senderId;

  /// Gönderen isim
  final String senderName;

  /// Gönderen profil resmi (nullable)
  final String? senderAvatar;

  /// Mesaj içeriği (HTML olabilir)
  final String message;

  /// Mesaj konusu (nullable)
  final String? subject;

  /// Mesaj zamanı
  final DateTime timestamp;

  /// Okundu mu?
  final bool isRead;

  /// İlgili ders ID'si (nullable)
  final int? courseId;

  const MoodleMessage({
    required this.id,
    required this.accountId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    this.subject,
    required this.timestamp,
    this.isRead = false,
    this.courseId,
  });

  /// Mesaj kısa önizlemesi (HTML tag'lerini temizle)
  String get preview {
    final cleaned = message
        .replaceAll(RegExp(r'<[^>]*>'), '') // HTML tag kaldır
        .replaceAll(RegExp(r'\s+'), ' ')     // Çoklu boşluk birleştir
        .trim();
    return cleaned.length > 100 ? '${cleaned.substring(0, 100)}...' : cleaned;
  }

  /// Ne kadar önce gönderildi
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}s önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
  }

  MoodleMessage markAsRead() => MoodleMessage(
        id: id,
        accountId: accountId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        message: message,
        subject: subject,
        timestamp: timestamp,
        isRead: true,
        courseId: courseId,
      );

  /// Moodle API JSON'undan oluştur
  factory MoodleMessage.fromApiJson(
    Map<String, dynamic> json,
    String accountId,
  ) {
    final ts = json['timecreated'] as int? ?? 0;
    return MoodleMessage(
      id: json['id'] as int,
      accountId: accountId,
      senderId: json['useridfrom'] as int? ?? 0,
      senderName: json['userfromfullname'] as String? ?? 'Bilinmeyen',
      senderAvatar: json['profileimageurl'] as String?,
      message: json['text'] as String? ?? json['smallmessage'] as String? ?? '',
      subject: json['subject'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
      isRead: (json['timeread'] as int? ?? 0) > 0,
    );
  }

  @override
  String toString() =>
      'MoodleMessage(id: $id, from: $senderName, preview: ${preview.substring(0, preview.length.clamp(0, 30))})';
}
