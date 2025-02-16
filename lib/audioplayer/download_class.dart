import 'dart:io';
import 'package:Medito/constants/constants.dart';
import 'package:Medito/network/downloads/downloads_bloc.dart';
import 'package:Medito/network/session_options/session_opts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'player_utils.dart';

class _Download {
  bool isDownloading = false;
  late AudioFile _file;
  int? _received = 0, _total = 1;
  var downloadAmountListener = ValueNotifier<double>(0);

  _Download(AudioFile file) {
    _file = file;
  }

  bool isThisFile(AudioFile? file) {
    return file == _file;
  }

  Future<void> startDownloading(AudioFile file, MediaItem mediaItem) async {
    if (isDownloading) return;
    isDownloading = true;
    _file = file;

    await _downloadFileWithProgress(file, mediaItem);
  }

  bool isDownloadingMe(AudioFile? file) {
    if (!isDownloading) return false;
    if (!isThisFile(file)) return false;
    return isDownloading;
  }

  // returns false if file already exists on in file system
  // returns true otherwise, after file is downloaded
  Future<dynamic> _downloadFileWithProgress(
      AudioFile currentFile, MediaItem mediaItem) async {
    var filePath = (await getFilePath(currentFile.id ?? ''));
    var file = File(filePath);
    if (file.existsSync()) {
      unawaited(DownloadsBloc.saveFileToDownloadedFilesList(mediaItem));
      isDownloading = false;
      return false;
    } else {
      file.createSync();
    }

    var url = HTTPConstants.BASE_URL_OLD + 'assets/' + (currentFile.id ?? '');
    var request = http.Request('GET', Uri.parse(url));
    request.headers[HttpHeaders.authorizationHeader] = HTTPConstants.CONTENT_TOKEN_OLD;
    var _response = await http.Client().send(request);
    _total = _response.contentLength ?? 0;
    _received = 0;
    var _bytes = <int>[];

    _response.stream.listen((value) {
      _bytes.addAll(value);
      if (_received != null) {
        _received = _received! + value.length;
      }

      var progress = 0.0;
      if (_received == null) {
        progress = 0;
        print('Unexpected State of downloading');
        _received;
        if (_total == null) {
          http.Client()
              .send(http.Request('GET', Uri.parse(currentFile.id ?? '')))
              .then((value) => _response = value);
          _total = _response.contentLength ?? 0;
          _received = _bytes.length;
        }
      } else {
        if (_received != null && _total != null) {
          progress = _received! / _total!;
        }
      }
      // ignore: unnecessary_cast
      downloadAmountListener.value = progress as double; // it is necessary
    }).onDone(() async {
      try {
        await file.writeAsBytes(_bytes);
        await DownloadsBloc.saveFileToDownloadedFilesList(mediaItem);
        print('Saved New: ' + file.path);
        isDownloading = false;
      } catch (e, st) {
        unawaited(
          Sentry.captureException(
            e,
            stackTrace: st,
            hint: Hint.withMap(
              {'message': 'onDone, writing file failed, ${file.path}'},
            ),
          ),
        );
      }

      return;
    });
  }

  double getProgress() {
    if (_total == null) {
      http.StreamedResponse? _throwResponse;
      http.Client()
          .send(http.Request('GET', Uri.parse(_file.id ?? '')))
          .then((value) => _throwResponse = value);
      _total = _throwResponse?.contentLength ?? 0;
    }

    return (_received != null && _total != null) ? (_received! / _total!) : 0;
  }
}

class DownloadSingleton {
  _Download? _download;

  DownloadSingleton(AudioFile? file) {
    if (file == null) return;
    _download = _Download(file);
  }

  bool isValid() {
    return _download != null;
  }

  bool isDownloadingSomething() {
    if (_download == null) return false;
    return _download?.isDownloading ?? false;
  }

  bool isDownloadingMe(AudioFile? file) {
    if (_download == null) return false;
    return _download?.isDownloadingMe(file) ?? false;
  }

  double getProgress(AudioFile file) {
    if (_download == null) return -1;
    if (isDownloadingMe(file)) return _download?.getProgress() ?? 0.0;

    return -1;
  }

  bool start(AudioFile file, MediaItem mediaItem) {
    if (_download == null) return false;
    if (_download?.isDownloadingMe(file) ?? false) return true;
    if (isDownloadingSomething()) return false;

    if (_download?.isThisFile(file) ?? false) {
      _download?.startDownloading(file, mediaItem);

      return true;
    }
    _download = _Download(file);
    _download?.startDownloading(file, mediaItem);

    return true;
  }

  ValueNotifier<double>? returnNotifier() {
    return _download?.downloadAmountListener;
  }
}
