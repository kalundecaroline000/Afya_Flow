import 'package:flutter/material.dart';
import 'payment_checkout_screen.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Invoices', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInvoiceCard(
            context,
            invoiceId: 'INV-2026-0042',
            service: 'Consultation & Lab Diagnostics',
            date: 'June 04, 2026',
            amount: 'KES 3,500.00',
            isPaid: false, // Changed to false so the user can test paying it!
          ),
          _buildInvoiceCard(
            context,
            invoiceId: 'INV-2026-0039',
            service: 'Pharmacy Prescription Dispensation',
            date: 'May 28, 2026',
            amount: 'KES 1,200.00',
            isPaid: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
      BuildContext context, {
        required String invoiceId,
        required String service,
        required String date,
        required String amount,
        required bool isPaid,
      }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!isPaid) {
            // Navigate directly to checkout if invoice is unpaid
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentCheckoutScreen(
                  invoiceId: invoiceId,
                  amount: amount,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This transaction invoice is fully settled! ✅'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(invoiceId, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(isPaid ? 'PAID' : 'PAY NOW', style: TextStyle(color: isPaid ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(service, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isPaid ? 'Total Amount' : 'Tap Card to Pay', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 13)),
                  Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}