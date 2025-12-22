import 'package:flutter/material.dart';

import '../ui/theme.dart';
import './deslocamento_map_screen.dart';

class SelecionarDiasTrechoPage extends StatefulWidget {
  const SelecionarDiasTrechoPage({super.key, required this.dataInicio, required this.dataFim});
  final DateTime dataInicio;
  final DateTime dataFim;

  @override
  State<SelecionarDiasTrechoPage> createState() => _SelecionarDiasTrechoPageState();
}

class _SelecionarDiasTrechoPageState extends State<SelecionarDiasTrechoPage> {
  late final List<DateTime> _diasPeriodo;
  final Set<DateTime> _selecionados = <DateTime>{};
  final List<_TrechoDias> _trechos = <_TrechoDias>[];

  @override
  void initState() {
    super.initState();
    final inicio = DateTime(widget.dataInicio.year, widget.dataInicio.month, widget.dataInicio.day);
    final fim = DateTime(widget.dataFim.year, widget.dataFim.month, widget.dataFim.day);
    final total = fim.difference(inicio).inDays;
    _diasPeriodo = [for (int i = 0; i <= total; i++) inicio.add(Duration(days: i))];
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1976D2);
    const amarelo = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: azul,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
          ],
          centerTitle: true,
          title: const Text(
            'Selecionar dias para trechos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                children: [
                  Text(
                    _fmtPeriodo(widget.dataInicio, widget.dataFim),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Selecione os dias e informe o trecho no mapa',
                    style: TextStyle(color: amarelo, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleção de dias
              Text('Dias do período', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _diasPeriodo
                    .map(
                      (d) => _DiaChip(
                        date: d,
                        selected: _selecionados.any((s) => _isSameDate(s, d)),
                        onTap: () {
                          final day = DateTime(d.year, d.month, d.day);
                          setState(() {
                            if (_selecionados.any((s) => _isSameDate(s, day))) {
                              _selecionados.removeWhere((s) => _isSameDate(s, day));
                            } else {
                              _selecionados.add(day);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _selecionados.isEmpty
                            ? null
                            : () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeslocamentoMapScreen(returnResult: true)));
                                if (!mounted) return;
                                if (result is Map && (result['origem']?.toString().isNotEmpty ?? false) && (result['destino']?.toString().isNotEmpty ?? false)) {
                                  setState(() {
                                    _trechos.add(_TrechoDias(origem: result['origem'] as String, destino: result['destino'] as String, dias: Set<DateTime>.from(_selecionados)));
                                    _selecionados.clear();
                                  });
                                }
                              },
                        icon: const Icon(Icons.map),
                        label: const Text('Selecionar trecho no mapa'),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              Text('Trechos adicionados', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              if (_trechos.isEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: const Text('Nenhum trecho adicionado ainda.'),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < _trechos.length; i++) ...[
                      _TrechoItem(trecho: _trechos[i], onDelete: () => setState(() => _trechos.removeAt(i))),
                      if (i < _trechos.length - 1) const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _trechos),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Concluir', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtPeriodo(DateTime inicio, DateTime fim) {
    return 'Período: ${inicio.day}/${inicio.month}/${inicio.year} a ${fim.day}/${fim.month}/${fim.year}';
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DiaChip extends StatelessWidget {
  const _DiaChip({required this.date, required this.selected, required this.onTap});
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary.withOpacity(0.12) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: selected ? cs.primary : Colors.black54),
              const SizedBox(width: 6),
              Text(
                '${date.day}/${date.month}',
                style: TextStyle(color: selected ? cs.primary : Colors.black87, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrechoDias {
  final String origem;
  final String destino;
  final Set<DateTime> dias;
  _TrechoDias({required this.origem, required this.destino, required this.dias});
}

class _TrechoItem extends StatelessWidget {
  const _TrechoItem({required this.trecho, required this.onDelete});
  final _TrechoDias trecho;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final diasFmt = trecho.dias.toList()..sort((a, b) => a.compareTo(b));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [appShadow(0.04)],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.black54),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('${trecho.origem} → ${trecho.destino}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: diasFmt.map((d) => _DiaResumoChip(date: d)).toList()),
        ],
      ),
    );
  }
}

class _DiaResumoChip extends StatelessWidget {
  const _DiaResumoChip({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text('${date.day}/${date.month}', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
