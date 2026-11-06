const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.pontomaisWebhook = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Método não permitido");
  }
  try {
    const dadosEvento = req.body;
    await db.collection("webhooks_pontomais").add({
      payload: dadosEvento,
      recebidoEm: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.status(200).send("Webhook recebido com sucesso!");
  } catch (erro) {
    console.error("Erro ao salvar webhook:", erro);
    return res.status(500).send("Erro interno ao processar webhook.");
  }
});

