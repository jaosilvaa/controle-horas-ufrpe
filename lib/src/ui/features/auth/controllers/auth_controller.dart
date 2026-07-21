import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:controle_horas/src/data/services/auth_service.dart';

/// Resultado simples de uma operação de autenticação.
///
/// [sucesso] indica se deu certo; [mensagem] traz um texto pronto pra mostrar
/// ao usuário (de sucesso ou de erro).
class AuthResult {
  final bool sucesso;
  final String mensagem;
  const AuthResult(this.sucesso, this.mensagem);
}

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<AuthState>? _authSub;

  AuthController(this._authService) {
    _authSub = _authService.onAuthStateChange.listen((data) {
      // O link de recuperação abriu o app: vamos para a tela de nova senha.
      if (data.event == AuthChangeEvent.passwordRecovery) {
        _recuperandoSenha = true;
      }
      notifyListeners();
    });
  }

  bool _carregando = false;
  bool get carregando => _carregando;

  // true quando o usuário chegou pelo link de recuperação e precisa definir
  // uma nova senha.
  bool _recuperandoSenha = false;
  bool get recuperandoSenha => _recuperandoSenha;

  bool get logado => _authService.isLoggedIn;
  String? get emailUsuario => _authService.currentUser?.email;

  /// URL da foto de perfil (vem do Google quando o login é por lá).
  /// Retorna null para contas de email/senha (que não têm foto).
  String? get fotoUrl {
    final meta = _authService.currentUser?.userMetadata;
    final url = (meta?['avatar_url'] ?? meta?['picture']) as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Nome do usuário. Usa o nome do Google; se não tiver, cai no trecho do
  /// email antes do "@".
  String? get nomeUsuario {
    final meta = _authService.currentUser?.userMetadata;
    final nome = (meta?['full_name'] ?? meta?['name']) as String?;
    if (nome != null && nome.trim().isNotEmpty) return nome.trim();
    final email = emailUsuario;
    if (email != null && email.contains('@')) return email.split('@').first;
    return null;
  }

  /// Só o primeiro nome (pra saudações tipo "Olá, Maria").
  String? get primeiroNome => nomeUsuario?.split(' ').first;

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  Future<AuthResult> entrar(String email, String senha) async {
    _setCarregando(true);
    try {
      await _authService.signIn(email: email, password: senha);
      return const AuthResult(true, 'Bem-vindo de volta!');
    } on AuthException catch (e) {
      return AuthResult(false, _traduzErro(e));
    } catch (_) {
      return const AuthResult(false, 'Não foi possível conectar. Verifique sua internet.');
    } finally {
      _setCarregando(false);
    }
  }

  Future<AuthResult> cadastrar(String email, String senha) async {
    _setCarregando(true);
    try {
      final res = await _authService.signUp(email: email, password: senha);
      // Se o Supabase exigir confirmação de email, não há sessão ainda.
      if (res.session == null) {
        return const AuthResult(
          true,
          'Conta criada! Confirme seu email para entrar.',
        );
      }
      return const AuthResult(true, 'Conta criada com sucesso!');
    } on AuthException catch (e) {
      return AuthResult(false, _traduzErro(e));
    } catch (_) {
      return const AuthResult(false, 'Não foi possível conectar. Verifique sua internet.');
    } finally {
      _setCarregando(false);
    }
  }

  Future<AuthResult> recuperarSenha(String email) async {
    _setCarregando(true);
    try {
      await _authService.sendPasswordReset(email);
      return const AuthResult(
        true,
        'Enviamos um link de recuperação para seu email. Abra-o neste celular.',
      );
    } on AuthException catch (e) {
      return AuthResult(false, _traduzErro(e));
    } catch (_) {
      return const AuthResult(false, 'Não foi possível conectar. Verifique sua internet.');
    } finally {
      _setCarregando(false);
    }
  }

  /// Define a nova senha (usado na tela que abre pelo link de recuperação).
  Future<AuthResult> atualizarSenha(String novaSenha) async {
    _setCarregando(true);
    try {
      await _authService.updatePassword(novaSenha);
      _recuperandoSenha = false;
      return const AuthResult(
        true,
        'Senha alterada! Entre com sua nova senha.',
      );
    } on AuthException catch (e) {
      return AuthResult(false, _traduzErro(e));
    } catch (_) {
      return const AuthResult(false, 'Não foi possível conectar. Verifique sua internet.');
    } finally {
      _setCarregando(false);
    }
  }

  Future<AuthResult> entrarComGoogle() async {
    _setCarregando(true);
    try {
      await _authService.signInWithGoogle();
      return const AuthResult(true, 'Bem-vindo!');
    } on GoogleSignInException catch (e) {
      // Usuário fechou o seletor de contas — não é erro de verdade.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const AuthResult(false, '');
      }
      // TEMPORÁRIO (diagnóstico): mostra o erro real do Google.
      debugPrint('### GoogleSignInException: code=${e.code} desc=${e.description}');
      return AuthResult(false, 'Google [${e.code.name}]: ${e.description ?? ''}');
    } on AuthException catch (e) {
      // TEMPORÁRIO (diagnóstico): mostra o erro real do Supabase.
      debugPrint('### Supabase AuthException: ${e.message} | status=${e.statusCode}');
      return AuthResult(false, 'Supabase: ${e.message}');
    } catch (e) {
      // TEMPORÁRIO (diagnóstico): mostra qualquer outro erro.
      debugPrint('### Erro Google desconhecido: $e');
      return AuthResult(false, 'Erro: $e');
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> sair() async {
    await _authService.signOut();
  }

  /// Converte mensagens de erro do Supabase (em inglês) para português.
  String _traduzErro(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'Já existe uma conta com esse email.';
    }
    if (msg.contains('password should be at least')) {
      return 'A senha precisa ter pelo menos 6 caracteres.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu email antes de entrar.';
    }
    if (msg.contains('unable to validate email') ||
        msg.contains('invalid email')) {
      return 'Email inválido.';
    }
    return 'Algo deu errado. Tente novamente.';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
