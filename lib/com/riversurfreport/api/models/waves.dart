import 'browse_wave.dart';

class Waves {
  List<BrowseWave> waves;

  Waves({this.waves});

  factory Waves.fromJson(List<dynamic> list) {
    List<BrowseWave> wavesList = list.map((i) => BrowseWave.fromJson(i)).toList();

    return Waves(waves: wavesList);
  }
}