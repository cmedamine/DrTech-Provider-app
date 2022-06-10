import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:share/share.dart';

class ShareManager {
  static void shearEngineer(id, name, service) {
    String paylaod = [
      LanguageManager.getText(173),
      name,
      Globals.shareUrl + "?eng_id=$id",
      LanguageManager.getText(174)
    ].join("\n");

    Share.share(paylaod, subject: service);
  }

  static void shearService(id, name) {
    String paylaod = [
      LanguageManager.getText(266),
      name,
      Globals.shareUrl + "?service_id=$id",
      LanguageManager.getText(174)
    ].join("\n");

    Share.share(paylaod, subject: name);
  }
}
