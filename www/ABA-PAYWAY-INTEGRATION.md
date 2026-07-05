# ABA PayWay production activation

The IDI APP interface includes a non-scannable KHQR demonstration. Production payments require an ABA PayWay merchant profile and a secure server.

## Required server flow

1. Create a unique membership renewal order and pending invoice in the IDI APP database.
2. From the server, call ABA PayWay QR API `POST /api/payment-gateway/v1/payments/generate-qr` with `payment_option=abapay_khqr`.
3. Generate the required Base64 HMAC-SHA512 signature on the server using the ABA-provided API key. Never expose the API key in browser JavaScript.
4. Return only PayWay's `qrImage`, `qrString`, `abapay_deeplink`, amount, currency, and transaction ID to the browser.
5. Receive and validate the PayWay callback on an HTTPS server endpoint.
6. Verify the transaction through PayWay before marking an invoice paid or extending membership access.
7. Store transaction ID, paid amount, currency, invoice, payment timestamp, and verification response for audit and reconciliation.

For a hosted checkout URL, the Ecommerce Purchase API can return `checkout_qr_url`. PayWay's Payment Link API can also create reusable or limited-use hosted payment links. These must also be created from the server.

## Suggested environment variables

```text
PAYWAY_MERCHANT_ID=
PAYWAY_API_KEY=
PAYWAY_RSA_PUBLIC_KEY=
PAYWAY_BASE_URL=
PAYWAY_CALLBACK_URL=https://your-domain.com/api/payments/payway/callback
PAYWAY_RETURN_URL=https://your-domain.com/billing/payment-result
```

## Official documentation

- https://developer.payway.com.kh/aba-qr-api-3158158f0
- https://developer.payway.com.kh/qr-api-14530840e0
- https://developer.payway.com.kh/purchase-14530820e0
- https://developer.payway.com.kh/payment-link-3158157f0
- https://developer.payway.com.kh/create-payment-link-14530837e0
- https://developer.payway.com.kh/check-transaction-14530826e0

