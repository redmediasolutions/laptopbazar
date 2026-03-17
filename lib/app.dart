import 'package:electralap/services/nav.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Webnav.router();
  }
}
