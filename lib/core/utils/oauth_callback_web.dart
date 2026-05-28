import 'package:web/web.dart' as web;

/// The current browser URL (used to detect the `?code=` OAuth callback).
String? currentUrl() => web.window.location.href;

/// Strips the query string so the router boots on a clean `/` and a future
/// refresh doesn't re-exchange the (now-spent) OAuth code.
void cleanCallbackUrl() {
  web.window.history.replaceState(null, '', '/');
}
