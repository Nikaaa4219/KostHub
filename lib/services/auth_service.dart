import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_session/d_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account.dart';

class AuthSource {
  // === REGISTER / SIGN UP ===
  // === API CALL ===
  // Berkomunikasi dengan Firebase Auth untuk membuat kredensial baru
  static Future<String> signUp(
      String name, String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final account = Account(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phoneNumber: '',
        kycStatus: 'UNVERIFIED',
      );

      await FirebaseFirestore.instance
          .collection('User')
          .doc(account.uid)
          .set(account.toJson());

      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Kata sandi yang diberikan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Akun untuk email tersebut sudah terdaftar.';
      }
      log(e.toString());
      return "Terjadi kesalahan saat mendaftar. Silakan coba lagi.";
    } catch (e) {
      log(e.toString());
      return "Terjadi kesalahan yang tidak diketahui.";
    }
  }

  // === LOGIN ===
  // === API CALL ===
  // Memverifikasi kredensial user melalui Firebase Auth
  static Future<String> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final accountDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(credential.user!.uid)
          .get();

      if (accountDoc.exists) {
        Map<String, dynamic> data = accountDoc.data()!;

        if (data['verifiedAt'] != null && data['verifiedAt'] is Timestamp) {
          data['verifiedAt'] =
              (data['verifiedAt'] as Timestamp).toDate().toIso8601String();
        }

        await DSession.setUser(data);
        return "success";
      } else {
        return "Data pengguna tidak ditemukan di database.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Tidak ada pengguna yang ditemukan dengan email tersebut.';
      } else if (e.code == 'wrong-password') {
        return 'Kata sandi yang Anda masukkan salah.';
      } else if (e.code == 'invalid-credential') {
        return 'Kredensial yang diberikan salah atau telah kedaluwarsa.';
      }
      log(e.toString());
      return "Terjadi kesalahan saat masuk. Silakan coba lagi.";
    } catch (e) {
      log(e.toString());
      return "Terjadi kesalahan yang tidak diketahui.";
    }
  }

  // === LOGOUT ===
  // === API CALL ===
  // Menghapus sesi kredensial Firebase dan lokal secara permanen
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await DSession.removeUser();
    } catch (e) {
      log(e.toString());
      throw Exception("Gagal keluar dari akun.");
    }
  }
}
