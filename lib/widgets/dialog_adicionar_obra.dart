import 'package:flutter/material.dart';
import '../services/obra_equipe_service.dart';

void mostrarDialogAdicionarObra(BuildContext context, VoidCallback onObraAdicionada) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Adicionar Nova Obra'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Ex: Obra Centro',
          labelText: 'Nome da Obra',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final nome = controller.text.trim();
            if (nome.isNotEmpty) {
              // Regista a obra com uma lista vazia de equipas no Firestore
              await ObraEquipeService.salvarEquipesDaObra(nome, []);
              if (context.mounted) Navigator.pop(context);
              onObraAdicionada(); // Atualiza a lista no ecrã principal
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}