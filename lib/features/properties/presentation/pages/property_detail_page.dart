import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/installments/presentation/providers/installment_providers.dart';
import 'package:proptrack/features/installments/presentation/widgets/installment_tile.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';

const Color _navyBlue = Color(0xFF1A2B4A);
const Color _bgGrey = Color(0xFFF5F6FA);
const Color _greenPaid = Color(0xFF10B981);

class PropertyDetailPage extends ConsumerWidget {
  const PropertyDetailPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(selectedPropertyProvider(propertyId));

    if (property == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _navyBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final progressValue = property.totalPrice > 0
        ? (property.paidAmount / property.totalPrice).clamp(0.0, 1.0)
        : 0.0;

    String getPropertyStatus() {
      if (property.totalInstallments == 0) return 'On Track';
      if (property.paidInstallments >= property.totalInstallments) {
        return 'Completed';
      }
      final handoverDate = property.handoverDate;
      if (handoverDate != null) {
        final daysUntilHandover =
            handoverDate.difference(DateTime.now()).inDays;
        if (daysUntilHandover < 0) return 'Overdue';
        if (daysUntilHandover <= 30) return 'Due Soon';
      }
      return 'On Track';
    }

    ({Color bgColor, Color textColor}) getStatusColors(String status) {
      switch (status) {
        case 'Overdue':
          return (
            bgColor: const Color(0xFFFEF2F2),
            textColor: const Color(0xFFDC2626),
          );
        case 'Due Soon':
          return (
            bgColor: const Color(0xFFFFF7ED),
            textColor: const Color(0xFFC2410C),
          );
        case 'Completed':
          return (
            bgColor: const Color(0xFFDCFCE7),
            textColor: const Color(0xFF16A34A),
          );
        default:
          return (
            bgColor: const Color(0xFFDCFCE7),
            textColor: const Color(0xFF16A34A),
          );
      }
    }

    Color getProgressBarColor(String status) {
      switch (status) {
        case 'Overdue':
          return const Color(0xFFDC2626);
        case 'Due Soon':
          return const Color(0xFFC2410C);
        default:
          return _greenPaid;
      }
    }

    final status = getPropertyStatus();
    final statusColors = getStatusColors(status);
    final progressBarColor = getProgressBarColor(status);

    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: _navyBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          property.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: property name + status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _navyBlue,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColors.bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColors.textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Developer row
                    if (property.developer != null &&
                        property.developer!.isNotEmpty)
                      _buildPropertyRow(
                        Icons.business_outlined,
                        property.developer!,
                      ),

                    // Location row
                    if (property.location != null &&
                        property.location!.isNotEmpty)
                      _buildPropertyRow(
                        Icons.location_on_outlined,
                        property.location!,
                      ),

                    // Handover date row
                    if (property.handoverDate != null)
                      _buildPropertyRow(
                        Icons.calendar_today_outlined,
                        DateFormat('d MMM yyyy').format(property.handoverDate!),
                      ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 12),

                    // Total price
                    Text(
                      '${property.currency} ${NumberFormat('#,##0.00').format(property.totalPrice)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _navyBlue,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 12),

                    // Payment Progress section
                    Text(
                      'Payment Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressBarColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${property.paidInstallments} of ${property.totalInstallments} installments paid',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Installments Section
            Padding(
              padding: EdgeInsets.zero,
              child: Text(
                'Installments',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _navyBlue,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Installments List
            Consumer(
              builder: (context, ref, _) {
                final installments =
                    ref.watch(installmentNotifierProvider(propertyId));
                final installmentNotifier =
                    ref.read(installmentNotifierProvider(propertyId).notifier);

                return installments.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading installments',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  data: (installmentsList) {
                    if (installmentsList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No installments yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _navyBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, size: 20),
                                    SizedBox(width: 6),
                                    Text('Add Installment'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: installmentsList
                          .map(
                            (inst) => InstallmentTile(
                              installment: inst,
                              currency: property.currency,
                              onToggle: (isPaid) => installmentNotifier
                                  .togglePaid(inst.id, isPaid),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _navyBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildPropertyRow(IconData icon, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      );
}
