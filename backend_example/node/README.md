# Controlix chat backend example (Node)

This is a minimal example of a backend endpoint that your Flutter app can call:

- `POST /api/chat`
- The backend calls OpenAI **Responses API** using `OPENAI_API_KEY` server-side.

## Setup

1. `cd backend_example/node`
2. `npm i`
3. Copy `.env.example` to `.env` and fill values
4. `npm run dev`

## Request/response contract

### Request

Headers:

- `Content-Type: application/json`
- `X-Controlix-Key: <shared-secret>`

Body:

```json
{
  "messages": [
    { "role": "user", "content": "Hello!" },
    { "role": "assistant", "content": "Hi — how can I help?" }
  ]
}
```

### Response

```json
{ "reply": "..." }
```

