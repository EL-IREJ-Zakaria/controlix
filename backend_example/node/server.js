import cors from "cors";
import "dotenv/config";
import express from "express";
import OpenAI from "openai";

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

const fetchFn = globalThis.fetch;

const openaiClient = process.env.OPENAI_API_KEY
  ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
  : null;

function requireSharedKey(req, res, next) {
  const expected = process.env.CONTROLIX_SHARED_KEY;
  if (!expected) {
    return res.status(500).json({
      message: "Server misconfigured: CONTROLIX_SHARED_KEY is missing.",
    });
  }

  const provided = req.header("X-Controlix-Key");
  if (!provided || provided !== expected) {
    return res.status(401).json({ message: "Unauthorized." });
  }

  next();
}

function normalizeMessages(messages) {
  return messages
    .filter((m) => m && typeof m === "object")
    .map((m) => ({
      role: m.role,
      content: typeof m.content === "string" ? m.content : "",
    }))
    .filter(
      (m) =>
        (m.role === "user" || m.role === "assistant") &&
        m.content.trim().length > 0
    )
    .slice(-24);
}

async function geminiReply(messages) {
  if (typeof fetchFn !== "function") {
    throw new Error(
      "fetch() is not available in this Node.js runtime. Use Node 18+ (recommended) or install a fetch polyfill."
    );
  }

  const apiKey = (process.env.GEMINI_API_KEY || "").trim();
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY is missing.");
  }

  const model = (process.env.GEMINI_MODEL || "gemini-2.0-flash").trim();
  const contents = normalizeMessages(messages).map((m) => ({
    role: m.role === "assistant" ? "model" : "user",
    parts: [{ text: m.content }],
  }));

  const res = await fetchFn(
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(
      model
    )}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        system_instruction: {
          parts: [
            {
              text:
                "Tu es Controlix Assistant, un assistant professionnel et concis pour une application d'automatisation Windows. " +
                "Réponds en français. Sois clair, pratique et prudent. " +
                "Quand c'est utile, pose une seule question de clarification courte.",
            },
          ],
        },
        contents,
      }),
    }
  );

  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail = payload?.error?.message || JSON.stringify(payload);
    throw new Error(`Gemini API error (${res.status}): ${detail}`);
  }

  const parts = payload?.candidates?.[0]?.content?.parts ?? [];
  const text = parts
    .map((p) => (typeof p?.text === "string" ? p.text : ""))
    .join("");
  return text.trim();
}

app.post("/api/chat", requireSharedKey, async (req, res) => {
  try {
    const messages = Array.isArray(req.body?.messages) ? req.body.messages : [];

    if ((process.env.GEMINI_API_KEY || "").trim()) {
      const reply = await geminiReply(messages);
      return res.json({ reply });
    }

    if (!openaiClient) {
      return res.status(500).json({
        message:
          "Server misconfigured: set GEMINI_API_KEY or OPENAI_API_KEY in .env.",
      });
    }
    const input = [
      {
        role: "developer",
        content:
          "Tu es Controlix Assistant, un assistant professionnel et concis pour une application d'automatisation Windows. " +
          "Réponds en français. Sois clair, pratique et prudent. Quand c'est utile, pose une seule question de clarification courte.",
      },
      ...normalizeMessages(messages),
    ];

    const response = await openaiClient.responses.create({
      model: process.env.OPENAI_MODEL || "gpt-5",
      input,
      store: false,
    });

    return res.json({ reply: response.output_text ?? "" });
  } catch (err) {
    const message =
      typeof err?.message === "string" ? err.message : "Chat request failed.";
    return res.status(500).json({ message });
  }
});

const port = Number(process.env.PORT || 8787);
app.listen(port, () => {
  console.log(`Chat backend listening on http://localhost:${port}`);
});
