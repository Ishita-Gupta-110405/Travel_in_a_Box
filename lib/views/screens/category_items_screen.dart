import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/closet_viewmodel.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String category;
  const CategoryItemsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final closetVM = Provider.of<ClosetViewModel>(context);
    final items = closetVM.getItemsByCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(category.toUpperCase())),
      body: items.isEmpty
          ? const Center(child: Text("No items in this section.", style: TextStyle(color: Colors.white24)))
          : GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(item.imageUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)))),
                Padding(padding: const EdgeInsets.all(10), child: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          );
        },
      ),
    );
  }
}