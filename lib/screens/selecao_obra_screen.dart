import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';
import '../services/obra_equipe_service.dart';
import 'resumo_refeicoes__screen.dart';
import 'selecao_equipes_screen.dart';

class SelecaoObraScreen extends StatefulWidget {
  const SelecaoObraScreen({super.key});

  @override
  State<SelecaoObraScreen> createState() => _SelecaoObraScreenState();
}

class _SelecaoObraScreenState extends State<SelecaoObraScreen> {
  List<String> obras = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarObras();
  }

  // Carrega as obras guardadas no armazenamento local
  Future<void> _carregarObras() async {
    setState(() => isLoading = true);
    final vinculos = await ObraEquipeService.obterTodosVinculos();
    setState(() {
      obras = vinculos.keys.toList()..sort();
      isLoading = false;
    });
  }

  // Abre uma janela para digitar e criar uma nova obra
  void _mostrarDialogAdicionarObra() {
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
                // Regista a obra com uma lista vazia de equipas inicialmente
                await ObraEquipeService.salvarEquipesDaObra(nome, []);
                if (mounted) Navigator.pop(context);
                _carregarObras();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solário - Selecionar Obra'),
        actions: [
          // Botão no topo para adicionar nova obra
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Obra',
            onPressed: _mostrarDialogAdicionarObra,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : obras.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nenhuma obra cadastrada ainda.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _mostrarDialogAdicionarObra,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Primeira Obra'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: obras.length,
                  itemBuilder: (context, index) {
                    final nomeObra = obras[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          nomeObra,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botão de engrenagem para associar as equipas da obra
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.grey),
                              tooltip: 'Configurar Equipas',
                              onPressed: () async {
                                // Abre a tela de seleção e atualiza a lista ao voltar
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelecaoEquipesScreen(nomeObra: nomeObra),
                                  ),
                                );
                                _carregarObras();
                              },
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: () {
                          // 1. Atualiza a obra selecionada
                          context.read<ObraProvider>().selecionarObra(nomeObra);

                          // 2. Abre a tela de Resumo de Refeições
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResumoRefeicoesScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}