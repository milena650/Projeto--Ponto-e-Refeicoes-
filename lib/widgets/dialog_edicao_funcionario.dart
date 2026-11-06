import 'package:flutter/material.dart';
import '../models/funcionario_model.dart';

void mostrarDialogEdicao(BuildContext context, Funcionario f) {
  final justificativaController = TextEditingController();
  final responsavelController = TextEditingController();

  bool cafeManha = f.temDireitoCafeManha;
  bool almoco = f.temDireitoAlmoco;
  bool cafeTarde = f.temDireitoCafeTarde;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: const Text('Editar Informações', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${f.nomeCompleto}:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Café Manhã: ${f.horarioEntrada ?? "07:00"}'),
                  value: cafeManha,
                  activeColor: Colors.green,
                  onChanged: (val) => setStateDialog(() => cafeManha = val ?? false),
                ),
                CheckboxListTile(
                  title: Text('Almoço: ${f.horarioSaidaIntervalo ?? "11:30"}'),
                  value: almoco,
                  activeColor: Colors.green,
                  onChanged: (val) => setStateDialog(() => almoco = val ?? false),
                ),
                CheckboxListTile(
                  title: Text('Café Tarde: ${f.horarioSaida ?? "17:18"}'),
                  value: cafeTarde,
                  activeColor: Colors.green,
                  onChanged: (val) => setStateDialog(() => cafeTarde = val ?? false),
                ),
                const SizedBox(height: 20),
                const Text('Justificativa da mudança:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: justificativaController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Digite o motivo da alteração...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Responsável pelo preenchimento:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: responsavelController,
                  decoration: const InputDecoration(
                    hintText: 'Nome do responsável...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Arquivo'),
          ),
          const Spacer(),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
            ),
            onPressed: () {
              if (responsavelController.text.trim().isEmpty ||
                  justificativaController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, preencha a Justificativa e o Responsável!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informações atualizadas com sucesso!')),
              );
            },
            child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}