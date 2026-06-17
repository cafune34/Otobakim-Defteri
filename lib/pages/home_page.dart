import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../widgets/app_summary_card.dart';
import '../widgets/section_title.dart';
import 'about_page.dart';
import 'expense_records_page.dart';
import 'maintenance_records_page.dart';
import 'vehicles_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _vehicleCount = 0;
  int _maintenanceCount = 0;
  int _expenseCount = 0;
  double _totalMaintenanceCost = 0.0;
  double _totalExpenseAmount = 0.0;
  double _grandTotalCost = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final dashboardValues = await Future.wait<num>([
        DatabaseHelper.instance.getVehicleCount(),
        DatabaseHelper.instance.getMaintenanceCount(),
        DatabaseHelper.instance.getExpenseCount(),
        DatabaseHelper.instance.getTotalMaintenanceCost(),
        DatabaseHelper.instance.getTotalExpenseAmount(),
        DatabaseHelper.instance.getGrandTotalCost(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicleCount = dashboardValues[0].toInt();
        _maintenanceCount = dashboardValues[1].toInt();
        _expenseCount = dashboardValues[2].toInt();
        _totalMaintenanceCost = dashboardValues[3].toDouble();
        _totalExpenseAmount = dashboardValues[4].toDouble();
        _grandTotalCost = dashboardValues[5].toDouble();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Özet bilgileri yüklenirken hata oluştu')),
      );
    }
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => page),
    );

    if (!mounted) {
      return;
    }

    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OtoBakım Defteri'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            tooltip: 'Hakkında',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Özet'),
              const SizedBox(height: 12),
              _buildDashboardContent(context),
              const SizedBox(height: 24),
              const SectionTitle('Menü'),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Araçlarım',
                description: 'Araç bilgilerini görüntüle ve yeni araç ekle.',
                icon: Icons.garage,
                onTap: () {
                  _navigateAndRefresh(const VehiclesPage());
                },
              ),
              _MenuCard(
                title: 'Bakım Kayıtları',
                description: 'Araç bakım geçmişini takip et.',
                icon: Icons.car_repair,
                onTap: () {
                  _navigateAndRefresh(const MaintenanceRecordsPage());
                },
              ),
              _MenuCard(
                title: 'Masraf Kayıtları',
                description: 'Araç masraflarını takip et.',
                icon: Icons.receipt_long,
                onTap: () {
                  _navigateAndRefresh(const ExpenseRecordsPage());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(height: 12),
              Text('Yükleniyor...'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 12),
        _GrandTotalCard(
          total: _grandTotalCost,
          maintenanceCount: _maintenanceCount,
          expenseCount: _expenseCount,
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final summaryCards = [
      AppSummaryCard(
        title: 'Araçlar',
        value: _vehicleCount.toString(),
        icon: Icons.directions_car,
      ),
      AppSummaryCard(
        title: 'Bakımlar',
        value: '${_totalMaintenanceCost.toStringAsFixed(2)} TL',
        icon: Icons.car_repair,
      ),
      AppSummaryCard(
        title: 'Masraflar',
        value: '${_totalExpenseAmount.toStringAsFixed(2)} TL',
        icon: Icons.payments,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            children: [
              for (var i = 0; i < summaryCards.length; i++) ...[
                summaryCards[i],
                if (i != summaryCards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: summaryCards,
        );
      },
    );
  }
}

class _GrandTotalCard extends StatelessWidget {
  const _GrandTotalCard({
    required this.total,
    required this.maintenanceCount,
    required this.expenseCount,
  });

  final double total;
  final int maintenanceCount;
  final int expenseCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.summarize, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Genel Toplam: ${total.toStringAsFixed(2)} TL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bakım kaydı: $maintenanceCount  •  Masraf kaydı: $expenseCount',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
