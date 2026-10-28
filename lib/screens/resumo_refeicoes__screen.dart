import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';

class ResumoRefeicoesScreen extends StatelessWidget {
  const ResumoRefeicoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObraProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.obraSelecionada ?? 'Resumo de Refeições'),
        actions: [
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
              ? Center(
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
                )
              : Column(
                  children: [
                    // Totais de refeições
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
                        'Acompanhamento de Colaboradores',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.funcionarios.length,
                        itemBuilder: (context, index) {
                          final f = provider.funcionarios[index];
                          return ListTile(
                            title: Text(f.nomeCompleto),
                            subtitle: Text(
                              'Café: ${f.temDireitoCafeManha ? "✓" : "✗"} | '
                              'Almoço: ${f.temDireitoAlmoco ? "✓" : "✗"} | '
                              'Tarde: ${f.temDireitoCafeTarde ? "✓" : "✗"}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_note, color: Colors.orange),
                              onPressed: () {
                                // Dialog para registrar justificativa de exceção
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

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
}