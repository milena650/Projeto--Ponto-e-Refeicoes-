import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/historico_dias_screen.dart';
import 'package:provider/provider.dart';
import '../models/funcionario_model.dart';
import '../providers/obra_provider.dart';
import '../widgets/dialog_edicao_funcionario.dart';
import '../widgets/dialog_historico_alteracoes.dart';

class ResumoRefeicoesScreen extends StatelessWidget {
  const ResumoRefeicoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObraProvider>();

    // Agrupa os funcionários por equipe em tempo real
    final Map<String, List<Funcionario>> equipeMap = {};
    for (var f in provider.funcionarios) {
      final equipe = (f.equipe != null && f.equipe!.isNotEmpty) ? f.equipe! : 'Geral';
      equipeMap.putIfAbsent(equipe, () => []).add(f);
    }

    final equipesKeys = equipeMap.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.obraSelecionada ?? 'Resumo de Refeições'),
        actions: [
          TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          icon: const Icon(Icons.history),
          label: const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoricoDiasScreen(nomeObra: provider.obraSelecionada ?? ''),
               ),
            );
          } 
        ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sincronizar com Pontomais',
            onPressed: () => provider.buscarDadosPontomais(),
          ),
        ],
       
      ),
      

       





      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.mensagemErro != null
              ? _buildTelaErro(provider)
              : Column(
                  children: [
                    // --- SEÇÃO 1: Totais de Refeições ---
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _cardTotal('Café Manhã', provider.totalCafeManha),
                          _cardTotal('Almoço', provider.totalAlmoco),
                          _cardTotal('Café Tarde', provider.totalCafeTarde),
                        ],
                      ),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Acompanhamento por Equipes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),

                    // --- SEÇÃO 2: Listagem de Equipes e Colaboradores ---
                    Expanded(
                      child: equipesKeys.isEmpty
                          ? const Center(child: Text('Nenhum colaborador encontrado.'))
                          : ListView.builder(
                              itemCount: equipesKeys.length,
                              itemBuilder: (context, equipeIndex) {
                                final nomeEquipe = equipesKeys[equipeIndex];
                                final funcionariosDaEquipe = equipeMap[nomeEquipe]!;

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: ExpansionTile(
                                    title: Text(
                                      '$nomeEquipe (${funcionariosDaEquipe.length})',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    children: funcionariosDaEquipe.map((f) {
                                      final semPonto = f.horarioEntrada == null &&
                                                       f.horarioSaidaIntervalo == null &&
                                                       f.horarioRetornoIntervalo == null &&
                                                       f.horarioSaida == null ;
                                      return ListTile(
                                        title: Text(
                                          f.nomeCompleto,
                                          style: TextStyle(
                                            color: semPonto ? Colors.red : Colors.black,
                                            fontWeight: semPonto ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: Text(
                                          semPonto
                                              ? '⚠️ Não bateu ponto '
                                              : 'Café Manhã : ${f.horarioEntrada ?? "X"}   Almoço : ${f.horarioSaidaIntervalo ?? "X"}   Café Tarde : ${f.horarioSaida ?? "X"}',
                                          style: TextStyle(
                                            color: semPonto ? Colors.red.shade700 : const Color.fromARGB(255, 70, 71, 71),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Botão para abrir o Histórico
                                            OutlinedButton(
                                              onPressed: () => mostrarDialogHistorico(context, f, f.historicos),
                                              child: const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 8),
                                            // Botão para abrir a Edição
                                            ElevatedButton(
                                              onPressed: () => mostrarDialogEdicao(context, f),
                                              child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  // Widget auxiliar para os Cards de Totais
  Widget _cardTotal(String titulo, int qtd) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('$qtd', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para exibir Erro
  Widget _buildTelaErro(ObraProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(provider.mensagemErro!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => provider.buscarDadosPontomais(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}