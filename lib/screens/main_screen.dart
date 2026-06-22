// lib/screens/main_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modules/wallet.dart';
import '../modules/shop.dart';
import '../modules/hunter_offline.dart';
import '../modules/hunter_wallet.dart';
import '../modules/miner_pro.dart';
import '../modules/miner_lite.dart';
import '../modules/sonar_flash.dart';
import '../services/wallet_service.dart';

const String _backgroundImageAsset = 'assets/background_image.webp';

/// مدل داده تمیز و قابل توسعه
class _Feature {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final bool premium;
  final String route;
  final String? subtitle;
  final String? statLabel;
  final String? statValue;
  final String? badgeText;
  final bool isWallet; // برای تشخیص کارت مستر ولت

  const _Feature({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.route,
    this.premium = false,
    this.subtitle,
    this.statLabel,
    this.statValue,
    this.badgeText,
    this.isWallet = false,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  final Uri _telegramUri = Uri.parse('https://t.me/im_abi_oo');
  final bool _isDark = true;

  late final List<_Feature> _features;

  @override
  void initState() {
    super.initState();
    _walletService.fetchPrices();

    _features = const [
      _Feature(
        title: 'Cloud Mining',
        icon: Icons.cloud_queue_rounded,
        gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        route: 'Cloud Maining',
        subtitle: 'Passive Income',
        statLabel: 'Hashrate',
        statValue: '248 MH/s',
      ),
      _Feature(
        title: 'Hunter Wallet',
        icon: Icons.shield_rounded,
        gradient: [Color(0xFF43e97b), Color(0xFF38f9d7)],
        route: 'Hunter Wallet',
        subtitle: 'Multi-chain',
        statLabel: 'Chains',
        statValue: '12 Active',
      ),
      _Feature(
        title: 'Scanner',
        icon: Icons.radar_rounded,
        gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
        premium: true,
        route: 'Scanner Wallet',
        subtitle: 'AI Detection',
        statLabel: 'Scanned',
        statValue: '1,847',
        badgeText: 'AI',
      ),
      _Feature(
        title: 'Miner Lite',
        icon: Icons.memory_rounded,
        gradient: [Color(0xFF30cfd0), Color(0xFF330867)],
        route: 'Miner Lite',
        subtitle: 'Low-power',
        statLabel: 'Efficiency',
        statValue: '94%',
      ),
      _Feature(
        title: 'Flash Coin',
        icon: Icons.bolt_rounded,
        gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
        premium: true,
        route: 'Flash Coin',
        subtitle: 'Instant Swap',
        statLabel: 'Volume',
        statValue: '\$2.4M',
      ),
      _Feature(
        title: 'Store',
        icon: Icons.storefront_rounded,
        gradient: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
        premium: true,
        route: 'Store',
        subtitle: 'Exclusive Items',
        statLabel: 'Items',
        statValue: '38 New',
      ),
      _Feature(
        title: 'Contact',
        icon: Icons.send_rounded,
        gradient: [Color(0xFF5ee7df), Color(0xFFb490ca)],
        route: 'Get Premium Access',
        subtitle: 'Premium Support',
        statLabel: 'Response',
        statValue: '< 5 min',
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(_backgroundImageAsset), context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openTelegram() async {
    try {
      await launchUrl(_telegramUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _navigateToPage(BuildContext context, String title) {
    if (title == 'Get Premium Access') {
      _openTelegram();
      return;
    }

    Widget page;
    switch (title) {
      case 'Master Wallet':
        page = const WalletEliteScreen();
        break;
      case 'Cloud Maining':
        page = const MinerProScreen();
        break;
      case 'Hunter Wallet':
        page = const HunterWalletScreen();
        break;
      case 'Scanner Wallet':
        page = const HunterOfflineScreen();
        break;
      case 'Miner Lite':
        page = const MinerLiteScreen();
        break;
      case 'Flash Coin':
        page = const SonarFlashScreen();
        break;
      case 'Store':
        page = const ShopScreen();
        break;
      default:
        page = Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text('Page not found: $title')),
        );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// چیدمان ریسپانسیو هوشمند بر اساس عرض واقعی
  int _gridColumns(double width) {
    if (width < 420) return 1;
    if (width < 680) return 2;
    if (width < 980) return 3;
    if (width < 1280) return 4;
    return 5;
  }

  Color get _bgColor => _isDark ? const Color(0xFF070912) : const Color(0xFFF5FAFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // پس‌زمینه تصویری
          Positioned.fill(
            child: Image.asset(
              _backgroundImageAsset,
              fit: BoxFit.cover,
              cacheWidth: 1400,
              errorBuilder: (_, __, ___) => Container(color: _bgColor),
            ),
          ),
          // لایه گرادیانت روی تصویر
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _isDark
                      ? [
                          const Color(0xE6070912),
                          const Color(0xC8070912),
                          const Color(0xFF070912),
                        ]
                      : [
                          const Color(0xE6F5FAFF),
                          const Color(0xC8F5FAFF),
                          const Color(0xFFF5FAFF),
                        ],
                ),
              ),
            ),
          ),
          // افکت نوری بالای راست
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF667eea).withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // افکت نوری پایین چپ
          Positioned(
            bottom: -200,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFf093fb).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sora Elite',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              actions: const [
                _BalanceChip(),
                SizedBox(width: 12),
                _NotificationBell(),
                SizedBox(width: 16),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  final columns = _gridColumns(maxW);
                  final isCompact = maxW < 500;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: maxW > 1000 ? 40 : (maxW > 600 ? 24 : 16),
                          vertical: 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _HeaderSection(isCompact: isCompact),
                            const SizedBox(height: 20),

                            // 🎯 Hero Card - با لیستنبل بیلدر برای آپدیت زنده
                            ListenableBuilder(
                              listenable: _walletService,
                              builder: (context, _) {
                                final heroFeature = _Feature(
                                  title: 'Master Wallet',
                                  icon: Icons.account_balance_wallet_rounded,
                                  gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                                  premium: true,
                                  route: 'Master Wallet',
                                  subtitle: 'Your Primary Vault',
                                  statLabel: 'Total Balance',
                                  statValue: '\$${_walletService.formattedBalance}',
                                  isWallet: true,
                                );
                                return _HeroTile(
                                  feature: heroFeature,
                                  isCompact: isCompact,
                                  onTap: () => _navigateToPage(context, 'Master Wallet'),
                                );
                              },
                            ),
                            const SizedBox(height: 28),

                            // عنوان بخش
                            _SectionHeader(title: 'Explore Features', icon: Icons.grid_view_rounded),
                            const SizedBox(height: 16),

                            // گرید کارت‌ها
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: columns == 1
                                    ? 2.2
                                    : (maxW < 500 ? 0.85 : 0.92),
                              ),
                              itemCount: _features.length,
                              itemBuilder: (context, i) => _FeatureTile(
                                feature: _features[i],
                                onTap: () => _navigateToPage(context, _features[i].route),
                              ),
                            ),

                            const SizedBox(height: 36),
                            const _FooterSection(),
                            const SizedBox(height: 20),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// اعلان‌ها
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 18),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFf5576c),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFf5576c).withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// چیپ balance - با لیستنبل بیلدر
class _BalanceChip extends StatelessWidget {
  const _BalanceChip();

  @override
  Widget build(BuildContext context) {
    final walletService = WalletService();

    return ListenableBuilder(
      listenable: walletService,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFffd97d), Color(0xFFff9a56)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.wallet, color: Color(0xFF1a1a2e), size: 13),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '\$${walletService.formattedBalance}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// بخش هدر با greeting و stats
class _HeaderSection extends StatelessWidget {
  final bool isCompact;
  const _HeaderSection({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting 👋',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Welcome back',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // آمار سریع - ریسپانسیو
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final count = w < 500 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: count,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: const [
                _StatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Profit',
                  value: '+24.5%',
                  color: Color(0xFF43e97b),
                ),
                _StatCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'Transactions',
                  value: '1,284',
                  color: Color(0xFF4facfe),
                ),
                _StatCard(
                  icon: Icons.monetization_on_rounded,
                  label: 'Active Coins',
                  value: '18',
                  color: Color(0xFFf093fb),
                ),
                _StatCard(
                  icon: Icons.verified_user_rounded,
                  label: 'Security',
                  value: 'Active',
                  color: Color(0xFFffd97d),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// کارت آماری کوچک
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان بخش
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Text(
          'See all',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 16),
      ],
    );
  }
}

/// 🎯 Hero Tile - کارت بزرگ و جذاب Master Wallet
class _HeroTile extends StatefulWidget {
  final _Feature feature;
  final bool isCompact;
  final VoidCallback onTap;

  const _HeroTile({
    required this.feature,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_HeroTile> createState() => _HeroTileState();
}

class _HeroTileState extends State<_HeroTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    final compact = widget.isCompact;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: _hover
              ? (Matrix4.identity()..translate(0.0, -4.0)..scale(1.01))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: f.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: f.gradient.last.withValues(alpha: _hover ? 0.55 : 0.4),
                blurRadius: _hover ? 40 : 30,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: f.gradient.first.withValues(alpha: 0.35),
                blurRadius: 80,
                offset: const Offset(0, 24),
                spreadRadius: -15,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // افکت نوری داخل کارت
                Positioned(
                  right: -60,
                  top: -60,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -80,
                  bottom: -80,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // الگوی پس‌زمینه
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.06,
                    child: CustomPaint(
                      painter: _GridPatternPainter(),
                    ),
                  ),
                ),

                // محتوای اصلی
                Padding(
                  padding: EdgeInsets.all(compact ? 22 : 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ردیف بالا - Badge + آیکون
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium_rounded,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'PRIMARY VAULT',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: compact ? 16 : 24),

                      // ردیف میانی - آیکون بزرگ + عنوان
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: compact ? 60 : 72,
                            height: compact ? 60 : 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              f.icon,
                              color: Colors.white,
                              size: compact ? 32 : 38,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.title,
                                  style: GoogleFonts.inter(
                                    fontSize: compact ? 24 : 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  f.subtitle ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: compact ? 12 : 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: compact ? 16 : 24),

                      // ردیف پایین - Balance + CTA
                      Container(
                        padding: EdgeInsets.all(compact ? 14 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.statLabel ?? 'Balance',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // 🎯 اینجا موجودی به صورت زنده آپدیت می‌شود
                                  Text(
                                    f.statValue ?? '\$0.00',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: compact ? 18 : 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Open',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF667eea),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF667eea),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// نقاش الگوی شبکه‌ای برای پس‌زمینه کارت
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🎯 Feature Tile - کارت جذاب و حرفه‌ای
class _FeatureTile extends StatefulWidget {
  final _Feature feature;
  final VoidCallback onTap;

  const _FeatureTile({required this.feature, required this.onTap});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          transform: _hover
              ? (Matrix4.identity()..translate(0.0, -6.0)..scale(1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.35 : 0.25),
                blurRadius: _hover ? 32 : 20,
                offset: Offset(0, _hover ? 16 : 10),
              ),
              BoxShadow(
                color: f.gradient.last.withValues(alpha: _hover ? 0.35 : 0.15),
                blurRadius: _hover ? 40 : 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _hover
                        ? [
                            Colors.white.withValues(alpha: 0.14),
                            Colors.white.withValues(alpha: 0.06),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _hover
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  children: [
                    // افکت نوری داخل کارت
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              f.gradient.first.withValues(
                                  alpha: _hover ? 0.35 : 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Badge PREMIUM
                    if (f.premium)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFffd97d),
                                Color(0xFFff9a56),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFffd97d).withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 10, color: Color(0xFF1a1a2e)),
                              const SizedBox(width: 2),
                              Text(
                                'PRO',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF1a1a2e),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // محتوای اصلی کارت
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // آیکون برجسته
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: f.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: f.gradient.last.withValues(
                                      alpha: _hover ? 0.6 : 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              f.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // عنوان و subtitle
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (f.subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    f.subtitle!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Mini Stat
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: f.gradient.first,
                                  size: 7,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  f.statLabel ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  f.statValue ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // فلش گوشه پایین راست
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _hover ? 1.0 : 0.3,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: f.gradient,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: f.gradient.last.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بخش فوتر
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // لوگو بزرگ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.diamond_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Sora Elite',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Made with 💜 by im_abi • powered by Saino™',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterChip(label: 'v2.0.0', icon: Icons.code_rounded),
              const SizedBox(width: 8),
              _FooterChip(label: 'Secure', icon: Icons.shield_rounded,
                  color: const Color(0xFF43e97b)),
              const SizedBox(width: 8),
              _FooterChip(label: '24/7', icon: Icons.access_time_rounded,
                  color: const Color(0xFF4facfe)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _FooterChip({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.white60),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}