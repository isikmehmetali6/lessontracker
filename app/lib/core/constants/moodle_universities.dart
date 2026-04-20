/// Önceden tanımlı Moodle üniversite listesi.
/// Kullanıcı arama kutusundan seçebilir veya kendi URL'ini girebilir.
class MoodleUniversity {
  final String name;
  final String baseUrl;
  final String? countryCode;

  const MoodleUniversity(this.name, this.baseUrl, {this.countryCode = 'TR'});
}

const kMoodleUniversities = [
  MoodleUniversity('İTÜ Ninova', 'https://ninova.itu.edu.tr'),
  MoodleUniversity('ODTÜ Class', 'https://odtuclass.metu.edu.tr'),
  MoodleUniversity('Boğaziçi Üniversitesi', 'https://moodle.boun.edu.tr'),
  MoodleUniversity('Hacettepe Üniversitesi', 'https://moodle.hacettepe.edu.tr'),
  MoodleUniversity('Ankara Üniversitesi', 'https://moodle.ankara.edu.tr'),
  MoodleUniversity('Yıldız Teknik Üniversitesi', 'https://moodle.yildiz.edu.tr'),
  MoodleUniversity('Gazi Üniversitesi', 'https://moodle.gazi.edu.tr'),
  MoodleUniversity('Ege Üniversitesi', 'https://moodle.ege.edu.tr'),
  MoodleUniversity('Çukurova Üniversitesi', 'https://moodle.cu.edu.tr'),
  MoodleUniversity('İstanbul Üniversitesi', 'https://moodle.istanbul.edu.tr'),
  MoodleUniversity('Anadolu Üniversitesi', 'https://moodle.anadolu.edu.tr'),
  MoodleUniversity('Dokuz Eylül Üniversitesi', 'https://moodle.deu.edu.tr'),
  MoodleUniversity('Erciyes Üniversitesi', 'https://moodle.erciyes.edu.tr'),
  MoodleUniversity('Sakarya Üniversitesi', 'https://moodle.sakarya.edu.tr'),
  MoodleUniversity('Selçuk Üniversitesi', 'https://moodle.selcuk.edu.tr'),
  MoodleUniversity('Kocaeli Üniversitesi', 'https://moodle.kocaeli.edu.tr'),
  MoodleUniversity('Pamukkale Üniversitesi', 'https://moodle.pau.edu.tr'),
  MoodleUniversity('Karadeniz Teknik Üniversitesi', 'https://moodle.ktu.edu.tr'),
  MoodleUniversity('Fırat Üniversitesi', 'https://moodle.firat.edu.tr'),
  MoodleUniversity('İnönü Üniversitesi', 'https://moodle.inonu.edu.tr'),
  MoodleUniversity('Eskişehir Osmangazi Üniversitesi', 'https://moodle.ogu.edu.tr'),
  MoodleUniversity('Gebze Teknik Üniversitesi', 'https://moodle.gtu.edu.tr'),
  MoodleUniversity('İzmir Yüksek Teknoloji Enstitüsü', 'https://moodle.iyte.edu.tr'),
  MoodleUniversity('TOBB ETÜ', 'https://moodle.etu.edu.tr'),
  MoodleUniversity('Atılım Üniversitesi', 'https://moodle.atilim.edu.tr'),
  MoodleUniversity('Bahçeşehir Üniversitesi', 'https://moodle.bau.edu.tr'),
  MoodleUniversity('Bilkent Üniversitesi', 'https://moodle.bilkent.edu.tr'),
  MoodleUniversity('Koç Üniversitesi', 'https://moodle.ku.edu.tr'),
  MoodleUniversity('Sabancı Üniversitesi', 'https://moodle.sabanciuniv.edu.tr'),
  MoodleUniversity('Özyeğin Üniversitesi', 'https://moodle.ozyegin.edu.tr'),
];
