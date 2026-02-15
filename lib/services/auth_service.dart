import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Common interface for auth. Use [Get.find<AuthService>()] in controllers.
abstract class AuthService extends GetxService {
  /// Optional. Set from Firebase Console (Project settings → General → Your apps → Web app → Web API key).
  /// Required for Google Sign-In on Android; recommended for iOS.
  static String? googleSignInWebClientId;

  Rxn<User> get currentUser;
  bool get isLoggedIn;
  /// False when running without Firebase (stub). Use to show setup message.
  bool get isFirebaseConfigured;
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

/// Real Firebase Auth. Used when Firebase is initialized.
class FirebaseAuthService extends AuthService {
  FirebaseAuthService() : _auth = FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final Rxn<User> _currentUser = Rxn<User>();

  @override
  Rxn<User> get currentUser => _currentUser;

  @override
  void onInit() {
    super.onInit();
    _currentUser.bindStream(_auth.authStateChanges());
  }

  @override
  bool get isLoggedIn => _currentUser.value != null;

  @override
  bool get isFirebaseConfigured => true;

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _GoogleSignInHelper.signInWithGoogle(_auth);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// No-op when Firebase is not configured. App runs without crashing.
class StubAuthService extends AuthService {
  final Rxn<User> _currentUser = Rxn<User>();

  @override
  Rxn<User> get currentUser => _currentUser;

  @override
  bool get isLoggedIn => false;

  @override
  bool get isFirebaseConfigured => false;

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // No-op until Firebase is configured
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw UnsupportedError(
      'Firebase is not configured. Run: flutterfire configure',
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    // No-op until Firebase is configured
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw UnsupportedError(
      'Firebase is not configured. Run: flutterfire configure',
    );
  }

  @override
  Future<void> signOut() async {}
}

/// Google Sign-In + Firebase Auth. Uses Web Client ID from Firebase if available.
class _GoogleSignInHelper {
  static Future<void> signInWithGoogle(FirebaseAuth firebaseAuth) async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
    );
    final account = await googleSignIn.signIn();
    if (account == null) return;

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await firebaseAuth.signInWithCredential(credential);
  }

  static String? get _webClientId => AuthService.googleSignInWebClientId;
}
