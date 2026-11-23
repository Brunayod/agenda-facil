import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração do projeto Supabase.
///
/// A anon key é pública por desenho (a segurança vem das políticas RLS do
/// banco). NUNCA coloque a `service_role key` no app.
///
/// Para trocar sem editar o código:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qnmbyqbpssbndxrmdwxx.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFubWJ5cWJwc3NibmR4cm1kd3h4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM4NjgwMDMsImV4cCI6MjEwOTQ0NDAwM30.UuyBkkDb-5IANRjPJe_FFviY3g45TtQYIXjn6h7jfvY',
  );

  static Future<void> inicializar() =>
      Supabase.initialize(url: url, anonKey: anonKey);
}

/// Atalho para o cliente do Supabase (só use depois de `inicializar`).
SupabaseClient get supabase => Supabase.instance.client;
