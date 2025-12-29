import 'package:filevo/generated/l10n.dart';
import 'package:flutter/material.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    // هذه القيم عادة ما تأتي من Controller أو Provider
    double used = 4.0; // GB
    double total = 10.0; // GB
    double percent = used / total;

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).storage)), // ✅ نص مترجم
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: Theme.of(context).cardColor, // دعم الوضع الليلي
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).storageUsage, // ✅ نص مترجم
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      // ✅ نص مترجم مع تمرير الأرقام كمتغيرات
                      S
                          .of(context)
                          .usedOfTotal(
                            used.toStringAsFixed(1),
                            total.toStringAsFixed(1),
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: Text(S.of(context).buyStorage), // ✅ نص مترجم
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              S.of(context).purchaseComingSoon,
                            ), // ✅ نص مترجم
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
