import 'dart:io';

enum ItemType { standard, loose }

class Product {
  final String id;
  String name;
  double buyPrice;
  double sellPrice;
  double stock;
  ItemType type;
  String? unit;
  String? barcode;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.type = ItemType.standard,
    this.unit = 'pcs',
    this.barcode,
    this.imagePath,
  });
}

class CartItem {
  final Product product;
  double quantity;
  double customPrice;

  CartItem({
    required this.product,
    required this.quantity,
    required this.customPrice,
  });

  double get total => quantity * customPrice;
}

class UdhaarRecord {
  final String personName;
  final String phone;
  final double amount;
  final DateTime date;

  UdhaarRecord({
    required this.personName,
    required this.phone,
    required this.amount,
    required this.date,
  });
}

class SaleHistory {
  final String id;
  final DateTime date;
  final double total;
  final String paymentMode;
  final List<CartItem> items;
  final String? customerName;

  SaleHistory({
    required this.id,
    required this.date,
    required this.total,
    required this.paymentMode,
    required this.items,
    this.customerName,
  });
}
