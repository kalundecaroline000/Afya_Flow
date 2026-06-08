import 'package:flutter/material.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String invoiceId;
  final String amount;

  const PaymentCheckoutScreen({
    super.key,
    required this.invoiceId,
    required this.amount,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  String _selectedMethod = 'M-Pesa';
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate network processing time for the payment gateway connection
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Show a beautiful success confirmation alert box
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.teal, size: 60),
              SizedBox(height: 12),
              Text('Payment Successful', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Your payment for ${widget.invoiceId} amounting to ${widget.amount} has been successfully processed via $_selectedMethod.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Pop the dialog box
                Navigator.pop(context);
                // Pop back to the invoices dashboard screen
                Navigator.pop(context);
              },
              child: const Text('Back to Billing', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isProcessing
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Initiating Secure Transaction Engine...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Summary Summary Card
            Card(
              color: Colors.teal.withAlpha(15),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.teal, width: 0.5)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.invoiceId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const Text('Total Outstanding Balance', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Text(widget.amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Interactive Radio Select Options
            RadioListTile<String>(
              title: const Text('M-Pesa Express (STK Push)'),
              value: 'M-Pesa',
              groupValue: _selectedMethod,
              activeColor: Colors.teal,
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            RadioListTile<String>(
              title: const Text('Credit / Debit Card'),
              value: 'Card',
              groupValue: _selectedMethod,
              activeColor: Colors.teal,
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            const SizedBox(height: 16),

            if (_selectedMethod == 'M-Pesa') ...[
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Enter M-Pesa Phone Number',
                  hintText: 'e.g. 0743131599',
                  prefixIcon: Icon(Icons.phone_android, color: Colors.teal),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _selectedMethod == 'M-Pesa' ? 'Send STK Prompt' : 'Pay via Secure Card Gateway',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}