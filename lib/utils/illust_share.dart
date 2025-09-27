import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareIllustImage({
  required BuildContext context,
  required Illusts illust,
  required int index,
  Rect? origin,
}) async {
  final url = _resolveShareUrl(illust, index);
  if (url == null || url.isEmpty) {
    BotToast.showText(text: I18n.of(context).failed);
    return;
  }

  try {
    final cacheManager = pixivCacheManager;
    if (cacheManager == null) {
      LPrinter.d('pixivCacheManager is not initialized');
      BotToast.showText(text: I18n.of(context).failed);
      return;
    }

    final fileInfo = await cacheManager.getFileFromCache(url) ?? await cacheManager.downloadFile(url);
    final sourceFile = fileInfo.file;

    final tempDir = await getTemporaryDirectory();
    final shareDir = Directory(p.join(tempDir.path, 'share_cache'));
    if (!await shareDir.exists()) {
      await shareDir.create(recursive: true);
    }

    final fileExtension = _resolveExtension(sourceFile.path, url);
    final targetPath = p.join(
      shareDir.path,
      '${p.basenameWithoutExtension(sourceFile.path)}$fileExtension',
    );

    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    } else {
      await targetFile.create(recursive: true);
    }
    await sourceFile.copy(targetPath);

    // await Share.shareXFiles([XFile(targetPath)], sharePositionOrigin: origin);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(targetPath)],
      sharePositionOrigin: origin ?? Rect.fromLTRB(0, 0, 0, 1),
    ));
  } catch (e, stackTrace) {
    LPrinter.d(e);
    LPrinter.d(stackTrace);
    BotToast.showText(text: I18n.of(context).failed);
  }
}

String? _resolveShareUrl(Illusts illust, int index) {
  if (illust.type == 'ugoira') {
    return illust.imageUrls.large;
  }

  if (illust.pageCount <= 1 || illust.metaPages.isEmpty) {
    return illust.type == 'manga' ? illust.managaDetailUrl : illust.illustDetailUrl;
  }

  if (index < 0 || index >= illust.metaPages.length) {
    return null;
  }

  return illust.type == 'manga' ? illust.managaDetailImageUrl(index) : illust.illustDetailImageUrl(index);
}

String _resolveExtension(String filePath, String url) {
  var extension = p.extension(filePath);
  if (extension.isEmpty) {
    extension = p.extension(Uri.parse(url).path);
  }
  return extension.isEmpty ? '.jpg' : extension;
}
