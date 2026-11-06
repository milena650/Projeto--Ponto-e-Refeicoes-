import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/obra_equipe_service.dart';
import '../services/pontomais_service.dart';

class SelecaoEquipesScreen extends StatefulWidget {
  final String nomeObra;

  const SelecaoEquipesScreen({Key? key, required this.nomeObra}) : super(key: key);

  @override
  State<SelecaoEquipesScreen> createState() => _SelecaoEquipesScreenState();
}

class _SelecaoEquipesScreenState extends State<SelecaoEquipesScreen> {
  bool _isLoading = true;
  List<String> _todasAsEquipes = [];
  List<String> _equipesSelecionadas = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Carrega as equipas já salvas anteriormente para esta obra no Firestore
      final salvas = await ObraEquipeService.obterEquipesDaObra(widget.nomeObra);

      // 2. Busca todas as equipas disponíveis usando o serviço centralizado do Pontomais
      final todas = await PontomaisService.obterTodasEquipes();

      setState(() {
        _todasAsEquipes = todas;
        _equipesSelecionadas = List.from(salvas);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar equipes : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _salvar() async {
    setState(() => _isLoading = true);
    await ObraEquipeService.salvarEquipesDaObra(widget.nomeObra, _equipesSelecionadas);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipes  associadas com sucesso!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipes da Obra: ${widget.nomeObra}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todasAsEquipes.isEmpty
              ? const Center(child: Text('Nenhuma equipe encontrada no Pontomais.'))
              : ListView.builder(
                  itemCount: _todasAsEquipes.length,
                  itemBuilder: (context, index) {
                    final equipe = _todasAsEquipes[index];
                    final isSelected = _equipesSelecionadas.contains(equipe);

                    return CheckboxListTile(
                      title: Text(equipe),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _equipesSelecionadas.add(equipe);
                          } else {
                            _equipesSelecionadas.remove(equipe);
                          }
                        });
                      },
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _isLoading ? null : _salvar,
          child: const Text('Salvar Mapeamento', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}