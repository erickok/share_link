import 'package:flutter/material.dart';
import 'package:share_link/share_link.dart';
import 'package:share_link/share_result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Share link'),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(32),
          child: const ShareButton(),
        ),
      ),
    );
  }
}

class ShareButton extends StatefulWidget {
  const ShareButton({super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  ShareResult? _shareResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          child: const Text('Share https://2312.nl'),
          onPressed: () async {
            final result = await ShareLink.shareUri(Uri.parse('https://2312.nl'), subject: '2312.nl website');
            setState(() {
              _shareResult = result;
            });
          },
        ),
        if (_shareResult != null) const SizedBox(height: 16),
        if (_shareResult != null)
          Text(
            _shareResult!.success == true
                ? "${_shareResult!.uri}\nwas shared to\n${_shareResult!.target}"
                : 'Link not shared',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
