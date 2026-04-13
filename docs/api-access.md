# Koi API Access

Koi supports an RFC 8628 device flow to create a bearer token for admin access with a 12h max duration:

1. Start the device flow with no cookies or session state.
2. Parse `device_code`, `user_code`, and `verification_uri_complete` from the JSON response.
3. Print the `user_code` in the console so the user can confirm it matches the browser approval prompt.
4. Open the approval URL in the user's preferred browser. Example: `open -a "Google Chrome" ...`.
5. Wait for the human to approve the request in the browser. A real human must approve the request.
6. Poll the token endpoint every 5 seconds until it returns `access_token`.
7. Use the returned token as `Authorization: Bearer <token>` for subsequent requests.

Commands:

```sh
DEVICE_JSON=$(curl -k -sS -X POST https://<hostname>/admin/device_authorizations -H "Accept: application/json")
VERIFICATION_URI=$(jq -r '.verification_uri_complete' <<< "$DEVICE_JSON")
DEVICE_CODE=$(jq -r '.device_code' <<< "$DEVICE_JSON")
USER_CODE=$(jq -r '.user_code' <<< "$DEVICE_JSON")

printf 'Approve device flow for code: %s\n' "$USER_CODE"

open -a "Google Chrome" "$VERIFICATION_URI"

while true; do
  TOKEN_JSON=$(curl -k -sS -X POST https://<hostname>/admin/device_tokens \
    -H "Accept: application/json" \
    -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
    -d "device_code=$DEVICE_CODE")

  if jq -e '.access_token' >/dev/null <<< "$TOKEN_JSON"
  then
    break
  fi

  sleep 5
done

ACCESS_TOKEN=$(jq -r '.access_token' <<< "$TOKEN_JSON")
```
