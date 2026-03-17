import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'app.dart';
import 'main.server.options.dart';
import 'package:electralap/services/supabase_service.dart';

void main() {
  // Initialize shared services.
  SupabaseService.client;

  // 1. Initialize Jaspr (Crucial Step)
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  // 2. Run the App
  runApp(Document(
    title: 'ELECTRALAP',
    meta: {'viewport': 'width=device-width, initial-scale=1.0'},
    head: [
      link(href: '/styles.css', rel: 'stylesheet'),
      link(href: "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel: "stylesheet"),
      link(href: "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0", rel: "stylesheet"),
    ],
    body: App(),
  ));
}
