import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';
import '../services/obra_equipe_service.dart';
import '../widgets/dialog_adicionar_obra.dart';
import './resumo_refeicoes__screen.dart';
import 'selecao_equipes_screen.dart';

class SelecaoObraScreen extends StatefulWidget {
  const SelecaoObraScreen({super.key});

  @override
  State<SelecaoObraScreen> createState() => SelecaoObraScreenState();
}

class SelecaoObraScreenState extends State<SelecaoObraScreen> {
  List<String> obras = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarObras();
  }

  // Carrega as obras guardadas no Firestore
  Future<void> _carregarObras() async {
    setState(() => isLoading = true);
    final vinculos = await ObraEquipeService.obterTodosVinculos();
    setState(() {
      obras = vinculos.keys.toList()..sort();
      isLoading = false;
    });
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
            onPressed: () => mostrarDialogAdicionarObra(context, _carregarObras),
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
                        onPressed: () => mostrarDialogAdicionarObra(context, _carregarObras),
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
                            // Botão para excluir a obra
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir Obra',
                              onPressed: () async {
                                final confirmar = await _confirmarExclusao(context, nomeObra);
                                if (confirmar == true) {
                                  await ObraEquipeService.excluirObra(nomeObra);
                                  _carregarObras();
                                }
                              },
                            ),
                            // Botão de engrenagem para associar as equipas à obra
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.grey),
                              tooltip: 'Configurar Equipas',
                              onPressed: () async {
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
                          // 1. Atualiza a obra selecionada no Provider
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

  // Caixa de diálogo auxiliar para confirmar exclusão
  Future<bool?> _confirmarExclusao(BuildContext context, String nomeObra) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Obra'),
        content: Text('Deseja realmente excluir a obra "$nomeObra"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}