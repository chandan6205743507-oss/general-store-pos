import 'package:flutter/material.dart';
import 'models.dart';

class UdhaarDialog extends StatefulWidget {
  final List<UdhaarCustomer> customers;
  final double totalAmount;
  final Function(UdhaarCustomer) onAddCustomer;
  final Function(String customerName) onSelectCustomer;

  const UdhaarDialog({
    super.key,
    required this.customers,
    required this.totalAmount,
    required this.onAddCustomer,
    required this.onSelectCustomer,
  });

  @override
  State<UdhaarDialog> createState() => _UdhaarDialogState();
}

class _UdhaarDialogState extends State<UdhaarDialog> {
  int activeTab = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: activeTab == 0 ? const Color(0xFFDDD2B8) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Select person",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: activeTab == 0 ? const Color(0xFF4A3426) : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => activeTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: activeTab == 1 ? const Color(0xFFDDD2B8) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "New person",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: activeTab == 1 ? const Color(0xFF4A3426) : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeTab == 0)
              SizedBox(
                height: 200,
                child: widget.customers.isEmpty
                    ? const Center(
                        child: Text("Koi customer nahi mila", style: TextStyle(color: Colors.black45)),
                      )
                    : ListView.separated(
                        itemCount: widget.customers.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (c, i) {
                          final UdhaarCustomer cust = widget.customers[i];
                          return ListTile(
                            dense: true,
                            title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(cust.phone),
                            trailing: Text(
                              "Old: ₹${cust.pendingAmount.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelectCustomer(cust.name);
                            },
                          );
                        },
                      ),
              )
            else
              Column(
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Person name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CA655),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final String name = nameController.text.trim();
                        if (name.isEmpty) return;

                        final UdhaarCustomer newCust = UdhaarCustomer(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          phone: phoneController.text.trim(),
                          pendingAmount: widget.totalAmount,
                        );
                        widget.onAddCustomer(newCust);
                        Navigator.pop(context);
                        widget.onSelectCustomer(newCust.name);
                      },
                      child: const Text(
                        "Add Udhaar",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
