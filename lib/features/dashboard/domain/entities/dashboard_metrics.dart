import 'package:equatable/equatable.dart';

class DashboardMetrics extends Equatable {
  final int totalProperties;
  final double totalInvested;
  final int upcomingPaymentsCount;
  final double upcomingPaymentsAmount;
  final int overduePaymentsCount;
  final double overduePaymentsAmount;

  const DashboardMetrics({
    required this.totalProperties,
    required this.totalInvested,
    required this.upcomingPaymentsCount,
    required this.upcomingPaymentsAmount,
    required this.overduePaymentsCount,
    required this.overduePaymentsAmount,
  });

  @override
  List<Object?> get props => [
    totalProperties,
    totalInvested,
    upcomingPaymentsCount,
    upcomingPaymentsAmount,
    overduePaymentsCount,
    overduePaymentsAmount,
  ];
}
