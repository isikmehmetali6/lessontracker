/// Haftalık programda aynı güne düşen ve saatleri çakışan dersleri yan yana
/// "şeritlere" dağıtır (UI_FIX_PLAN U9). Saf fonksiyon — widget'tan bağımsız
/// test edilebilir.
class TimetableSlot<T> {
  const TimetableSlot({
    required this.item,
    required this.startMinutes,
    required this.endMinutes,
  });

  final T item;
  final int startMinutes;
  final int endMinutes;
}

class TimetablePlacement<T> {
  const TimetablePlacement(this.slot, this.lane, this.laneCount);

  final TimetableSlot<T> slot;

  /// 0 tabanlı şerit indeksi.
  final int lane;

  /// Bu bloğun içinde bulunduğu çakışma kümesindeki toplam şerit sayısı.
  final int laneCount;
}

/// Tek bir günün bloklarını yerleştirir. Birbiriyle (dolaylı da olsa)
/// çakışan bloklar bir küme oluşturur; küme içindeki her blok ilk boş
/// şeride yerleşir ve kümedeki tüm bloklar aynı genişliği paylaşır.
List<TimetablePlacement<T>> layoutDay<T>(List<TimetableSlot<T>> slots) {
  final sorted = [...slots]
    ..sort((a, b) {
      final byStart = a.startMinutes.compareTo(b.startMinutes);
      return byStart != 0 ? byStart : b.endMinutes.compareTo(a.endMinutes);
    });

  final result = <TimetablePlacement<T>>[];
  var cluster = <(TimetableSlot<T>, int)>[];
  var laneEnds = <int>[];
  var clusterEnd = -1;

  void flush() {
    final count = laneEnds.length;
    for (final (slot, lane) in cluster) {
      result.add(TimetablePlacement(slot, lane, count));
    }
    cluster = [];
    laneEnds = [];
    clusterEnd = -1;
  }

  for (final slot in sorted) {
    if (cluster.isNotEmpty && slot.startMinutes >= clusterEnd) flush();
    var lane = laneEnds.indexWhere((end) => end <= slot.startMinutes);
    if (lane == -1) {
      lane = laneEnds.length;
      laneEnds.add(slot.endMinutes);
    } else {
      laneEnds[lane] = slot.endMinutes;
    }
    cluster.add((slot, lane));
    if (slot.endMinutes > clusterEnd) clusterEnd = slot.endMinutes;
  }
  if (cluster.isNotEmpty) flush();
  return result;
}
