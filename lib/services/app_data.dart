import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'data_service.dart';
import 'supabase_data_service.dart';

class AppData {
  static DataService? service;
  static AppUser? currentUser;
  static String? setupError;

  // Add your Supabase Project URL and anon/public key here.
  // These values are also loaded from .env if available.
  static const String _supabaseUrlFallback =
      'https://fiiygwtpfxdfqesvtdcy.supabase.co';
  static const String _supabaseAnonKeyFallback =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpaXlnd3RwZnhkZnFlc3Z0ZGN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMzcwOTAsImV4cCI6MjA5NTgxMzA5MH0.1QrqlnUlW7gxoi5qdEhs7jxNvwDpi0L9Bl0BgCK73fY';

  static String _cleanUrl(String url) {
    final trimmed = url.trim();

    // If the URL was accidentally pasted twice, keep only the first valid Supabase URL.
    final match = RegExp(r'https://[^\s/]+\.supabase\.co').firstMatch(trimmed);
    final candidate = match?.group(0) ?? trimmed;

    return candidate
        .replaceAll('/rest/v1', '')
        .replaceAll('/auth/v1', '')
        .replaceAll(RegExp(r'/+$'), '');
  }

  static bool _looksConfigured(String url, String key) {
    return url.startsWith('https://') &&
        url.contains('.supabase.co') &&
        key.length > 40 &&
        !url.contains('your-project') &&
        !key.contains('your-anon');
  }

  static Future<void> initialize({String? url, String? anonKey}) async {
    final rawUrl = url?.trim() ?? dotenv.env['SUPABASE_URL']?.trim() ?? _supabaseUrlFallback;
    final key = (anonKey?.trim() ?? dotenv.env['SUPABASE_ANON_KEY']?.trim() ??
            _supabaseAnonKeyFallback)
        .trim();
    final cleanedUrl = _cleanUrl(rawUrl);

    if (!_looksConfigured(cleanedUrl, key)) {
      setupError =
          'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY in the .env file.';
      service = null;
      return;
    }

    try {
      await Supabase.initialize(url: cleanedUrl, publishableKey: key);
      final client = Supabase.instance.client;
      await client
          .from('users')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 12));
      service = SupabaseDataService(client);
      setupError = null;
    } catch (error) {
      setupError = readableError(error);
      service = null;
    }
  }

  static DataService requireService() {
    final activeService = service;
    if (activeService == null) {
      throw Exception(setupError ?? 'Supabase service is not ready.');
    }
    return activeService;
  }

  static void setCurrentUser(AppUser user) {
    currentUser = user;
  }

  static void logout() {
    currentUser = null;
  }

  static String readableError(Object error) {
    final message = error.toString();
    final lower = message.toLowerCase();

    if (lower.contains('permission') ||
        lower.contains('42501') ||
        lower.contains('row-level') ||
        lower.contains('rls')) {
      return 'Supabase table permission problem. Run database/schema.sql in the Supabase SQL Editor.';
    }
    if (lower.contains('404') ||
        lower.contains('not found') ||
        lower.contains('relation') ||
        lower.contains('does not exist')) {
      return 'Supabase table not found. Run database/schema.sql in the Supabase SQL Editor.';
    }
    if (lower.contains('401') ||
        lower.contains('403') ||
        lower.contains('unauthorized')) {
      return 'Supabase 401 Unauthorized. Run database/schema.sql again, then confirm your .env uses the Project URL and anon public key.';
    }
    if (lower.contains('invalid api key') || lower.contains('jwt')) {
      return 'Invalid Supabase anon key. Copy the anon public key from Supabase Project Settings > API.';
    }
    if (lower.contains('failed to fetch') ||
        lower.contains('xmlhttprequest') ||
        lower.contains('clientexception')) {
      return 'Cannot reach Supabase. Check that SUPABASE_URL in .env is your exact Project URL, your project is not paused, and your internet/DNS can open it.';
    }
    if (lower.contains('failed host lookup') ||
        lower.contains('remote name could not be resolved') ||
        lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('timeout')) {
      return 'Network connection failed. Check your internet connection and Supabase URL.';
    }
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
