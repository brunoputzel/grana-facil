import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTransacaoTela extends StatefulWidget {
  const AddTransacaoTela({super.key});

  @override
  State<AddTransacaoTela> createState() => _AddTransacaoTelaState();
}

class _AddTransacaoTelaState extends State<AddTransacaoTela> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _valorConvertidoController = TextEditingController();

  String _tipoSelecionado = 'Despesa'; 
  final List<String> _categorias = ['Alimentação', 'Transporte', 'Moradia', 'Lazer', 'Salário', 'Vendas', 'Compras Online'];
  String? _categoriaSelecionada;

  String _moedaSelecionada = 'BRL';
  Map<String, double> _taxasDeCambio = {};
  String _statusCotacao = 'Buscando cotações...';

  @override
  void initState() {
    super.initState();
    _buscarCotacoes();
    _valorController.addListener(_converterValor);
  }

  Future<void> _buscarCotacoes() async {
    try {
      final [dolarResponse, euroResponse] = await Future.wait([
        http.get(Uri.parse('https://api.frankfurter.app/latest?from=USD&to=BRL')),
        http.get(Uri.parse('https://api.frankfurter.app/latest?from=EUR&to=BRL'))
      ]);

      if (dolarResponse.statusCode == 200 && euroResponse.statusCode == 200) {
        final dolarData = jsonDecode(dolarResponse.body);
        final euroData = jsonDecode(euroResponse.body);
        if (mounted) {
          setState(() {
            _taxasDeCambio = {
              'USD': dolarData['rates']['BRL'],
              'EUR': euroData['rates']['BRL'],
            };
            _statusCotacao = 'Cotações carregadas!';
          });
        }
      } else {
        throw Exception('Falha ao carregar cotações');
      }
    } catch (e) {
      if (mounted) {
        setState(() { _statusCotacao = 'Erro ao buscar cotações.'; });
      }
    }
  }

  void _converterValor() {
    final valorDigitado = double.tryParse(_valorController.text) ?? 0.0;
    
    if (valorDigitado == 0.0 || _moedaSelecionada == 'BRL' || _taxasDeCambio.isEmpty) {
      if (mounted) setState(() { _valorConvertidoController.clear(); });
      return;
    }

    double taxa = 1.0;
    if (_moedaSelecionada == 'USD') {
      taxa = _taxasDeCambio['USD']!;
    } else if (_moedaSelecionada == 'EUR') {
      taxa = _taxasDeCambio['EUR']!;
    }
    
    final valorFinal = valorDigitado * taxa;
    _valorConvertidoController.text = valorFinal.toStringAsFixed(2);
  }
  
  void _salvarTransacao() {
    final descricao = _descricaoController.text;
    final valorDigitado = double.tryParse(_valorController.text) ?? 0.0;

    if (descricao.isEmpty || valorDigitado == 0.0 || _categoriaSelecionada == null) return; 

    double valorFinalEmBRL = valorDigitado;
    if (_moedaSelecionada != 'BRL' && _taxasDeCambio.isNotEmpty) {
      double taxa = 1.0;
      if (_moedaSelecionada == 'USD') {
        taxa = _taxasDeCambio['USD']!;
      } else if (_moedaSelecionada == 'EUR') {
        taxa = _taxasDeCambio['EUR']!;
      }
      valorFinalEmBRL = valorDigitado * taxa;
    }

    final novaTransacao = {
      'descricao': descricao,
      'valor': _tipoSelecionado == 'Despesa' ? -valorFinalEmBRL : valorFinalEmBRL, 
      'tipo': _tipoSelecionado,
      'categoria': _categoriaSelecionada,
    };
    Navigator.of(context).pop(novaTransacao);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _valorConvertidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nova Transação', style: TextStyle(color: Colors.black87)),
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Despesa', label: Text('Despesa')),
                  ButtonSegment(value: 'Receita', label: Text('Receita')),
                ],
                selected: {_tipoSelecionado},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() { _tipoSelecionado = newSelection.first; });
                },
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valorController,
                      decoration: const InputDecoration(labelText: 'Valor', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: DropdownButtonFormField<String>(
                      value: _moedaSelecionada,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: ['BRL', 'USD', 'EUR'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (mounted) setState(() { _moedaSelecionada = newValue!; });
                        _converterValor();
                      },
                    ),
                  ),
                ],
              ),
              if (_moedaSelecionada != 'BRL')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: _valorConvertidoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Valor Convertido (BRL)',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.currency_exchange),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                hint: const Text('Selecione a Categoria'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categorias.map((String categoria) {
                  return DropdownMenuItem<String>(value: categoria, child: Text(categoria));
                }).toList(),
                onChanged: (String? newValue) {
                  if (mounted) setState(() { _categoriaSelecionada = newValue; });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvarTransacao,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Salvar Transação', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              if (_taxasDeCambio.isEmpty)
                Center(child: Text(_statusCotacao, style: TextStyle(color: Colors.grey[600])))
            ],
          ),
        ),
      ),
    );
  }
}