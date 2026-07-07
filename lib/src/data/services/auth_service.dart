import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';

/// Camada fina sobre a autenticação do Supabase.
///
/// Concentra todas as chamadas de auth num só lugar, pra que o resto do app
/// não precise conhecer detalhes do Supabase.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  bool _googleIniciado = false;

  GoTrueClient get _auth => _client.auth;

  /// Usuário logado no momento (ou null se não houver sessão).
  User? get currentUser => _auth.currentUser;

  /// true se existe uma sessão ativa.
  bool get isLoggedIn => _auth.currentSession != null;

  /// Emite um evento sempre que o estado de login muda (login, logout, etc).
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Cria uma conta nova com email e senha.
  ///
  /// Dependendo da configuração do Supabase, pode ser necessário confirmar
  /// o email antes de a sessão ficar ativa.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _auth.signUp(email: email.trim(), password: password);
  }

  /// Faz login com email e senha.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// Encerra a sessão atual.
  Future<void> signOut() => _auth.signOut();

  /// Endereço (deep link) que o link do email vai abrir de volta no app.
  /// Precisa estar cadastrado nas "Redirect URLs" do Supabase.
  static const String passwordResetRedirect = 'controlehoras://login-callback';

  /// Envia um email de recuperação de senha. O link aponta de volta para o app
  /// (deep link), que abre a tela de nova senha.
  Future<void> sendPasswordReset(String email) {
    return _auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: passwordResetRedirect,
    );
  }

  /// Define a nova senha do usuário (precisa de uma sessão ativa — que o app
  /// recebe automaticamente quando o link de recuperação abre o app).
  Future<UserResponse> updatePassword(String newPassword) {
    return _auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Login com a conta Google (fluxo nativo do Android).
  ///
  /// Abre o seletor de contas do Google, pega o token de identidade e o
  /// entrega ao Supabase, que cria/usa a sessão do usuário.
  Future<AuthResponse> signInWithGoogle() async {
    final google = GoogleSignIn.instance;

    // initialize() só pode ser chamado uma vez (exigência da API v7).
    if (!_googleIniciado) {
      await google.initialize(
        serverClientId: SupabaseConfig.googleWebClientId,
      );
      _googleIniciado = true;
    }

    final conta = await google.authenticate();
    final idToken = conta.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('Não foi possível obter o token do Google.');
    }

    return _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }
}
