import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatelessWidget {
  // A tela continua recebendo a lista de transações do widget pai
  final List<Map<String, dynamic>> transacoes;
  
  const DashboardScreen({super.key, required this.transacoes});

  // Função para processar os dados e preparar para o gráfico
  Map<String, double> get gastosPorCategoria {
    final Map<String, double> dados = {};
    for (var transacao in transacoes) {
      if (transacao['tipo'] == 'Despesa') {
        final categoria = transacao['categoria'] as String;
        final valor = transacao['valor'] as double;
        // Soma os valores para cada categoria
        dados.update(categoria, (value) => value + valor.abs(), ifAbsent: () => valor.abs());
      }
    }
    return dados;
  }
  
  @override
  Widget build(BuildContext context) {
    // --- 1. CÁLCULO DINÂMICO DO SALDO ---
    // Usamos o método 'fold' para somar todos os valores da lista de transações.
    // O valor inicial da soma é 0.0.
    final double saldoTotal = transacoes.fold(0.0, (somaAnterior, item) => somaAnterior + (item['valor'] as double));

    // Prepara os dados para o gráfico
    final dadosGrafico = gastosPorCategoria;
    final totalGastos = dadosGrafico.values.fold(0.0, (sum, item) => sum + item);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        
        title: Image.asset(
          'assets/logo_splash.png',
          height: 32,
        ),

        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        
        iconTheme: const IconThemeData(
          color: Colors.black54, // Cor para o botão de voltar
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card do Saldo agora com o valor dinâmico
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Atual', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  // O Text agora usa a variável 'saldoTotal' formatada para 2 casas decimais
                  Text(
                    'R\$ ${saldoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // --- 2. MELHORIA NO ESPAÇAMENTO ---
          // Aumentamos o espaçamento vertical para dar mais "respiro" ao layout
          const SizedBox(height: 32), 

          const Text('Gastos por Categoria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          
          // Gráfico de Pizza
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: dadosGrafico.entries.map((entry) {
                  final percentual = totalGastos > 0 ? (entry.value / totalGastos) * 100 : 0.0;
                  return PieChartSectionData(
                    color: Colors.primaries[dadosGrafico.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                    value: entry.value,
                    title: '${percentual.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 38),

          // --- 3. CONSTRUÇÃO DA LEGENDA DO GRÁFICO ---
          // Usamos um widget 'Wrap' para que a legenda se ajuste automaticamente
          // caso tenha muitas categorias.
          Wrap(
            spacing: 16.0, // Espaçamento horizontal entre os itens da legenda
            runSpacing: 8.0, // Espaçamento vertical entre as linhas da legenda
            alignment: WrapAlignment.center,
            children: dadosGrafico.keys.map((categoria) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: Colors.primaries[dadosGrafico.keys.toList().indexOf(categoria) % Colors.primaries.length],
                  ),
                  const SizedBox(width: 6),
                  Text(categoria),
                ],
              );
            }).toList(),
          ),
          
          // --- 2. MELHORIA NO ESPAÇAMENTO ---
          const SizedBox(height: 32), 
          
          const Text('Transações Recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Usamos 'Column' aqui em vez de 'Expanded' porque a tela toda agora é rolável
          Column(
            children: transacoes.map((transacao) {
              final valor = transacao['valor'] as double? ?? 0.0;
              final tipo = transacao['tipo'] as String? ?? 'Despesa';
              return Card(
                child: ListTile(
                  leading: Icon(
                    tipo == 'Receita' ? Icons.arrow_upward : Icons.arrow_downward,
                    color: tipo == 'Receita' ? Colors.green : Colors.red,
                  ),
                  title: Text(transacao['descricao'] as String? ?? ''),
                  subtitle: Text(transacao['categoria'] as String? ?? ''),
                  trailing: Text(
                    'R\$ ${valor.abs().toStringAsFixed(2)}',
                    style: TextStyle(color: tipo == 'Receita' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}