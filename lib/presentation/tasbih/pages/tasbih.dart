
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _DhikrItem {
  final String id;
  String text;
  int count;
  int totalCount;
  int target;
  final bool isCustom;

  _DhikrItem({
    required this.id,
    required this.text,
    this.count = 0,
    this.totalCount = 0,
    this.target = 33,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'target': target,
  };
}

class _TasbihPageState extends State<TasbihPage> {
  static const List<String> defaultAdhkar = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'أَسْتَغْفِرُ اللَّهَ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
  ];

  static const String _customListKey = 'tasbih_custom_adhkar';
  static const String _selectedKey = 'tasbih_selected_id';

  final List<_DhikrItem> _items = [];

  String? _selectedId;
  bool _isLoading = true;

  _DhikrItem? get _selectedItem {
    for (final item in _items) {
      if (item.id == _selectedId) return item;
    }
    return _items.isNotEmpty ? _items.first : null;
  }

  String _countKey(_DhikrItem item) {
    if (!item.isCustom) {
      final index = int.parse(item.id.split('_').last);
      return 'tasbih_count_$index';
    }
    return 'tasbih_count_${item.id}';
  }

  String _totalKey(_DhikrItem item) {
    if (!item.isCustom) {
      final index = int.parse(item.id.split('_').last);
      return 'tasbih_total_$index';
    }
    return 'tasbih_total_${item.id}';
  }

  String _targetKey(_DhikrItem item) => 'tasbih_target_${item.id}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final loadedItems = <_DhikrItem>[];

    for (int i = 0; i < defaultAdhkar.length; i++) {
      loadedItems.add(
        _DhikrItem(
          id: 'builtin_$i',
          text: defaultAdhkar[i],
        ),
      );
    }

    final customJson = prefs.getString(_customListKey);

    if (customJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(customJson);

        for (final data in decoded) {
          if (data is! Map) continue;

          final id = data['id']?.toString();
          final text = data['text']?.toString();

          if (id == null || text == null || text.trim().isEmpty) {
            continue;
          }

          loadedItems.add(
            _DhikrItem(
              id: id,
              text: text,
              target: (data['target'] as num?)?.toInt() ?? 33,
              isCustom: true,
            ),
          );
        }
      } catch (_) {
        // Ignore invalid saved custom data.
      }
    }

    for (final item in loadedItems) {
      item.count = prefs.getInt(_countKey(item)) ?? 0;
      item.totalCount = prefs.getInt(_totalKey(item)) ?? 0;
      item.target = prefs.getInt(_targetKey(item)) ?? item.target;

      if (item.target < 1) item.target = 33;
    }

    final savedSelectedId = prefs.getString(_selectedKey);

    if (!mounted) return;

    setState(() {
      _items
        ..clear()
        ..addAll(loadedItems);

      _selectedId = _items.any((item) => item.id == savedSelectedId)
          ? savedSelectedId
          : _items.first.id;

      _isLoading = false;
    });
  }

  Future<void> _saveCustomItems() async {
    final prefs = await SharedPreferences.getInstance();

    final customItems = _items
        .where((item) => item.isCustom)
        .map((item) => item.toJson())
        .toList();

    await prefs.setString(
      _customListKey,
      jsonEncode(customItems),
    );
  }

  Future<void> _saveItem(_DhikrItem item) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_countKey(item), item.count);
    await prefs.setInt(_totalKey(item), item.totalCount);
    await prefs.setInt(_targetKey(item), item.target);
  }

  Future<void> _selectDhikr(String? id) async {
    if (id == null || !_items.any((item) => item.id == id)) return;

    setState(() {
      _selectedId = id;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, id);
  }

  Future<void> _increment() async {
    final item = _selectedItem;
    if (item == null) return;

    setState(() {
      item.count++;
      item.totalCount++;
    });

    await _saveItem(item);

    if (item.count == item.target && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ما شاء الله! أكملت العدد المطلوب'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetCount() async {
    final item = _selectedItem;
    if (item == null) return;

    setState(() {
      item.count = 0;
    });

    await _saveItem(item);
  }

  Future<void> _changeTarget(int? value) async {
    if (value == null || value < 1) return;

    final item = _selectedItem;
    if (item == null) return;

    setState(() {
      item.target = value;
    });

    await _saveItem(item);

    if (item.isCustom) {
      await _saveCustomItems();
    }
  }

  Future<Map<String, dynamic>?> _showDhikrDialog({
    String initialText = '',
    int initialTarget = 33,
    required String title,
  }) async {
    final textController = TextEditingController(text: initialText);
    final targetController = TextEditingController(
      text: initialTarget.toString(),
    );

    String? errorMessage;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'الذكر أو الدعاء',
                        hintText: 'اكتب الذكر هنا',
                        prefixIcon: Icon(Icons.edit_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العدد المستهدف',
                        hintText: 'مثال: 100',
                        prefixIcon: Icon(Icons.numbers_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    final target = int.tryParse(
                      targetController.text.trim(),
                    );

                    if (text.isEmpty) {
                      setDialogState(() {
                        errorMessage = 'من فضلك اكتب الذكر أولاً';
                      });
                      return;
                    }

                    if (target == null || target < 1) {
                      setDialogState(() {
                        errorMessage = 'أدخل عددًا صحيحًا أكبر من صفر';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'text': text,
                      'target': target,
                    });
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();
    targetController.dispose();

    return result;
  }

  Future<void> _addDhikr() async {
    final result = await _showDhikrDialog(
      title: 'إضافة ذكر جديد',
    );

    if (result == null || !mounted) return;

    final id = 'custom_${DateTime.now().microsecondsSinceEpoch}';

    final item = _DhikrItem(
      id: id,
      text: result['text'] as String,
      target: result['target'] as int,
      isCustom: true,
    );

    setState(() {
      _items.add(item);
      _selectedId = item.id;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, item.id);
    await _saveCustomItems();
    await _saveItem(item);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الذكر بنجاح'),
      ),
    );
  }

  Future<void> _editDhikr(_DhikrItem item) async {
    final result = await _showDhikrDialog(
      title: 'تعديل الذكر',
      initialText: item.text,
      initialTarget: item.target,
    );

    if (result == null || !mounted) return;

    setState(() {
      item.text = result['text'] as String;
      item.target = result['target'] as int;
    });

    await _saveItem(item);

    if (item.isCustom) {
      await _saveCustomItems();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعديل الذكر')),
    );
  }

  Future<void> _deleteDhikr(_DhikrItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الذكر'),
        content: Text('هل تريد حذف "${item.text}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _items.removeWhere((entry) => entry.id == item.id);

      if (_selectedId == item.id) {
        _selectedId = _items.first.id;
      }
    });

    await prefs.remove(_countKey(item));
    await prefs.remove(_totalKey(item));
    await prefs.remove(_targetKey(item));
    await prefs.setString(_selectedKey, _selectedId!);
    await _saveCustomItems();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الذكر')),
    );
  }

  void _showDhikrOptions(_DhikrItem item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('تعديل الذكر والعدد المستهدف'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editDhikr(item);
                },
              ),
              if (item.isCustom)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text('حذف الذكر'),
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _deleteDhikr(item);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = isDark
        ? Colors.greenAccent
        : Colors.green.shade800;

    if (_isLoading || _items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('السبحة الإلكترونية'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final item = _selectedItem!;
    final progress = (item.count / item.target).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('السبحة الإلكترونية'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'إضافة ذكر جديد',
            onPressed: _addDhikr,
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: 'إعادة العداد',
            onPressed: _resetCount,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'أذكاري',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_selectedId),
                    initialValue: _selectedId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(
                        Icons.auto_awesome_rounded,
                        color: primary,
                      ),
                    ),
                    items: _items.map((dhikr) {
                      return DropdownMenuItem<String>(
                        value: dhikr.id,
                        child: Text(
                          dhikr.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                      );
                    }).toList(),
                    onChanged: _selectDhikr,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'تعديل الذكر',
                  onPressed: () => _showDhikrOptions(item),
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addDhikr,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('إضافة ذكر من عندي'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: isDark
                      ? const [
                    Color(0xFF173B30),
                    Color(0xFF10251F),
                  ]
                      : const [
                    Color(0xFFE4F4E9),
                    Color(0xFFF5FBF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    item.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 210,
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 9,
                            strokeCap: StrokeCap.round,
                            backgroundColor:
                            primary.withValues(alpha: 0.15),
                            color: primary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.count}',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            Text(
                              'من ${item.target}',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'الإجمالي: ${item.totalCount} تسبيحة',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _increment,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor:
                        isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'سَبِّح',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _resetCount,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('إعادة العداد'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'العدد المستهدف',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [33, 99, 100].map((value) {
                return ChoiceChip(
                  label: Text('$value'),
                  selected: item.target == value,
                  onSelected: (_) => _changeTarget(value),
                  selectedColor: primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await _showDhikrDialog(
                  title: 'تغيير العدد المستهدف',
                  initialText: item.text,
                  initialTarget: item.target,
                );

                if (result != null && mounted) {
                  await _changeTarget(result['target'] as int);

                  if (item.isCustom) {
                    setState(() {
                      item.text = result['text'] as String;
                    });
                    await _saveCustomItems();
                  }
                }
              },
              icon: const Icon(Icons.tune_rounded),
              label: const Text('تحديد عدد مخصص'),
            ),
            const SizedBox(height: 24),
            Text(
              'أذكاري المحفوظة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._items.where((entry) => entry.isCustom).map((dhikr) {
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.bookmark_added_rounded,
                    color: primary,
                  ),
                  title: Text(
                    dhikr.text,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${dhikr.count} / ${dhikr.target}  •  '
                        'الإجمالي ${dhikr.totalCount}',
                  ),
                  onTap: () => _selectDhikr(dhikr.id),
                  trailing: IconButton(
                    tooltip: 'خيارات الذكر',
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () => _showDhikrOptions(dhikr),
                  ),
                ),
              );
            }),
            if (!_items.any((entry) => entry.isCustom))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'لسه مفيش أذكار مخصصة. اضغط «إضافة ذكر من عندي».',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
