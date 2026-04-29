import 'dart:typed_data';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareImage(Uint8List imageBytes, {String? fileName}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${fileName ?? 'inspiration_card.png'}');
    await file.writeAsBytes(imageBytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Faith Inspire',
      ),
    );
  }
}
