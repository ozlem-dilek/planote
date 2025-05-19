import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TodoScreenFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const TodoScreenFilterChip({Key? key, required this.label, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.todoFilterSelectedBackground : AppColors.todoFilterBackground,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            border: isSelected ? Border(bottom: BorderSide(color: AppColors.primary, width: 2.5)) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.todoFilterText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filterLabels = ["Tümü", "Listelerim", "Bugün"];

  // Örnek To-Do item listesi
  final List<Map<String, dynamic>> _todoItems = List.generate(15, (i) => {
    "id": i,
    "metric": (i * 5 + (i % 3 == 0 ? 12 : 7)) % 25 == 0 ? 5 : (i * 5 + (i % 3 == 0 ? 12 : 7)) % 25,
    "title": "To-Do Öğesi ${i + 1}",
  });

  @override
  Widget build(BuildContext context) {
    // Bu widget AppShell'in body'sinde gösterilecek, bu yüzden kendi Scaffold'u yok.
    // AppShell'deki SafeArea genel bir koruma sağlar, gerekirse burada da kullanılabilir.
    return Column(
      children: [

        Container(
          color: AppColors.todoAppBarBackground,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 0,
              left: 4,
              right: 16,
              bottom: 0
          ),
          child: Row(
            children: [
              Builder(
                  builder: (buttonContext) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.primaryText),
                      onPressed: () {
                        Scaffold.of(buttonContext).openDrawer();
                      },
                      tooltip: 'Menüyü Aç',
                    );
                  }
              ),
              const Text(
                'To-Do List',
                style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 20 // Biraz küçülttüm
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        Container(
          color: AppColors.todoAppBarBackground,
          child: Container(
            decoration: const BoxDecoration(
                color: AppColors.todoFilterBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: List.generate(_filterLabels.length, (index) {
                return TodoScreenFilterChip(
                  label: _filterLabels[index],
                  isSelected: _selectedFilterIndex == index,
                  onTap: () {
                    setState(() { _selectedFilterIndex = index; });
                    // TODO: Provider ile listeyi bu alt filtreye göre filtrele
                  },
                );
              }),
            ),
          ),
        ),

        // 3. To-Do Listesi
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.separated(
              itemCount: _todoItems.length, // TODO: Provider'dan filtrelenmiş liste
              itemBuilder: (context, index) {
                final item = _todoItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      item['metric'].toString(),
                      style: const TextStyle(fontSize: 15, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(item['title'], style: const TextStyle(color: AppColors.primaryText, fontSize: 16)),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 0.5, indent: 24, endIndent: 24, color: AppColors.screenBackground),
            ),
          ),
        ),

        // 4. Alt Komut/Giriş Alanı
        /*Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppColors.screenBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.short_text_rounded, color: AppColors.secondaryText.withOpacity(0.8)),
                  const SizedBox(width: 12),
                  Icon(Icons.data_object_rounded, color: AppColors.secondaryText.withOpacity(0.8)),
                  const SizedBox(width: 12),
                  Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.secondaryText.withOpacity(0.8)),
                ],
              ),
              Text(
                "Sans, Wot Gcsbn", // Ekran görüntüsündeki metin
                style: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 11),
              ),
            ],
          ),
        ) */
      ],
    );
  }
}