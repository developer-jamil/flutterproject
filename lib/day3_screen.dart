import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final bool inStock;

  const Product({
    required this.name,
    required this.price,
    this.inStock = true,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    name: j['name'] as String? ?? '',
    price: (j['price'] as num?)?.toDouble() ?? 0,
    inStock: (j['in_stock'] as int? ?? 0) == 1,
  );

  double get priceWithVat => price * 1.15;
}

class Day3Screen extends StatelessWidget {
  const Day3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Product.fromJson(const {
      'name': 'শীতের চাদর',
      'price': 1200,
      'in_stock': 1,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('দিন ৩')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, height: 1.6,
            )),
            const SizedBox(height: 8),
            Text('দাম ৳${p.price.toStringAsFixed(0)}'),
            Text('ভ্যাটসহ ৳${p.priceWithVat.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text(p.inStock ? 'স্টকে আছে' : 'স্টক শেষ'),
          ],
        ),
      ),
    );
  }
}
