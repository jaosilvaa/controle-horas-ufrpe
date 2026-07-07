/// Configuração de conexão com o Supabase.
///
/// COMO PREENCHER:
/// 1. Acesse https://supabase.com e crie um projeto (grátis).
/// 2. No painel do projeto, vá em:  Settings → Data API (e Settings → API Keys).
/// 3. Copie a "Project URL" e cole em [url].
/// 4. Copie a chave pública "anon / publishable" e cole em [anonKey].
///
/// A chave "anon" é PÚBLICA e pode ficar no app — ela só permite o que suas
/// regras de segurança (RLS) do Supabase autorizarem. NUNCA coloque aqui a
/// chave "service_role" (essa é secreta).
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://sqnpxzwrnjwnesemqpsa.supabase.co';
  static const String publishableKey =
      'sb_publishable_tAne7dGA8bRNJH7SHofEnw_U79AqJ8_';

  /// Client ID do tipo "Web" criado no Google Cloud. É usado pelo login Google
  /// no Android (como serverClientId) e também precisa estar configurado no
  /// painel do Supabase (Authentication → Providers → Google).
  static const String googleWebClientId =
      '959278051976-pkkghedvkjm1fm6g0dc9upfvrcbbpqlr.apps.googleusercontent.com';

  /// Retorna true quando as chaves já foram preenchidas.
  static bool get isConfigured =>
      !url.startsWith('COLE_AQUI') && !publishableKey.startsWith('COLE_AQUI');

  /// true quando o login com Google está pronto pra ser usado.
  static bool get googleEnabled =>
      isConfigured && !googleWebClientId.startsWith('COLE_AQUI');
}
