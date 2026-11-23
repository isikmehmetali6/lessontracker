import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/screens/home/tabs/timetable_layout.dart';

TimetableSlot<String> _s(String id, int start, int end) =>
    TimetableSlot(item: id, startMinutes: start, endMinutes: end);

Map<String, (int, int)> _layout(List<TimetableSlot<String>> slots) => {
      for (final p in layoutDay(slots)) p.slot.item: (p.lane, p.laneCount),
    };

void main() {
  test('çakışmayan dersler tam genişlik', () {
    expect(_layout([_s('a', 600, 690), _s('b', 780, 870)]), {
      'a': (0, 1),
      'b': (0, 1),
    });
  });

  test('aynı saatteki iki ders yan yana iki şerit', () {
    expect(_layout([_s('math', 600, 690), _s('linear', 600, 690)]).values,
        unorderedEquals([(0, 2), (1, 2)]));
  });

  test('zincirleme çakışmada boşalan şerit yeniden kullanılır', () {
    // a 9-11, b 10-12, c 11-13 → a ve c aynı şeride, küme 2 şerit
    final r = _layout([_s('a', 540, 660), _s('b', 600, 720), _s('c', 660, 780)]);
    expect(r['a'], (0, 2));
    expect(r['b'], (1, 2));
    expect(r['c'], (0, 2));
  });

  test('bitişik dersler çakışma sayılmaz', () {
    expect(_layout([_s('a', 600, 660), _s('b', 660, 720)]), {
      'a': (0, 1),
      'b': (0, 1),
    });
  });
}
