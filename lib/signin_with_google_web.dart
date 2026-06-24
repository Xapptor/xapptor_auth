/// Web-specific Google Sign-In initialization.
///
/// In google_sign_in 7.x, the web plugin (google_sign_in_web) feeds
/// authentication events through GoogleSignIn.instance.authenticationEvents,
/// which is already listened to in check_login.dart.
/// The renderButton() click triggers an AuthenticationEventSignIn on that stream.
///
/// These functions are kept as no-ops to maintain the conditional import interface.

void init_google_signin_web_listener() {
  // No-op: In v7, authenticationEvents stream handles web sign-in events.
}

void dispose_google_signin_web_listener() {
  // No-op: No manual subscription to clean up.
}
