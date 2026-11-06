const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const axios = require("axios");
const serviceAccount = require("./serviceAccountKey.json");

// Inicializa o Firebase Admin
initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function sincronizarDados() {
  try {
    console.log("A buscar dados na API do PontoMais...");

    // URL correta conforme a documentação oficial e uso do cabeçalho 'access-token'
    const resposta = await axios.get("https://api.pontomais.com.br/external_api/v1/employees", {
      headers: {
        "access-token": "$2a$12$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK", // Insira o seu token público da API aqui
        "Content-Type": "application/json"
      },
      params: {
        active: true,
        per_page: 50 // Ajuste conforme a quantidade de registos que deseja buscar
      }
    });

    // Conforme o manual, a lista de colaboradores vem dentro da propriedade 'employees'
    const dados = resposta.data.employees || resposta.data;
    
    if (!dados || dados.length === 0) {
      console.log("Nenhum colaborador encontrado na resposta.");
      return;
    }

    console.log(`Encontrados ${dados.length} registos. A guardar no Firestore...`);

    const batch = db.batch();

    for (const item of dados) {
      const docRef = db.collection("funcionarios_ponto").doc(String(item.id));
      batch.set(docRef, {
        ...item,
        atualizadoEm: FieldValue.serverTimestamp()
      });
    }

    await batch.commit();
    console.log("Sincronização concluída com sucesso no Firestore!");

  } catch (erro) {
    console.error("Erro na sincronização:", erro.response?.data || erro.message);
  }
}

sincronizarDados();