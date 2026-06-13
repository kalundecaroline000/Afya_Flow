import 'package:flutter/material.dart';
import 'payment_checkout_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      appBar: AppBar(
        title: const Text('Billing & Invoices',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Outstanding Balance Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.teal, Color(0xFF006D6D)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Outstanding', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('KES 4,800.00',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),

          // 2. Filter Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Paid'),
            ],
          ),

          // 3. Invoice List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvoiceList('all'),
                _buildInvoiceList('pending'),
                _buildInvoiceList('paid'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(String filter) {
    // Mock data for the UI
    final invoices = [
      {'id': 'INV-2025-0045', 'service': 'Dental Cleaning', 'date': 'June 12, 2025', 'amount': 'KES 4,800.00', 'status': 'pending'},
      {'id': 'INV-2025-0042', 'service': 'Lab Diagnostics', 'date': 'June 04, 2025', 'amount': 'KES 3,500.00', 'status': 'paid'},
      {'id': 'INV-2025-0039', 'service': 'Pharmacy Bill', 'date': 'May 28, 2025', 'amount': 'KES 1,200.00', 'status': 'paid'},
    ];

    final filteredList = filter == 'all'
        ? invoices
        : invoices.where((i) => i['status'] == filter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final invoice = filteredList[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(Map<String, String> invoice) {
    bool isPaid = invoice['status'] == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(invoice['id']!, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'PENDING',
                  style: TextStyle(
                      color: isPaid ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(invoice['service']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(invoice['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(invoice['amount']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)
              ),
              if (!isPaid)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentCheckoutScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}