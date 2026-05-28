// Platform-agnostic entry point for handling the web OAuth callback URL.
// Resolves to the web implementation on web, and a no-op stub on native.
export 'oauth_callback_stub.dart'
    if (dart.library.js_interop) 'oauth_callback_web.dart';
