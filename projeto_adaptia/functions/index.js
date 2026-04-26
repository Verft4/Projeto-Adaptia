const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.chatIA = functions.https.onRequest(async (req, res) => {
  const userMessage = req.body.message;

  const response = await fetch(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyDXh_1fUSu8gLsg9aHGqPZzhKM7TEDuNi4",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: "Você ajuda professores a criar atividades " +
                    "para alunos neurodivergentes.\n\n" +
                    `Usuário: ${userMessage}`,
                },
              ],
            },
          ],
        }),
      },
  );

  const data = await response.json();

  let reply = "Erro ao gerar resposta";

  if (
    data.candidates &&
        data.candidates[0] &&
        data.candidates[0].content &&
        data.candidates[0].content.parts &&
        data.candidates[0].content.parts[0]
  ) {
    reply = data.candidates[0].content.parts[0].text;
  }

  res.json({reply});
});
