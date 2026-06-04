import 'package:audioplayers/audioplayers.dart';

class RingtoneService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playRingtone() async {
    try {
      print("🔊 Playing ringtone...");

      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);

      await _player.play(AssetSource('sounds/lonely_in_gorgeous_ins.mp3'));
    } catch (e) {
      print("❌ Ringtone error: $e");
    }
  }

  Future<void> stopRingtone() async {
    await _player.stop();
  }
}
