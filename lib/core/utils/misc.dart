import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:plain_notification_token/plain_notification_token.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toolbox/core/extension/uint8list.dart';

import 'platform.dart';

Future<bool> shareFiles(BuildContext context, List<String> filePaths) async {
  for (final filePath in filePaths) {
    if (!await File(filePath).exists()) {
      return false;
    }
  }
  var text = '';
  if (filePaths.length == 1) {
    text = filePaths.first.split('/').last;
  } else {
    text = '${filePaths.length} ${S.of(context)!.files}';
  }
  final xfiles = filePaths.map((e) => XFile(e)).toList();
  await Share.shareXFiles(xfiles, text: 'ServerBox -> $text');
  return filePaths.isNotEmpty;
}

void copy(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

Future<String?> pickOneFile() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any);
  return result?.files.single.path;
}

Future<String?> getToken() async {
  if (isIOS) {
    final plainNotificationToken = PlainNotificationToken();
    plainNotificationToken.requestPermission();

    // If you want to wait until Permission dialog close,
    // you need wait changing setting registered.
    await plainNotificationToken.onIosSettingsRegistered.first;
    return await plainNotificationToken.getToken();
  }
  return null;
}

Future<void> loadFontFile(String localPath, String name) async {
  var fontLoader = FontLoader(name);
  fontLoader.addFont(File(localPath).readAsBytes().byteData);
  await fontLoader.load();
}
