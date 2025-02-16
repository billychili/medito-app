import 'package:Medito/repositories/repositories.dart';
import 'package:Medito/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Medito/models/models.dart';

final audioDownloaderProvider =
    ChangeNotifierProvider<AudioDownloaderProvider>((ref) {
  return AudioDownloaderProvider(ref);
});

class AudioDownloaderProvider extends ChangeNotifier {
  ChangeNotifierProviderRef<AudioDownloaderProvider> ref;
  AudioDownloaderProvider(this.ref);
  Map<String, double> downloadingProgress = {};
  Map<String, AUDIO_DOWNLOAD_STATE> audioDownloadState = {};
  Future<void> downloadMeditationAudio(
    MeditationModel meditationModel,
    MeditationFilesModel file,
  ) async {
    var fileName =
        '${meditationModel.id}-${file.id}${getFileExtension(file.path)}';
    try {
      final downloadAudio = ref.read(downloaderRepositoryProvider);
      audioDownloadState[fileName] = AUDIO_DOWNLOAD_STATE.DOWNLOADIING;
      await downloadAudio.downloadFile(
        file.path,
        name: fileName,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadingProgress[fileName] = (received / total * 100);
            print(downloadingProgress);
            notifyListeners();
          }
        },
      );
      downloadingProgress.remove(fileName);
      audioDownloadState[fileName] = AUDIO_DOWNLOAD_STATE.DOWNLOADED;
      notifyListeners();
    } catch (e) {
      audioDownloadState[fileName] = AUDIO_DOWNLOAD_STATE.DOWNLOAD;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMeditationAudio(String fileName) async {
    final downloadAudio = ref.read(downloaderRepositoryProvider);
    await downloadAudio.deleteDownloadedFile(fileName);
    audioDownloadState[fileName] = AUDIO_DOWNLOAD_STATE.DOWNLOAD;
    notifyListeners();
  }

  Future<String?> getMeditationAudio(String fileName) async {
    final downloadAudio = ref.read(downloaderRepositoryProvider);
    var audioPath = await downloadAudio.getDownloadedFile(fileName);
    audioDownloadState[fileName] = audioPath != null
        ? AUDIO_DOWNLOAD_STATE.DOWNLOADED
        : AUDIO_DOWNLOAD_STATE.DOWNLOAD;
    notifyListeners();

    return audioPath;
  }
}

enum AUDIO_DOWNLOAD_STATE {
  DOWNLOAD,
  DOWNLOADIING,
  DOWNLOADED,
}
