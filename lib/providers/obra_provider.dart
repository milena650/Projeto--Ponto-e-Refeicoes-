import 'package:flutter/material.dart';
import '../models/funcionario_model.dart';
import '../services/pontomais_service.dart';

class ObraProvider extends ChangeNotifier {
  String? _obraSelecionada;
  List<Funcionario> _funcionarios = [];
  bool _isLoading = false;
  String? _mensagemErro;

  String? get obraSelecionada => _obraSelecionada;
  List<Funcionario> get funcionarios => _funcionarios;
  bool get isLoading => _isLoading;
  String? get mensagemErro => _mensagemErro;

  void selecionarObra(String obra) {
    _obraSelecionada = obra;
    buscarDadosPontomais();
  }

  Future<void> buscarDadosPontomais() async {
    if (_obraSelecionada == null) return;

    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      // Pega a data atual em formato YYYY-MM-DD
      final hoje = DateTime.now().toIso8601String().split('T')[0];
      
      _funcionarios = await PontomaisService.buscarMarcacoesPorObra(_obraSelecionada!, hoje);
    } catch (e) {
      _mensagemErro = 'Não foi possível carregar os dados da Pontomais.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Contadores automáticos
  int get totalCafeManha => _funcionarios.where((f) => f.temDireitoCafeManha).length;
  int get totalAlmoco => _funcionarios.where((f) => f.temDireitoAlmoco).length;
  int get totalCafeTarde => _funcionarios.where((f) => f.temDireitoCafeTarde).length;
}