import 'package:flutter/material.dart';
import '../models/funcionario_model.dart';

void mostrarDialogHistorico(BuildContext context, Funcionario f, List<HistoricoEdicao> historicos) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Histórico de Alterações: ${f.nomeCompleto}'),
      content: SizedBox(
        width: 600,
        child: historicos.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Nenhuma alteração registrada ainda.'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: historicos.length,
                itemBuilder: (context, index) {
                  final h = historicos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Responsável: ${h.responsavel}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              Text(h.dataHora, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Justificativa: "${h.justificativa}"',
                              style: const TextStyle(fontStyle: FontStyle.italic)),
                          const Divider(),
                          const Text('Mudanças:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          ...h.alteracoes.entries.map((e) => Text('• ${e.key}: ${e.value}')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}