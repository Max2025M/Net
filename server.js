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

// OCR múltiplo
app.post("/upload", upload.array("images", 20), async (req, res) => {
  if (!req.files || req.files.length === 0)
    return res.json({ error: "Nenhuma imagem enviada." });

  const worker = await createWorker("eng+por");
  let allNumbers = [];
  let progress = [];

  for (let i = 0; i < req.files.length; i++) {
    const file = req.files[i];
    try {
      const { data: { text } } = await worker.recognize(file.path);
      fs.unlinkSync(file.path);

      const numbers = extractMozNumbers(text);
      allNumbers.push(...numbers);
      progress.push({
        imageIndex: i + 1,
        total: req.files.length,
        found: numbers.length,
      });
    } catch (err) {
      console.error("Erro no OCR:", err);
    }
  }

  await worker.terminate();

  res.json({
    numbers: [...new Set(allNumbers)],
    totalImages: req.files.length,
    progress,
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Servidor rodando na porta ${PORT}`));
