import 'package:flutter/material.dart';
import 'models.dart';

class ShopTabScreen extends StatelessWidget {
  final List<Product> items;
  final bool isLoose;
  final VoidCallback onToggleMode;
  final VoidCallback onAddStock;
  final Function(Product) onEditItem;
  final Function(String) onSearch;

  const ShopTabScreen({
    super.key,
    required this.items,
    required this.isLoose,
    required this.onToggleMode,
    required this.onAddStock,
    required this.onEditItem,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final list = items.where((p) => p.isLoose == isLoose).toList();

    return Column(
      children: [
        Container(
          color: const Color(0xFFF9F7F1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0DDD5)),
                      ),
                      child: TextField(
                        onChanged: onSearch,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: Colors.black45),
                          hintText: isLoose ? "Search loose item" : "Search barcode item",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onToggleMode,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE8D8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isLoose ? Icons.shopping_bag : Icons.qr_code_scanner,
                        color: const Color(0xFF8D6E63),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCA134),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: onAddStock,
                  child: Text(
                    isLoose ? "Stock loose item" : "Stock barcode items",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text("No items found. Tap button to add stock."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final item = list[i];
                    return GestureDetector(
                      onTap: () => onEditItem(item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0EBE1)),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EFE6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  item.isLoose ? Icons.grain : Icons.fastfood,
                                  color: const Color(0xFFDCA134),
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.stock.toStringAsFixed(0)} ${item.unit}",
                                    style: const TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "₹${item.sellPrice.toStringAsFixed(0)}${item.isLoose ? '/kg' : ''}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'models.dart';

class ShopTabScreen extends StatelessWidget {
  final List<Product> items;
  final bool isLoose;
  final VoidCallback onToggleMode;
  final VoidCallback onAddStock;
  final Function(Product) onEditItem;
  final Function(String) onSearch;

  const ShopTabScreen({
    super.key,
    required this.items,
    required this.isLoose,
    required this.onToggleMode,
    required this.onAddStock,
    required this.onEditItem,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final list = items.where((p) => p.isLoose == isLoose).toList();

    return Column(
      children: [
        Container(
          color: const Color(0xFFFAF9F5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              // Top Two Tabs: Shop items & Pending
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDD2B8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Shop items: ${list.length}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037), fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EFE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Pending  0",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Search Bar + Scanner / Bag icon
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDCD6C8)),
                      ),
                      child: TextField(
                        onChanged: onSearch,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 22),
                          hintText: isLoose ? "Search loose item" : "Search barcode item",
                          hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onToggleMode,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE4D5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isLoose ? Icons.shopping_bag_outlined : Icons.qr_code_scanner,
                        color: const Color(0xFF795548),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Golden Action Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC88523),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: onAddStock,
                  child: Text(
                    isLoose ? "Stock loose item" : "Stock barcode items",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Product List with Photos
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text("No items found. Tap button to add."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final item = list[i];
                    return GestureDetector(
                      onTap: () => onEditItem(item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEDE8DE)),
                          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFF3EFE6),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.fastfood, color: Color(0xFFC88523), size: 30),
                                      )
                                    : const Icon(Icons.fastfood, color: Color(0xFFC88523), size: 30),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.stock.toStringAsFixed(0)} ${item.unit}",
                                    style: const TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "₹${item.sellPrice.toStringAsFixed(0)}${item.isLoose ? '/kg' : ''}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
