import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hosted_checkout_webview.dart';

class PaymentDemoPage extends ConsumerStatefulWidget {
  const PaymentDemoPage({super.key});
  @override
  ConsumerState<PaymentDemoPage> createState() => _PaymentDemoPageState();
}

class _PaymentDemoPageState extends ConsumerState<PaymentDemoPage> {
  final _jobIdCtrl = TextEditingController(text: 'demo-job-123');
  final _amountCtrl = TextEditingController(text: '500'); // PKR

  bool loading = false;
  String? lastStatus;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Payments Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _jobIdCtrl, decoration: const InputDecoration(labelText: 'Job ID')),
          const SizedBox(height: 8),
          TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (PKR)')),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.credit_card),
              label: const Text('Pay with Stripe'),
              onPressed: loading ? null : () => _payStripe(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('JazzCash Checkout'),
              onPressed: loading ? null : () => _payJazzCash(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance),
              label: const Text('Easypaisa Checkout'),
              onPressed: loading ? null : () => _payEasypaisa(),
            ),
          ]),
          const SizedBox(height: 16),
          if (lastStatus != null) Text('Status: $lastStatus'),
          const Spacer(),
          if (user != null) Text('Signed in as ${user.phone ?? user.uid}', style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }

  Future<void> _payStripe() async {
    setState(() { loading = true; lastStatus = null;});
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createStripePaymentIntent');
      final res = await callable.call({'jobId': _jobIdCtrl.text, 'amountPkr': int.parse(_amountCtrl.text)});
      final data = Map<String, dynamic>.from(res.data);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'FixIt',
          style: ThemeMode.system,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      final confirm = FirebaseFunctions.instance.httpsCallable('confirmPayment');
      await confirm.call({'jobId': _jobIdCtrl.text, 'gateway': 'stripe'});
      setState(() => lastStatus = 'Stripe Payment successful');
    } catch (e) {
      setState(() => lastStatus = 'Stripe error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _payJazzCash() async {
    setState(() { loading = true; lastStatus = null;});
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createJazzCashCheckout');
      final res = await callable.call({'jobId': _jobIdCtrl.text, 'amountPkr': int.parse(_amountCtrl.text)});
      final data = Map<String, dynamic>.from(res.data);
      if (!mounted) return;
      final ok = await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HostedCheckoutWebView(
          postUrl: data['postUrl'],
          fields: Map<String, String>.from(data['fields']),
          successUrlPrefix: data['returnUrl'],
        ),
      ));
      if (ok == true) {
        final confirm = FirebaseFunctions.instance.httpsCallable('confirmPayment');
        await confirm.call({'jobId': _jobIdCtrl.text, 'gateway': 'jazzcash'});
        setState(() => lastStatus = 'JazzCash success');
      } else {
        setState(() => lastStatus = 'JazzCash cancelled/failed');
      }
    } catch (e) {
      setState(() => lastStatus = 'JazzCash error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _payEasypaisa() async {
    setState(() { loading = true; lastStatus = null;});
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createEasypaisaCheckout');
      final res = await callable.call({'jobId': _jobIdCtrl.text, 'amountPkr': int.parse(_amountCtrl.text)});
      final data = Map<String, dynamic>.from(res.data);
      if (!mounted) return;
      final ok = await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HostedCheckoutWebView(
          postUrl: data['postUrl'],
          fields: Map<String, String>.from(data['fields']),
          successUrlPrefix: data['returnUrl'],
        ),
      ));
      if (ok == true) {
        final confirm = FirebaseFunctions.instance.httpsCallable('confirmPayment');
        await confirm.call({'jobId': _jobIdCtrl.text, 'gateway': 'easypaisa'});
        setState(() => lastStatus = 'Easypaisa success');
      } else {
        setState(() => lastStatus = 'Easypaisa cancelled/failed');
      }
    } catch (e) {
      setState(() => lastStatus = 'Easypaisa error: $e');
    } finally {
      setState(() => loading = false);
    }
  }
}
