/// Native (non-web) no-op: there is no `?code=` query in the URL to handle,
/// so this does nothing. The web implementation strips the OAuth code from
/// the browser URL after the session exchange.
String? currentUrl() => null;

void cleanCallbackUrl() {}
