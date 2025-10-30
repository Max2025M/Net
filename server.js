import express from "express";
import multer from "multer";
import { createWorker } from "tesseract.js";
import fs from "fs";

const app = express();
const upload = multer({ dest: "uploads/" });

// Servir o HTML
app.get("/", (req, res) => {
  fs.readFile("index.html", "utf8", (err, data) => {
    if (err) return res.status(500).send("Erro ao carregar página.");
    res.send(data);
  });
});

// Função para extrair números moçambicanos válidos
function extractMozNumbers(text) {
  const matches = text.match(/(\+?258[\s\d]{7,}|\b8\d[\s\d]{7,})/g) || [];
  const cleaned = matches
    .map(m => m.replace(/[^\d]/g, ""))
    .map(n => (n.startsWith("258") ? n.slice(3) : n))
    .filter(n => n.length >= 8 && n.length <= 9 && /^8\d+/.test(n));
  return [...new Set(cleaned)];
}

// Endpoint de upload e OCR
app.post("/upload", upload.single("image"), async (req, res) => {
  if (!req.file) return res.json({ error: "Nenhuma imagem enviada." });

  const worker = await createWorker("eng+por");
  try {
    const { data: { text } } = await worker.recognize(req.file.path);
    await worker.terminate();
    fs.unlinkSync(req.file.path);

    const numbers = extractMozNumbers(text);
    if (!numbers.length)
      return res.json({ error: "Nenhum número válido encontrado.", ocrText: text });

    res.json({ numbers: numbers.join(","), ocrText: text });
  } catch (err) {
    console.error("Erro no OCR:", err);
    res.json({ error: "Erro ao processar imagem." });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Servidor rodando na porta ${PORT}`));
