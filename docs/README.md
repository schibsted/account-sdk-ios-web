# Technical Documentation

## Login

When logging in, we create a `ASWebAuthenticationSession` with a given URL, and reads the corresponding `code` query parameter when it completes.

The code is then used to [request the user tokens](https://docs.schibsted.io/schibsted-account/guides/tokens/)

```mermaid
sequenceDiagram
    SchibstedAuthenticator-)ASWebAuthenticationSession: GET /oauth/authorize?client_id=example&redirect_uri=example:/login
    ASWebAuthenticationSession-->>SchibstedAuthenticator: example:/login?code=b13PkT0QdbblAwF1JGfC8
    SchibstedAuthenticator-)login.schibsted.com: POST /oauth/token
    login.schibsted.com-->>SchibstedAuthenticator: User Tokens
```

Next we perform [local token introspection](https://docs.schibsted.io/schibsted-account/guides/token-introspection/#local-token-introspection) using the Schibsted Account public keys from `/oauth/jwks`

```mermaid
sequenceDiagram
    SchibstedAuthenticator-)IdTokenValidating: Validate User Tokens
    IdTokenValidating-)login.schibsted.com: GET /oauth/jwks
    login.schibsted.com-->>IdTokenValidating: ID Token
    IdTokenValidating-->>SchibstedAuthenticator: ID token
```

## Token refresh flow

When the `AuthenticatedURLSession` hits a HTTP 401, it'll attempt to refresh the OAuth token, using the stored refresh token.

```mermaid
sequenceDiagram
    AuthenticatedURLSession-)Endpoint: data(for:delegate)
    Endpoint-->>AuthenticatedURLSession: HTTP 401
    AuthenticatedURLSession-)login.schibsted.com: POST oauth/token
    login.schibsted.com-->>AuthenticatedURLSession: Updated tokens
    AuthenticatedURLSession-)Endpoint: data(for:delegate)
    Endpoint-->>AuthenticatedURLSession: HTTP 200
```

## Simplified Login

Simplified login uses a user token from a shared keychain to request a `assertion`, which is provided as a query parameter for the URL passed to the `ASWebAuthenticationSession`, in order to login without needing any user input.

```mermaid
sequenceDiagram
    SchibstedAuthenticator-)login.schibsted.com: POST /api/2/user/auth/token
    login.schibsted.com-->>SchibstedAuthenticator: { data: { assertion: "ak3492nfAwF1JGf" } }
    SchibstedAuthenticator-)ASWebAuthenticationSession: GET /oauth/authorize?client_id=example&assertion=ak3492nfAwF1JGf
    ASWebAuthenticationSession-->>SchibstedAuthenticator: example:/login?code=b13PkT0QdbblAwF1JGfC8
```
