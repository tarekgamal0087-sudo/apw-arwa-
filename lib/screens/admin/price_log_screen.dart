import 'package:flutter/material.dart';
import '../../models/price_log_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class PriceLogScreen extends StatelessWidget {
  const PriceLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل تغييرات الأسعار')),
        body: StreamBuilder<List<PriceLogModel>>(
          stream: firestoreService.getPriceLogs(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final logs = snapshot.data!;
            if (logs.isEmpty) {
              return const Center(
                  child: Text('لا يوجد تغييرات أسعار حتى الآن',
                      style: TextStyle(color: AppColors.textGray)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final increased = log.newSellPrice > log.oldSellPrice;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.productName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(Formatters.currency(log.oldSellPrice),
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textGray)),
                            const SizedBox(width: 8),
                            Icon(
                                increased
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                color: increased
                                    ? AppColors.danger
                                    : AppColors.success),
                            const SizedBox(width: 8),
                            Text(Formatters.currency(log.newSellPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'بواسطة: ${log.editedByName.isEmpty ? "غير معروف" : log.editedByName} - ${Formatters.date(log.date)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGray),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
