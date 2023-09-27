import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turn2draw/config/http.dart';

class SessionShareModal extends StatelessWidget {
  const SessionShareModal({super.key, this.sessionId = ''});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Let others scan this QR-Code from the home screen to join this lobby',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24.0),
          SizedBox.square(
            dimension: MediaQuery.of(context).size.width * 0.4,
            child: PrettyQrView.data(
              data: sessionId,
              decoration: const PrettyQrDecoration(),
            ),
          ),
          const Spacer(),
          Text(
            'or share a link that connects other to this lobby',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () => Share.share(
              [httpBaseUrl, 'session/$sessionId'].join('/'),
              subject: 'Let\'s draw together!',
            ),
            child: const Text('Share Invite'),
          ),
        ],
      ),
    );
  }
}
