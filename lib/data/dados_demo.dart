/// Credenciais da conta de demonstração ("Acesso Rápido").
///
/// A conta e seus agendamentos ficam no Supabase: crie o usuário e rode
/// `select public.seed_demo('<uuid>')` (seção 7 do SQL). Todos os dados são
/// fictícios.
abstract final class DadosDemo {
  static const cpf = '12345678909';
  static const cns = '700123456789010';
  static const email = 'jheniffer.santos@email.com';
  static const senha = 'agenda123';
}
