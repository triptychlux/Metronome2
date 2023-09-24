import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MetronomeApp());
}

class MetronomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metronome',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0x00000000)),
      home: MetronomeScreen(),
    );
  }
}

class MetronomeScreen extends StatefulWidget {
  @override
  _MetronomeScreenState createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int _bpm = 120;
  bool _isPlaying = false;
  late AudioPlayer _audioPlayer;
  Timer? _timer;
  int _selectedTimeSignatureIndex = 0;
  List<String> _availableTimeSignatures = ['4', '1', '2', '3', '5', '6', '7', '8'];
  bool _accentBulbsVisible = false;
  bool _regularBulbsVisible = false;


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startStopMetronome() {
    if (_isPlaying) {
      _timer?.cancel();
      setState(() {
        _isPlaying = false;
        _accentBulbsVisible = false;
        _regularBulbsVisible = false;
      });
    } else {
      final int beatDuration = (60000 ~/ _bpm);

      int beatCount = 0;
      final int beatsPerAccent = _getNumerator();
      _timer = Timer.periodic(Duration(milliseconds: beatDuration), (_) {
        setState(() {
          if (beatCount % beatsPerAccent == 0) {
            _accentBulbsVisible = true;
            _regularBulbsVisible = false;
            _playMetronomeSound(isAccent: true);
          } else {
            _accentBulbsVisible = false;
            _regularBulbsVisible = true;
            _playMetronomeSound(isAccent: false);
          }
          beatCount++;
          if (beatCount >= beatsPerAccent) {
            beatCount = 0;
          }
        });
      });
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _playMetronomeSound({bool isAccent = false}) async {
    if (isAccent) {
      await _audioPlayer.play(AssetSource('click1ac.wav'));
    } else {
      await _audioPlayer.play(AssetSource('click1.wav'));
    }
  }

  int _getNumerator() {
    final List<
        int> timeSignatureParts = _availableTimeSignatures[_selectedTimeSignatureIndex]
        .split('/')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    if (timeSignatureParts.isNotEmpty && timeSignatureParts[0] != 0) {
      return timeSignatureParts[0];
    }
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metronome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _startStopMetronome,
              child: Text(_isPlaying ? 'Stop' : 'Start'),
            ),
            SizedBox(height: 50),

            Text('Tempo: $_bpm BPM', style: TextStyle(fontSize: 18, color: Colors.white)),
            Slider(
              value: _bpm.toDouble(),
              min: 40,
              max: 200,
              onChanged: (value) {
                setState(() {
                  _bpm = value.round();
                });
              },
            ),
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[



                Text('Akcent co:', style: TextStyle(fontSize: 18, color: Colors.white)),
              ],
            ),
            DropdownButton<String>(
              value: _availableTimeSignatures[_selectedTimeSignatureIndex],
              items: _availableTimeSignatures.map((String timeSignature) {
                return DropdownMenuItem<String>(
                  value: timeSignature,
                  child: Text(timeSignature, style: TextStyle(fontSize: 18, color: Colors.blueAccent)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimeSignatureIndex =
                      _availableTimeSignatures.indexOf(newValue!);
                });
              }),
            AnimatedOpacity(
              opacity: _isPlaying && _accentBulbsVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 10),
              child: FaIcon(
                FontAwesomeIcons.music,
                color: Colors.yellow,
                size: 32.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
