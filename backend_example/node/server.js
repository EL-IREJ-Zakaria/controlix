import cors from "cors";
import "dotenv/config";
import express from "express";
import OpenAI from "openai";

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

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

app.post("/api/chat", requireSharedKey, async (req, res) => {
  try {
    const messages = Array.isArray(req.body?.messages) ? req.body.messages : [];
    const input = [
      {
        role: "developer",
        content:
          "You are Controlix Assistant, a concise professional assistant for a Windows automation app. " +
          "Be clear, practical, and safe. When needed, ask one short clarifying question.",
      },
      ...normalizeMessages(messages),
    ];

    const response = await client.responses.create({
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

