import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcReadingScreen extends StatefulWidget {
  @override
  _NfcReadingScreenState createState() => _NfcReadingScreenState();
}

class _NfcReadingScreenState extends State<NfcReadingScreen> {
  @override
  void initState() {
    super.initState();
    _startNfcReading();
  }

  void _startNfcReading() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        // Assuming the NFC tag contains the user ID as a string in the NDEF record.
        var ndef = Ndef.from(tag);
        if (ndef == null || ndef.cachedMessage == null) {
          return;
        }
        var record = ndef.cachedMessage!.records.first;
        String payload = String.fromCharCodes(record.payload).substring(3); // Remove language code
        NfcManager.instance.stopSession();
        Navigator.pop(context, payload);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('NFC not available on this device.'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Reading'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nfc,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Waiting for NFC tag...',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
