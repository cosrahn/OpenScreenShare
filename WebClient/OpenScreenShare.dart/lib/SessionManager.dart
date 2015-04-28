library SessionManager;

import 'dart:html';
import 'package:crypto/crypto.dart';
//import 'package:cryptoutils/cryptoutils.dart';
import 'package:OpenScreenShare/Comm.dart';

class Session {
 String aesKey;
 String downloadKey;
 num currentIndex;
 Session(this.aesKey, this.downloadKey);
}

class SessionManager extends Object with Comm {

  Element SessionKeyInputElement;
  // List of sessions. sessions has a name and keys with values
  Map<String, Session> SessionKeys;

  SessionManager(Element sks) {
    SessionKeyInputElement = sks;
    SessionKeys = new Map<String, Session>();
  }
  
  String doubleHASH(String key) {
    var first_sha256 = new SHA256();
    first_sha256.add(key.codeUnits);
    var first_digest = first_sha256.close();

    var second_sha256 = new SHA256();
    second_sha256.add(first_digest);
    List<int> digest = second_sha256.close();

    return CryptoUtils.bytesToHex(digest);

    /*
     * Later use shorter Base64 strings
     * issue: in URLs should removed '/' ( and maybe '+' and '=' to)
    String b64 = CryptoUtils.bytesToBase64(digest);
    b64.replaceAll(new RegExp(r"="), '');

    return b64;
     */
  }

  void addSessionKey(String sessionkey) {
    if ( ! SessionKeys.containsKey(sessionkey)) {
      String downloadKey = doubleHASH(sessionkey);
      print('add sessionkey: $sessionkey download key: $downloadKey');
      SessionKeys[sessionkey] = new Session(sessionkey, downloadKey);
      SessionKeys.forEach((String k, Session s) => print('Session Key $k / ${s.aesKey} download: ${s.downloadKey}'));      
    }
  }

  bool checkSessionKey(String sessionkey) {
    // e.g. 7f94d156-59f60aac-df28d0bd-e4c1f20a
    if(sessionkey.length == 35) {
      RegExp exp = new RegExp(r"^[a-f0-9]{8,8}-[a-f0-9]{8,8}-[a-f0-9]{8,8}-[a-f0-9]{8,8}$");
      if(exp.hasMatch(sessionkey)) {
        return true;
      }
    }
    return false;
  }
  
}
