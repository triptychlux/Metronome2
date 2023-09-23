import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

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
  List<String> _availableTimeSignatures = ['1/4', '2/4', '3/4', '4/4', '5/4', '6/4', '7/4', '8/4'];

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
      });
    } else {
      final int beatDuration = (60000 ~/ _bpm);

      int beatCount = 0;
      final int beatsPerAccent = _getNumerator();
      _timer = Timer.periodic(Duration(milliseconds: beatDuration), (_) {
        if (beatCount % beatsPerAccent == 0) {
          _playMetronomeSound(isAccent: true);
        } else {
          _playMetronomeSound(isAccent: false);
        }
        beatCount++;
        if (beatCount >= beatsPerAccent) {
          beatCount = 0;
        }
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
    final List<int> timeSignatureParts = _availableTimeSignatures[_selectedTimeSignatureIndex]
        .split('/')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    if (timeSignatureParts.isNotEmpty && timeSignatureParts[0] != 0) {
      return timeSignatureParts[0];
    }
    return 4; // Default numerator
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
            Text('Tempo: $_bpm BPM', style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startStopMetronome,
              child: Text(_isPlaying ? 'Stop' : 'Start'),
            ),
            DropdownButton<String>(
              value: _availableTimeSignatures[_selectedTimeSignatureIndex],
              items: _availableTimeSignatures.map((String timeSignature) {
                return DropdownMenuItem<String>(
                  value: timeSignature,
                  child: Text(timeSignature),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimeSignatureIndex = _availableTimeSignatures.indexOf(newValue!);
                });
              },
            ),
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
          ],
        ),
      ),
    );
  }
}
