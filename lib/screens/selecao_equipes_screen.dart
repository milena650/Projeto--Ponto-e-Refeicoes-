import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/obra_equipe_service.dart';

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
    try {
      // 1. Carrega as equipas já salvas anteriormente para esta obra
      final salvas = await ObraEquipeService.obterEquipesDaObra(widget.nomeObra);

      // 2. Busca todas as equipas disponíveis na API do Pontomais
      const String baseUrl = 'https://api.pontomais.com.br/external_api/v1';
      const String token = r'$2a$12$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK';
      
      final response = await http.get(
        Uri.parse('$baseUrl/employees?active=true&attributes=team'),
        headers: {
          'Content-Type': 'application/json',
          'access-token': token,
        },
      );

      Set<String> equipasUnicas = {};
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List employees = body['employees'] ?? body['data'] ?? [];
        
        for (var emp in employees) {
          if (emp is! Map) continue;
          String equipeName = 'Geral';
          if (emp['team'] is Map) {
            equipeName = emp['team']['name']?.toString() ?? 'Geral';
          } else if (emp['team'] != null) {
            equipeName = emp['team'].toString();
          }
          equipasUnicas.add(equipeName);
        }
      }

      setState(() {
        _todasAsEquipes = equipasUnicas.toList()..sort();
        _equipesSelecionadas = List.from(salvas);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar equipas: $e');
    }
  }

  Future<void> _salvar() async {
    await ObraEquipeService.salvarEquipesDaObra(widget.nomeObra, _equipesSelecionadas);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipas associadas com sucesso!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipas da Obra: ${widget.nomeObra}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todasAsEquipes.isEmpty
              ? const Center(child: Text('Nenhuma equipa encontrada no Pontomais.'))
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