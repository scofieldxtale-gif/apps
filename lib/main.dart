import 'package:flutter/material.dart';

void main() {
  runApp(const KasirApp());
}

String rupiah(int value) {
  final text = value.toString();
  return 'Rp${text.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.icon,
  });

  final int id;
  String name;
  int price;
  String category;
  int stock;
  final IconData icon;
}

class Sale {
  Sale({
    required this.total,
    required this.items,
    required this.payment,
    required this.time,
  });

  final int total;
  final int items;
  final String payment;
  final DateTime time;
}

class KasirApp extends StatelessWidget {
  const KasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir Tab',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const KasirHome(),
    );
  }
}

class KasirHome extends StatefulWidget {
  const KasirHome({super.key});

  @override
  State<KasirHome> createState() => _KasirHomeState();
}

class _KasirHomeState extends State<KasirHome> {
  int pageIndex = 0;

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'Semua';

  final Map<int, int> cart = {};
  final List<Sale> sales = [];

  final List<Product> products = [
    Product(
      id: 1,
      name: 'Kopi Susu',
      price: 12000,
      category: 'Minuman',
      stock: 50,
      icon: Icons.coffee_rounded,
    ),
    Product(
      id: 2,
      name: 'Es Teh',
      price: 5000,
      category: 'Minuman',
      stock: 70,
      icon: Icons.local_drink_rounded,
    ),
    Product(
      id: 3,
      name: 'Air Mineral',
      price: 4000,
      category: 'Minuman',
      stock: 100,
      icon: Icons.water_drop_rounded,
    ),
    Product(
      id: 4,
      name: 'Mie Goreng',
      price: 15000,
      category: 'Makanan',
      stock: 35,
      icon: Icons.ramen_dining_rounded,
    ),
    Product(
      id: 5,
      name: 'Nasi Goreng',
      price: 18000,
      category: 'Makanan',
      stock: 30,
      icon: Icons.rice_bowl_rounded,
    ),
    Product(
      id: 6,
      name: 'Ayam Geprek',
      price: 20000,
      category: 'Makanan',
      stock: 25,
      icon: Icons.lunch_dining_rounded,
    ),
    Product(
      id: 7,
      name: 'Keripik',
      price: 8000,
      category: 'Snack',
      stock: 40,
      icon: Icons.cookie_rounded,
    ),
    Product(
      id: 8,
      name: 'Roti',
      price: 7000,
      category: 'Snack',
      stock: 28,
      icon: Icons.bakery_dining_rounded,
    ),
    Product(
      id: 9,
      name: 'Susu Kotak',
      price: 6500,
      category: 'Minuman',
      stock: 32,
      icon: Icons.local_cafe_rounded,
    ),
    Product(
      id: 10,
      name: 'Telur',
      price: 2500,
      category: 'Sembako',
      stock: 80,
      icon: Icons.egg_rounded,
    ),
    Product(
      id: 11,
      name: 'Beras 1 Kg',
      price: 16000,
      category: 'Sembako',
      stock: 20,
      icon: Icons.shopping_bag_rounded,
    ),
    Product(
      id: 12,
      name: 'Gula 1 Kg',
      price: 17000,
      category: 'Sembako',
      stock: 18,
      icon: Icons.inventory_2_rounded,
    ),
  ];

  List<String> get categories {
    final data = products.map((e) => e.category).toSet().toList();
    return ['Semua', ...data];
  }

  Product productById(int id) {
    return products.firstWhere((product) => product.id == id);
  }

  List<Product> get filteredProducts {
    final query = searchController.text.trim().toLowerCase();

    return products.where((product) {
      final categoryMatch = selectedCategory == 'Semua' ||
          product.category == selectedCategory;

      final searchMatch = query.isEmpty ||
          product.name.toLowerCase().contains(query);

      return categoryMatch && searchMatch;
    }).toList();
  }

  int get cartItems {
    return cart.values.fold(0, (a, b) => a + b);
  }

  int get cartTotal {
    int total = 0;

    for (final entry in cart.entries) {
      final product = productById(entry.key);
      total += product.price * entry.value;
    }

    return total;
  }

  void addToCart(Product product) {
    final current = cart[product.id] ?? 0;

    if (current >= product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok tidak mencukupi.'),
        ),
      );
      return;
    }

    setState(() {
      cart[product.id] = current + 1;
    });
  }

  void decreaseCart(Product product) {
    final current = cart[product.id] ?? 0;

    if (current <= 1) {
      setState(() {
        cart.remove(product.id);
      });
    } else {
      setState(() {
        cart[product.id] = current - 1;
      });
    }
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  Future<void> paymentDialog() async {
    if (cart.isEmpty) return;

    final method = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Pembayaran',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total ${rupiah(cartTotal)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                PaymentButton(
                  icon: Icons.payments_rounded,
                  title: 'Tunai',
                  subtitle: 'Hitung uang & kembalian',
                  onTap: () => Navigator.pop(context, 'Tunai'),
                ),
                const SizedBox(height: 10),
                PaymentButton(
                  icon: Icons.qr_code_2_rounded,
                  title: 'QRIS Manual',
                  subtitle: 'Konfirmasi setelah pelanggan membayar',
                  onTap: () => Navigator.pop(context, 'QRIS'),
                ),
                const SizedBox(height: 10),
                PaymentButton(
                  icon: Icons.account_balance_rounded,
                  title: 'Transfer',
                  subtitle: 'Pembayaran transfer manual',
                  onTap: () => Navigator.pop(context, 'Transfer'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (method == null) return;

    if (method == 'Tunai') {
      await cashDialog();
    } else {
      await confirmPayment(method);
    }
  }

  Future<void> cashDialog() async {
    final controller = TextEditingController(
      text: cartTotal.toString(),
    );

    final paid = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pembayaran Tunai'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total ${rupiah(cartTotal)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Uang diterima',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(
                  controller.text.replaceAll(RegExp(r'[^0-9]'), ''),
                );

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );

    if (paid == null) return;

    if (paid < cartTotal) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima masih kurang.'),
        ),
      );
      return;
    }

    final change = paid - cartTotal;

    completeTransaction('Tunai');

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            size: 54,
          ),
          title: const Text('Transaksi Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kembalian'),
              const SizedBox(height: 8),
              Text(
                rupiah(change),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmPayment(String method) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pembayaran $method'),
          content: Text(
            'Pastikan pembayaran ${rupiah(cartTotal)} sudah diterima.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Sudah Dibayar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      completeTransaction(method);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi $method berhasil.'),
        ),
      );
    }
  }

  void completeTransaction(String method) {
    final transactionTotal = cartTotal;
    final transactionItems = cartItems;

    for (final entry in cart.entries) {
      final product = productById(entry.key);
      product.stock -= entry.value;
    }

    setState(() {
      sales.insert(
        0,
        Sale(
          total: transactionTotal,
          items: transactionItems,
          payment: method,
          time: DateTime.now(),
        ),
      );

      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktopMode = width >= 760;

    final page = switch (pageIndex) {
      0 => buildCashier(),
      1 => buildProducts(),
      2 => buildReports(),
      _ => buildSettings(),
    };

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (desktopMode)
              NavigationRail(
                selectedIndex: pageIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
                leading: const Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.point_of_sale_rounded),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.point_of_sale_outlined),
                    selectedIcon: Icon(Icons.point_of_sale_rounded),
                    label: Text('Kasir'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2_rounded),
                    label: Text('Produk'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: Text('Laporan'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: Text('Pengaturan'),
                  ),
                ],
              ),
            if (desktopMode) const VerticalDivider(width: 1),
            Expanded(child: page),
          ],
        ),
      ),
      bottomNavigationBar: desktopMode
          ? null
          : NavigationBar(
              selectedIndex: pageIndex,
              onDestinationSelected: (index) {
                setState(() {
                  pageIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_rounded),
                  label: 'Kasir',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: 'Produk',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Laporan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Pengaturan',
                ),
              ],
            ),
    );
  }

  Widget buildCashier() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final splitView = constraints.maxWidth >= 850;

        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kasir',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const Text(
                          'Toko Saya • Siap transaksi',
                        ),
                      ],
                    ),
                  ),
                  Badge(
                    label: Text('$cartItems'),
                    child: IconButton.filledTonal(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) {
                                  return SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * .85,
                                    child: buildCartPanel(),
                                  );
                                },
                              );
                            },
                      icon: const Icon(Icons.shopping_cart_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: splitView
                    ? Row(
                        children: [
                          Expanded(
                            child: buildProductArea(),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 350,
                            child: buildCartPanel(),
                          ),
                        ],
                      )
                    : buildProductArea(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildProductArea() {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];

              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int columns = 2;

              if (constraints.maxWidth >= 1000) {
                columns = 4;
              } else if (constraints.maxWidth >= 650) {
                columns = 3;
              }

              final data = filteredProducts;

              return GridView.builder(
                itemCount: data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final product = data[index];
                  final quantity = cart[product.id] ?? 0;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => addToCart(product),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Icon(product.icon),
                                ),
                                const Spacer(),
                                if (quantity > 0)
                                  Badge(
                                    label: Text('$quantity'),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              rupiah(product.price),
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Stok ${product.stock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: product.stock <= 5
                                    ? Colors.red
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCartPanel() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (cart.isNotEmpty)
                  TextButton(
                    onPressed: clearCart,
                    child: const Text('Kosongkan'),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: cart.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 54,
                            color: Colors.black26,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada produk',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: cart.entries.map((entry) {
                        final product = productById(entry.key);
                        final quantity = entry.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      rupiah(product.price * quantity),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => decreaseCart(product),
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                ),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              IconButton(
                                onPressed: () => addToCart(product),
                                icon: const Icon(
                                  Icons.add_circle_rounded,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const Divider(),
            Row(
              children: [
                const Text('Item'),
                const Spacer(),
                Text('$cartItems'),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  rupiah(cartTotal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: cart.isEmpty ? null : paymentDialog,
                icon: const Icon(Icons.payments_rounded),
                label: const Text(
                  'BAYAR',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProducts() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk & Stok',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(product.icon),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(product.category),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rupiah(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text('Stok ${product.stock}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReports() {
    final omzet = sales.fold<int>(
      0,
      (sum, sale) => sum + sale.total,
    );

    final items = sales.fold<int>(
      0,
      (sum, sale) => sum + sale.items,
    );

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatCard(
                title: 'Omzet',
                value: rupiah(omzet),
                icon: Icons.payments_rounded,
              ),
              StatCard(
                title: 'Transaksi',
                value: '${sales.length}',
                icon: Icons.receipt_long_rounded,
              ),
              StatCard(
                title: 'Produk Terjual',
                value: '$items',
                icon: Icons.shopping_bag_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Card(
              child: sales.isEmpty
                  ? const Center(
                      child: Text('Belum ada transaksi.'),
                    )
                  : ListView.separated(
                      itemCount: sales.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final sale = sales[index];

                        final hh =
                            sale.time.hour.toString().padLeft(2, '0');
                        final mm =
                            sale.time.minute.toString().padLeft(2, '0');

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt_rounded),
                          ),
                          title: Text(
                            rupiah(sale.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            '${sale.items} item • ${sale.payment}',
                          ),
                          trailing: Text('$hh:$mm'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.store_rounded),
                  title: Text('Nama Toko'),
                  subtitle: Text('Toko Saya'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.print_rounded),
                  title: Text('Printer Bluetooth'),
                  subtitle: Text('Belum terhubung'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.qr_code_rounded),
                  title: Text('QRIS'),
                  subtitle: Text('Mode manual'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_sync_rounded),
                  title: Text('Sinkronisasi Cloud'),
                  subtitle: Text('Akan ditambahkan'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      leading: CircleAvatar(
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 120,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
