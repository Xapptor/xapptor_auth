import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/initial_values.dart';

Future<String> gak({
  required String n,
  required String o,
}) async {
  DocumentSnapshot o_m =
      await FirebaseFirestore.instance.collection("metadata").doc(o).get();
  Map<String, dynamic> o_d = o_m.data() as Map<String, dynamic>;
  String ak = "";
  String p_n = "";

  if (UniversalPlatform.isAndroid) {
    p_n = "android";
  } else if (UniversalPlatform.isIOS) {
    p_n = "ios";
  } else if (UniversalPlatform.isWeb) {
    p_n = "web";
  }

  ak = o_d["keys"][n][p_n];

  if (d_m_f_au != null) {
    ak = d_m_f_au!(
      m: ak,
      k: e_k_au,
    );
  }

  return ak;
}
