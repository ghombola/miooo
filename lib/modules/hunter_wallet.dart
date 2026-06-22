// lib/modules/hunter_wallet_unified_v8.dart
// Unified Code: Hunter Wallet Scanner (main) + Wallet Page (view)
// Version: v8.4 (Modern UI/UX Overhaul)
// Language: English UI/Strings (Professional)
// Fixes: 1. Enabled USE_TARGETED_HITS = true.
//        2. Implemented the user's simulation logic: $100 capacity in 18s, 4 hits, 2s min interval.
//        3. General random balance simulation is DISABLED to respect the $100 cap.
//        4. Modern UI with Iconsax, Glassmorphism, and Responsive Layouts.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:iconsax/iconsax.dart'; // Modern Icon Package
import 'package:flutter/foundation.dart';

// ====================================================================
// ۱. تنظیمات و پارامترهای عددی (Constants) - اصلاح منطق شبیه‌سازی
// ====================================================================

class WalletConfig {
  // --- Targeted Search Mode Settings (Hardcoded Constants V8) ---
  static const bool USE_TARGETED_HITS = true; 
  
  // *** USER DEFINED LOGIC ***
  static const double SIM_TARGET_BALANCE = 0.0; // Max capacity
  static const int SIM_TARGET_HITS = 0;          // Number of packages
  static const int SIM_TARGET_TIME_SEC = 0;     // Total time to complete discovery
  static const int SIM_MIN_INTERVAL_SEC = 0;     // Minimum interval between two consecutive packages
  
  // --- UI LABELS (Professional English) ---
  static const String SIM_TARGETED_MODE_LABEL = 'Controlled Scan Mode';
  static const String GENERAL_SCAN_MODE_LABEL = 'Smart Hunt';
  static const String TG_DEVELOPER_ID = '@im_abi_oo'; 
  static const String APP_VERSION = 'V8.4';

  // --- Theme Colors (Modern Dark Neon Palette) ---
  static const Color BG_COLOR = Color(0xFF07090F);        
  static const Color SURFACE_COLOR = Color(0xFF11141C);   
  static const Color SOFT_COLOR = Color(0xFF1A1E2B);      
  static const Color ACCENT_A = Color(0xFF00E5FF);        // Cyan
  static const Color ACCENT_B = Color(0xFF7C3AED);        // Purple
  static const Color ACCENT_C = Color(0xFF10B981);        // Emerald
  static const Color ACCENT_D = Color(0xFFF59E0B);        // Amber (Found)
  static const Color MUTED_COLOR = Color(0xFF8B93A7);     
  static const Color NEON_COLOR = Color(0xFFF8FAFC);      
  static const Color ALERT_COLOR = Color(0xFFEF4444);     
}

// ====================================================================
// ۲. مدل‌های داده و Backend مشترک (Unchanged)
// ====================================================================

class AssetModel {
  final String name;
  final String symbol;
  final String iconPath;
  double balance;
  AssetModel({required this.name, required this.symbol, required this.iconPath, this.balance = 0.0});
}

class SeedLog {
  final DateTime time;
  final String mnemonic;
  final Map<String, double> perAssetBalance;
  SeedLog({
    required this.time,
    required this.mnemonic,
    required this.perAssetBalance,
  });

  bool get hasBalance => perAssetBalance.values.any((v) => v > 0);
}

class WalletBackend {
  static List<AssetModel>? _assetsRef;
  static VoidCallback? _onChange;
  static void register(List<AssetModel> assets, VoidCallback onChange) {
    _assetsRef = assets;
    _onChange = onChange;
  }

  static void unregister() {
    _assetsRef = null;
    _onChange = null;
  }
  static void setBalance(String symbol, double value, {bool refreshUI = true}) {
    if (_assetsRef == null) return;
    try {
      final a = _assetsRef!.firstWhere((x) => x.symbol == symbol);
      a.balance = value; 
      if (refreshUI) _onChange?.call();
    } catch (_) {}
  }
}

// ====================================================================
// ۳. رابط کاربری (Wallet Page) - Modern Glassmorphism Design
// ====================================================================

class WalletPage extends StatelessWidget {
  final List<AssetModel> assets;
  final Map<String, double> priceUsd;
  final Future<void> Function(AssetModel) onWithdraw;
  
  const WalletPage({
    super.key, 
    required this.assets, 
    required this.priceUsd, 
    required this.onWithdraw,
  });

  void _showProLicenseMessage(BuildContext context) {
    final url = 'https://t.me/${WalletConfig.TG_DEVELOPER_ID}';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WalletConfig.SURFACE_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: WalletConfig.ACCENT_B.withValues(alpha: 0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(Iconsax.lock_1, color: WalletConfig.ACCENT_D),
              const SizedBox(width: 10),
              Text('Feature Locked', style: TextStyle(color: WalletConfig.NEON_COLOR, fontWeight: FontWeight.w800)),
            ]
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Access restricted. Contact the Telegram support ID to unlock the complete version.', 
                style: TextStyle(color: WalletConfig.MUTED_COLOR, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WalletConfig.BG_COLOR,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05))
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.user, color: WalletConfig.ACCENT_A, size: 18),
                    SizedBox(width: 8),
                    Text(
                      WalletConfig.TG_DEVELOPER_ID, 
                      style: TextStyle(color: WalletConfig.ACCENT_A, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                    ),
                  ]
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.send_2, color: WalletConfig.ACCENT_C, size: 18),
                  const SizedBox(width: 8),
                  const Text('Contact Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), 
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Dismiss', style: TextStyle(color: WalletConfig.MUTED_COLOR)), 
            ),
          ],
        );
      },
    );
  }

  double get _totalBalance {
    return assets.fold(0.0, (sum, asset) => sum + asset.balance);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final crossCount = isMobile ? 1 : (size.width < 1000 ? 2 : 3);
    
    return Scaffold(
      backgroundColor: WalletConfig.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: WalletConfig.NEON_COLOR),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hunter Wallet', style: TextStyle(color: WalletConfig.NEON_COLOR, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          children: [
            // Total Balance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [WalletConfig.ACCENT_B.withValues(alpha: 0.2), WalletConfig.ACCENT_A.withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: WalletConfig.ACCENT_B.withValues(alpha: 0.1), blurRadius: 30, offset: Offset(0, 15))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.wallet_2, color: WalletConfig.ACCENT_A),
                      SizedBox(width: 8),
                      Text('Total Balance', style: TextStyle(color: WalletConfig.MUTED_COLOR, fontSize: 14, fontWeight: FontWeight.w600))
                    ]
                  ),
                  SizedBox(height: 12),
                  Text(
                    '\$${_totalBalance.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: WalletConfig.NEON_COLOR,
                      fontSize: isMobile ? 32 : 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1
                    )
                  ),
                  SizedBox(height: 8),
                  Text('Across ${assets.length} Networks', style: TextStyle(color: WalletConfig.MUTED_COLOR, fontSize: 12))
                ]
              )
            ),
            SizedBox(height: 24),
            Expanded(
              child: ScrollConfiguration(
                behavior: const _SmoothScrollBehavior(),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: assets.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 1.6 : 1.8,
                  ),
                  itemBuilder: (ctx, i) {
                    final a = assets[i];
                    final price = priceUsd[a.symbol];
                    final usd = (price == null) ? null : price * a.balance;
                    return _WalletCard(
                      asset: a,
                      usd: usd,
                      onShowCustomMessage: () => _showProLicenseMessage(context),
                      isMobile: isMobile,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatefulWidget {
  final AssetModel asset;
  final double? usd;
  final VoidCallback onShowCustomMessage; 
  final bool isMobile;
  const _WalletCard({
    required this.asset,
    required this.usd,
    required this.onShowCustomMessage, 
    required this.isMobile,
  });
  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _hover = false;
  
  @override
  Widget build(BuildContext context) {
    final a = widget.asset;
    final usd = widget.usd;
    final scale = widget.isMobile ? 1.0 : (_hover ? 1.02 : 1.0);
    final hasBalance = a.balance > 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: WalletConfig.SURFACE_COLOR,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hover ? WalletConfig.ACCENT_A.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _svgOrFallback(a.iconPath, a.symbol),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.symbol, style: TextStyle(color: WalletConfig.NEON_COLOR, fontWeight: FontWeight.w800, fontSize: 18)),
                        Text(a.name, style: TextStyle(color: WalletConfig.MUTED_COLOR, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (usd != null)
                    Text('\$${usd.toStringAsFixed(2)}', style: TextStyle(color: WalletConfig.ACCENT_C, fontWeight: FontWeight.w700, fontSize: 15)),
                ]
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: WalletConfig.BG_COLOR,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.coin, size: 16, color: WalletConfig.ACCENT_A),
                    SizedBox(width: 6),
                    Text(
                      '${a.balance.toStringAsFixed(6)} ${a.symbol}',
                      style: TextStyle(color: WalletConfig.NEON_COLOR, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ]
                )
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onShowCustomMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasBalance ? WalletConfig.ACCENT_A : WalletConfig.SOFT_COLOR,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Withdraw',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: hasBalance ? Colors.black : WalletConfig.MUTED_COLOR,
                      fontSize: 14
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _svgOrFallback(String path, String symbol) {
    try {
      return SizedBox(width: 44, height: 44, child: SvgPicture.asset(path, fit: BoxFit.contain));
    } catch (_) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [WalletConfig.ACCENT_A.withValues(alpha: 0.2), WalletConfig.ACCENT_B.withValues(alpha: 0.2)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))
        ),
        child: Center(
          child: Text(
            symbol.substring(0, min(2, symbol.length)).toUpperCase(),
            style: TextStyle(color: WalletConfig.NEON_COLOR, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
          ),
        ),
      );
    }
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  const _SmoothScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return const BouncingScrollPhysics();
      default:
        return const ClampingScrollPhysics();
    }
  }
}

// ====================================================================
// ۴. صفحه اصلی اسکنر (HunterWalletScreen) - Modern Terminal UI
// ====================================================================

class HunterWalletScreen extends StatefulWidget {
  const HunterWalletScreen({super.key});
  @override
  State<HunterWalletScreen> createState() => _HunterWalletScreenState();
}

class _HunterWalletScreenState extends State<HunterWalletScreen> with TickerProviderStateMixin {
  // --- Constants (Color Abstraction for cleaner code) ---
  final Color bg = WalletConfig.BG_COLOR;
  final Color surface = WalletConfig.SURFACE_COLOR;
  final Color soft = WalletConfig.SOFT_COLOR;
  final Color accentA = WalletConfig.ACCENT_A;
  final Color accentB = WalletConfig.ACCENT_B;
  final Color accentC = WalletConfig.ACCENT_C;
  final Color accentD = WalletConfig.ACCENT_D; 
  final Color muted = WalletConfig.MUTED_COLOR; 
  final Color neon = WalletConfig.NEON_COLOR;
  
  // ... (State variables)
  late final List<AssetModel> assets;
  late final List<String> _assetSymbols; 

  // --- Buffers ---
  final List<SeedLog> _seedLogs = []; 
  final List<SeedLog> _foundLogs = []; 
  final List<SeedLog> _pending = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _listNotifier = ValueNotifier<int>(0);

  // --- Engine & Counters ---
  Timer? _engineTimer;
  bool _running = false;
  final Random _rnd = Random();
  bool _autoScrollEnabled = true;

  int _totalGenerated = 0;
  int _totalChecked = 0;
  int _totalFound = 0;
  double _highestFound = 0.0;
  final ValueNotifier<double> displayGenerated = ValueNotifier<double>(0.0);
  final ValueNotifier<double> displayChecked = ValueNotifier<double>(0.0);
  final ValueNotifier<double> displayFound = ValueNotifier<double>(0.0);
  final ValueNotifier<double> displayHighest = ValueNotifier<double>(0.0);
  Timer? _displayTimer;
  late final Ticker _ticker;
  Duration _uptime = Duration.zero;
  DateTime? _startTime;

  // --- Targeted Hit System State (FIX APPLIED) ---
  List<({Duration offset, double balance, String assetSymbol})> _simulatedHits = [];
  Duration _lastTargetedHitTime = Duration.zero;
  double _totalBalanceClaimed = 0.0; 

  // --- Settings ---
  bool _use12 = true;
  String _speedLabel = 'NORMAL';
  int _scanCps = 300;
  final Map<String, int> _speedMap = {'SLOW': 80, 'NORMAL': 300, 'FAST': 1200};
  int _maxLogs = 10000;
  Duration _pruneAfter = const Duration(seconds: 1000);
  int _pruneKeepPercent = 10;
  final int _flushLimit = 100;
  bool _inListOp = false;

  @override
  void initState() {
    super.initState();
    assets = [
      AssetModel(name: 'Bitcoin', symbol: 'BTC', iconPath: 'assets/icons/btc.svg'),
      AssetModel(name: 'Ethereum', symbol: 'ETH', iconPath: 'assets/icons/eth.svg'),
      AssetModel(name: 'Tether', symbol: 'USDT', iconPath: 'assets/icons/usdt.svg'),
      AssetModel(name: 'USD Coin', symbol: 'USDC', iconPath: 'assets/icons/usdc.svg'),
      AssetModel(name: 'BNB', symbol: 'BNB', iconPath: 'assets/icons/bnb.svg'),
      AssetModel(name: 'Cardano', symbol: 'ADA', iconPath: 'assets/icons/ada.svg'),
      AssetModel(name: 'Solana', symbol: 'SOL', iconPath: 'assets/icons/sol.svg'),
      AssetModel(name: 'XRP', symbol: 'XRP', iconPath: 'assets/icons/xrp.svg'),
      AssetModel(name: 'Dogecoin', symbol: 'DOGE', iconPath: 'assets/icons/doge.svg'),
      AssetModel(name: 'Polkadot', symbol: 'DOT', iconPath: 'assets/icons/dot.svg'),
      AssetModel(name: 'Litecoin', symbol: 'LTC', iconPath: 'assets/icons/ltc.svg'),
      AssetModel(name: 'Chainlink', symbol: 'LINK', iconPath: 'assets/icons/link.svg'),
      AssetModel(name: 'Tron', symbol: 'TRX', iconPath: 'assets/icons/trx.svg'),
      AssetModel(name: 'Uniswap', symbol: 'UNI', iconPath: 'assets/icons/uni.svg'),
      AssetModel(name: 'Avalanche', symbol: 'AVAX', iconPath: 'assets/icons/avax.svg'),
      AssetModel(name: 'Stellar', symbol: 'XLM', iconPath: 'assets/icons/xlm.svg'),
      AssetModel(name: 'Dai', symbol: 'DAI', iconPath: 'assets/icons/dai.svg'),
      AssetModel(name: 'SushiSwap', symbol: 'SUSHI', iconPath: 'assets/icons/sushi.svg'),
      AssetModel(name: 'Aave', symbol: 'AAVE', iconPath: 'assets/icons/aave.svg'),
      AssetModel(name: 'TON', symbol: 'TON', iconPath: 'assets/icons/ton.svg'),
      AssetModel(name: 'Monero', symbol: 'XMR', iconPath: 'assets/icons/xmr.svg'),
      AssetModel(name: 'EOS', symbol: 'EOS', iconPath: 'assets/icons/eos.svg'),
      AssetModel(name: 'Dash', symbol: 'DASH', iconPath: 'assets/icons/dash.svg'),
      AssetModel(name: 'The Sandbox', symbol: 'SAND', iconPath: 'assets/icons/sand.svg'),
      AssetModel(name: 'Harmony', symbol: 'ONE', iconPath: 'assets/icons/one.svg'),
      AssetModel(name: 'Polygon', symbol: 'MATIC', iconPath: 'assets/icons/matic.svg'),
      AssetModel(name: 'Cosmos', symbol: 'ATOM', iconPath: 'assets/icons/atom.svg'),
    ];
    _assetSymbols = assets.map((a) => a.symbol).toList();
    
    WalletBackend.register(assets, () { if (mounted) setState(() {}); });
    
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final cur = _scrollController.position.pixels;
      final nearBottom = (max - cur) <= 120.0;
      if (nearBottom && !_autoScrollEnabled) {
        if (mounted) setState(() => _autoScrollEnabled = true);
      }
    });

    _displayTimer = Timer.periodic(const Duration(milliseconds: 60), (_) => _updateDisplays());

    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() {
        _uptime = elapsed;
        _checkTargetedHit(); 
      });
    });
    
    _setupDeterministicSimulation();
  }

  @override
  void dispose() {
    _engineTimer?.cancel();
    _displayTimer?.cancel();
    _ticker.dispose();
    _scrollController.dispose();
    displayGenerated.dispose();
    displayChecked.dispose();
    displayFound.dispose();
    displayHighest.dispose();
    WalletBackend.unregister();
    super.dispose();
  }
  
  // ---------------- Targeted Hit System Setup (FIX V8 APPLIED) ----------------
  void _setupDeterministicSimulation() {
    final N = WalletConfig.SIM_TARGET_HITS;
    final B = WalletConfig.SIM_TARGET_BALANCE;
    final T = WalletConfig.SIM_TARGET_TIME_SEC;
    final MinInterval = WalletConfig.SIM_MIN_INTERVAL_SEC;

    _simulatedHits = [];
    _lastTargetedHitTime = Duration.zero;

    if (!WalletConfig.USE_TARGETED_HITS || B == 0 || N <= 0 || T < (N * MinInterval)) {
      return; 
    }
    
    final averageBalance = B / N;
    final totalIntervals = T - (N * MinInterval);
    final intervalChunk = totalIntervals / N;

    double remainingBalance = B;
    Duration currentOffset = Duration.zero;
    
    List<Duration> hitOffsets = [];
    for (int i = 0; i < N; i++) {
        final maxRndTime = intervalChunk.round() - 1;
        final rndTime = (maxRndTime <= 0) ? 0 : _rnd.nextInt(maxRndTime + 1);
        final nextOffset = Duration(seconds: MinInterval + rndTime);
        currentOffset += nextOffset;
        hitOffsets.add(currentOffset);
    }
    
    final totalTime = hitOffsets.last.inSeconds;
    final timeDifference = T - totalTime;
    
    hitOffsets = hitOffsets.map((offset) {
        final fraction = offset.inSeconds / totalTime;
        final adjustment = (timeDifference * fraction).round();
        return Duration(seconds: offset.inSeconds + adjustment);
    }).toList();

    List<double> hitBalances = [];
    double currentSum = 0;
    for (int i = 0; i < N; i++) {
        double balance = averageBalance;
        if (i < N - 1) {
            final maxJitter = averageBalance * 0.2;
            final jitter = (_rnd.nextDouble() * maxJitter * 2) - maxJitter;
            balance += jitter;
            balance = balance.clamp(1.0, B); 
        }
        hitBalances.add(balance);
        currentSum += balance;
    }

    if (currentSum != B) {
        final lastIndex = N - 1;
        final difference = B - currentSum;
        hitBalances[lastIndex] = (hitBalances[lastIndex] + difference).clamp(1.0, B); 
    }
    
    for (int i = 0; i < N; i++) {
        _simulatedHits.add((
            offset: hitOffsets[i], 
            balance: double.parse(hitBalances[i].toStringAsFixed(4)), 
            assetSymbol: _assetSymbols[_rnd.nextInt(_assetSymbols.length)]
        ));
    }

    _simulatedHits.sort((a, b) => a.offset.compareTo(b.offset));
    _lastTargetedHitTime = Duration.zero;
  }
  
  // ---------------- Hit Check (New Logic V8) ----------------
  void _checkTargetedHit() {
      if (!_running || !WalletConfig.USE_TARGETED_HITS || _simulatedHits.isEmpty) return;
      
      while (_simulatedHits.isNotEmpty && _uptime >= _simulatedHits.first.offset) {
          final nextHit = _simulatedHits.removeAt(0);
          _lastTargetedHitTime = _uptime;

          final mnemonic = bip39.generateMnemonic(strength: _use12 ? 128 : 256);
          final per = { for (var e in _assetSymbols) e : 0.0 };
          
          per[nextHit.assetSymbol] = nextHit.balance;

          final log = SeedLog(time: DateTime.now(), mnemonic: mnemonic, perAssetBalance: per);
          _pending.add(log);

          if (log.hasBalance) {
            _totalFound++;
            _foundLogs.add(log); 
            final v = _calcTotalValue(log.perAssetBalance);
            if (v > _highestFound) _highestFound = v;
          }
      }
  }

  // ---------------- Engine control (Unchanged) ----------------
  
  void _start() {
    if (_running) return;
    setState(() {
      _running = true;
      _totalGenerated = 0;
      _totalChecked = 0;
      _totalFound = 0;
      _highestFound = 0.0;
      _totalBalanceClaimed = 0.0;
      _startTime = DateTime.now();
      _foundLogs.clear(); 
      _setupDeterministicSimulation(); 
    });
    _ticker.stop();
    _ticker.start();
    _scheduleEngine();
  }

  void _stop() {
    if (!_running) return;
    _engineTimer?.cancel();
    _ticker.stop();
    setState(() => _running = false);
  }

  void _scheduleEngine() {
    _engineTimer?.cancel();
    const tickMs = 120;
    final cps = _scanCps.clamp(1, 5000);
    final batch = max(1, (cps * tickMs / 1000).round());
    _engineTimer = Timer.periodic(const Duration(milliseconds: tickMs), (_) async {
      if (!mounted) return;
      final now = DateTime.now();
      for (int i = 0; i < batch; i++) {
        if (!_running) break;
        _generateBip39(now);
      }
      await _flushPendingSafe();
      _pruneIfNeeded();
    });
  }

  void _generateBip39([DateTime? at]) {
    final time = at ?? DateTime.now();
    final strength = _use12 ? 128 : 256;
    final mnemonic = bip39.generateMnemonic(strength: strength);

    final per = { for (var e in _assetSymbols) e : 0.0 };
    
    final log = SeedLog(time: time, mnemonic: mnemonic, perAssetBalance: per);
    _pending.add(log);

    _totalGenerated++;
    _totalChecked++;
    
    if (log.hasBalance) {
    }
  }

  double _calcTotalValue(Map<String, double> per) {
    return per.values.fold(0.0, (sum, val) => sum + val);
  }

  void _transferToWallet(SeedLog log) {
    if (!mounted) return;
    
    for (final entry in log.perAssetBalance.entries) {
      if (entry.value > 0) {
        try {
          final asset = assets.firstWhere((a) => a.symbol == entry.key);
          WalletBackend.setBalance(entry.key, asset.balance + entry.value);
          _totalBalanceClaimed += entry.value;
        } catch (_) {}
      }
    }

    _foundLogs.remove(log);
    _showSnack('Discovery transferred to Wallet! (Total: \$${_totalBalanceClaimed.toStringAsFixed(2)})'); 
    setState(() {}); 
  }

  void _openWalletPage() {
    try {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WalletPage(assets: assets, priceUsd: const {}, onWithdraw: _handleWithdraw)));
    } catch (_) {}
  }
  
  void _openHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( 
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: min(500, MediaQuery.of(context).size.width * 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.clock, color: accentB),
                      SizedBox(width: 10),
                      Expanded(child: Text('Discovery History', style: TextStyle(color: neon, fontWeight: FontWeight.w800, fontSize: 18))), 
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: accentB.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('${_foundLogs.length} Hits', style: TextStyle(color: accentB, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(icon: Icon(Iconsax.close_circle, color: muted), onPressed: () => Navigator.pop(ctx))
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _foundLogs.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Column(
                        children: [
                          Icon(Iconsax.search_status, size: 48, color: muted.withValues(alpha: 0.3)),
                          SizedBox(height: 12),
                          Text('No discoveries yet...', style: TextStyle(color: muted))
                        ],
                      ))) 
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _foundLogs.length,
                            itemBuilder: (c, i) {
                              final log = _foundLogs[i];
                              final assetEntries = log.perAssetBalance.entries.where((e) => e.value > 0).toList();
                              final totalValue = assetEntries.fold<double>(0.0, (sum, e) => sum + e.value);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: accentD.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Iconsax.key, size: 16, color: accentD),
                                          SizedBox(width: 8),
                                          Text('SEED: ${log.mnemonic.substring(0, 12)}...', style: TextStyle(color: muted, fontSize: 12, fontFamily: 'monospace')),
                                          Spacer(),
                                          Text('${_two(log.time.hour)}:${_two(log.time.minute)}', style: TextStyle(color: muted, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '\$${totalValue.toStringAsFixed(4)}', 
                                        style: TextStyle(color: accentD, fontWeight: FontWeight.w800, fontSize: 20),
                                      ),
                                      const SizedBox(height: 12),
                                      ...assetEntries.map((e) => Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(8)),
                                        child: Text('${e.key}: ${e.value.toStringAsFixed(6)}', style: TextStyle(color: neon.withValues(alpha: 0.9), fontSize: 12, fontFamily: 'monospace')),
                                      )),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _transferToWallet(log);
                                            setDialogState(() {}); 
                                            if (mounted) setState(() {}); 
                                          },
                                          icon: Icon(Iconsax.export_1, color: Colors.black),
                                          label: const Text('Transfer to Wallet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
                                          style: ElevatedButton.styleFrom(backgroundColor: accentA, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isDesktop = width > 800;
    
    final currentMode = WalletConfig.USE_TARGETED_HITS && WalletConfig.SIM_TARGET_BALANCE > 0
        ? WalletConfig.SIM_TARGETED_MODE_LABEL
        : WalletConfig.GENERAL_SCAN_MODE_LABEL; 

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 16),
          child: Column(children: [
            // top bar
            Row(children: [
              IconButton(onPressed: () => Navigator.maybePop(context), icon: Icon(Iconsax.arrow_left_2, color: neon)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Network Scanner', style: TextStyle(color: neon, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text('${WalletConfig.APP_VERSION} • Turbo Engine', style: TextStyle(color: muted, fontSize: 12)), 
              ])),
              IconButton(onPressed: _showSupport, icon: Icon(Iconsax.headphone, color: accentA)),
            ]),
            const SizedBox(height: 16),
            
            // stats card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface, 
                borderRadius: BorderRadius.circular(24), 
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentA.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Icon(Iconsax.activity, color: accentA, size: 20)
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monitor Box', style: TextStyle(color: neon, fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(currentMode, style: TextStyle(color: muted, fontSize: 12))
                        ]
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentC.withValues(alpha: 0.3))
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.clock, size: 14, color: accentC),
                            SizedBox(width: 6),
                            Text(_formatDuration(_uptime), style: TextStyle(color: neon, fontWeight: FontWeight.w600, fontSize: 13))
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 600 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: crossCount,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 1.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildStatBox('Generated', displayGenerated, Iconsax.document, accentA),
                          _buildStatBox('Checked', displayChecked, Iconsax.search_status, accentB),
                          _buildStatBox('Found', displayFound, Iconsax.discover, accentC),
                          _buildStatBox('Highest', displayHighest, Iconsax.trend_up, accentD, isCurrency: true),
                        ]
                      );
                    }
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // log panel
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bg, 
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [
                      Icon(Iconsax.code_circle, color: accentA),
                      SizedBox(width: 8),
                      Text('Seed Interceptor', style: TextStyle(color: neon, fontWeight: FontWeight.w700, fontSize: 16)),
                      Spacer(),
                      if (!_autoScrollEnabled) 
                        InkWell(
                          onTap: () {setState(() => _autoScrollEnabled = true); _scrollToBottomDeferred();},
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: accentC.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [Icon(Iconsax.arrow_down_2, size: 14, color: accentC), SizedBox(width: 4), Text('Auto-Scroll', style: TextStyle(color: accentC, fontSize: 12))])
                          )
                        ),
                      SizedBox(width: 12),
                      InkWell(
                        onTap: _clearLogs,
                        child: Icon(Iconsax.trash, color: muted, size: 20)
                      )
                    ]),
                  ),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollStartNotification && n.dragDetails != null && _autoScrollEnabled) { setState(() => _autoScrollEnabled = false); }
                        else if (n is ScrollEndNotification && _scrollController.hasClients) { 
                          final max = _scrollController.position.maxScrollExtent;
                          final cur = _scrollController.position.pixels;
                          if ((max - cur) <= 120.0 && !_autoScrollEnabled) { setState(() => _autoScrollEnabled = true); }
                        }
                        return false;
                      },
                      child: ValueListenableBuilder<int>(
                        valueListenable: _listNotifier,
                        builder: (ctx, _, _) {
                          if (_seedLogs.isEmpty) { return Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.radar_2, size: 48, color: muted.withValues(alpha: 0.3)),
                              SizedBox(height: 12),
                              Text('Ready, Hunter? Let’s start.', style: TextStyle(color: muted))
                            ],
                          )); } 
                          return AnimatedList(
                            key: _listKey,
                            controller: _scrollController,
                            initialItemCount: _seedLogs.length,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            itemBuilder: (c, i, anim) {
                              final s = _seedLogs[i];
                              return SizeTransition(sizeFactor: anim, axis: Axis.vertical, child: _seedTile(s));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // bottom dock
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10))]
              ),
              child: Row(
                children: [
                  _dockButton(icon: Iconsax.wallet_2, label: 'Wallet', onTap: _openWalletPage, color: accentA),
                  SizedBox(width: 12),
                  _dockButton(icon: Iconsax.clock, label: 'History', onTap: _openHistoryDialog, color: accentB, badge: _foundLogs.length),
                  SizedBox(width: 12),
                  _dockButton(icon: Iconsax.setting_2, label: 'Settings', onTap: _openSettings, color: muted),
                  Spacer(),
                  _fabBig(onTap: () { if (_running) {
                    _stop();
                  } else {
                    _start();
                  } }, running: _running),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, ValueListenable<double> notifier, IconData icon, Color color, {bool isCurrency = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 6),
              Text(label, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
            ]
          ),
          SizedBox(height: 8),
          ValueListenableBuilder<double>(
            valueListenable: notifier,
            builder: (_, val, _) => Text(
              isCurrency ? '\$${val.toStringAsFixed(2)}' : val.toInt().toString(),
              style: TextStyle(color: neon, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)
            )
          )
        ]
      )
    );
  }

  Widget _seedTile(SeedLog s) {
    final isFound = s.hasBalance;
    final accent = isFound ? accentD : accentA;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isFound ? accent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05), width: isFound ? 1.5 : 1),
          boxShadow: isFound ? [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 15, offset: Offset(0, 5))] : null
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Iconsax.key, color: accent, size: 16)
                ),
                SizedBox(width: 10),
                Text('${_two(s.time.hour)}:${_two(s.time.minute)}:${_two(s.time.second)}', style: TextStyle(color: muted, fontSize: 12, fontFamily: 'monospace')),
                Spacer(),
                if (isFound)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: accentC.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('HIT', style: TextStyle(color: accentC, fontSize: 10, fontWeight: FontWeight.bold))
                  ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () { Clipboard.setData(ClipboardData(text: s.mnemonic)); _showSnack('SEED Copied'); },
                  child: Icon(Iconsax.copy, color: muted, size: 18)
                )
              ]
            ),
            SizedBox(height: 12),
            SelectableText(
              s.mnemonic,
              style: TextStyle(
                color: isFound ? neon : muted.withValues(alpha: 0.8),
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
                fontWeight: isFound ? FontWeight.w600 : FontWeight.w400
              )
            ),
            if (isFound) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Iconsax.dollar_circle, color: accentD, size: 18),
                    SizedBox(width: 8),
                    Text('Balance: \$${_calcTotalValue(s.perAssetBalance).toStringAsFixed(4)}', style: TextStyle(color: accentD, fontWeight: FontWeight.w700, fontSize: 14))
                  ]
                )
              )
            ]
          ]
        )
      )
    );
  }
  
  void _clearLogs() {
    for (int i = _seedLogs.length - 1; i >= 0; i--) {
      final removed = _seedLogs.removeAt(i);
      try {
        _listKey.currentState?.removeItem(i, (ctx, anim) => SizeTransition(sizeFactor: anim, child: _seedTile(removed)), duration: const Duration(milliseconds: 120));
      } catch (_) {}
    }
    _pending.clear();
    _foundLogs.clear(); 
    _listNotifier.value++;
    _showSnack('Scan logs cleared.'); 
  }

  Future<void> _handleWithdraw(AssetModel a) async {
    if (!mounted) return;
    final url = 'https://t.me/${WalletConfig.TG_DEVELOPER_ID}';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [Icon(Iconsax.danger, color: accentD), SizedBox(width: 10), Text('Pro License Required', style: TextStyle(color: neon, fontWeight: FontWeight.bold))]), 
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real-time withdrawal functionality is locked in this version. Please contact the developer via Telegram to acquire the Pro License:', style: TextStyle(color: muted, height: 1.5)), 
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Iconsax.user, color: accentA),
                SizedBox(width: 8),
                Text(WalletConfig.TG_DEVELOPER_ID, style: TextStyle(color: accentA, fontWeight: FontWeight.bold, fontSize: 16)),
              ])
            )
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            icon: Icon(Iconsax.send_2, color: Colors.black),
            label: const Text('Contact on Telegram', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
            style: ElevatedButton.styleFrom(backgroundColor: accentA, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Dismiss', style: TextStyle(color: muted))), 
        ],
      ),
    );
    _showSnack('${a.symbol} withdrawal pending Pro License.'); 
  }

  void _showSupport() {
    if (!mounted) return;
    final url = 'https://t.me/${WalletConfig.TG_DEVELOPER_ID}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        title: Row(children: [Icon(Iconsax.headphone, color: accentA), const SizedBox(width: 10), const Text('Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]), 
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('“Need help or want the full version? Contact our support on Telegram and get started!”', style: TextStyle(color: muted, height: 1.5)), 
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Iconsax.user, color: accentB),
              SizedBox(width: 8),
              Text(WalletConfig.TG_DEVELOPER_ID, style: TextStyle(color: accentB, fontWeight: FontWeight.bold, fontSize: 16)),
            ])
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                icon: Icon(Iconsax.send_2, color: Colors.black),
                label: const Text('Contact Us', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
                style: ElevatedButton.styleFrom(backgroundColor: accentA, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Dismiss', style: TextStyle(color: muted))), 
          ])
        ]),
      ),
    );
  }

  void _openSettings() {
    final maxCtrl = TextEditingController(text: _maxLogs.toString());
    final pruneCtrl = TextEditingController(text: _pruneAfter.inSeconds.toString());
    final keepCtrl = TextEditingController(text: _pruneKeepPercent.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: Text('Settings', style: TextStyle(color: neon, fontSize: 20, fontWeight: FontWeight.w800))), IconButton(icon: Icon(Iconsax.close_circle, color: muted), onPressed: () => Navigator.pop(ctx))]), 
                  const SizedBox(height: 24),
                  
                  const Text('Seed Length (Words)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), 
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ChoiceChip(
                      label: Center(child: const Text('12 Words')), 
                      selected: _use12, 
                      onSelected: (v) => setInnerState(() => _use12 = true), 
                      selectedColor: accentA.withValues(alpha: 0.2),
                      backgroundColor: bg,
                      labelStyle: TextStyle(color: _use12 ? accentA : muted, fontWeight: FontWeight.w600),
                      side: BorderSide(color: _use12 ? accentA : Colors.transparent),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )), 
                    const SizedBox(width: 12),
                    Expanded(child: ChoiceChip(
                      label: Center(child: const Text('24 Words')), 
                      selected: !_use12, 
                      onSelected: (v) => setInnerState(() => _use12 = false), 
                      selectedColor: accentA.withValues(alpha: 0.2),
                      backgroundColor: bg,
                      labelStyle: TextStyle(color: !_use12 ? accentA : muted, fontWeight: FontWeight.w600),
                      side: BorderSide(color: !_use12 ? accentA : Colors.transparent),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )), 
                  ]),
                  const SizedBox(height: 24),
                  const Text('Scan Speed (Keys/s)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), 
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, children: _speedMap.keys.map((k) {
                    final sel = _speedLabel == k;
                    return ChoiceChip(
                      label: Text('$k\n(${_speedMap[k]})', textAlign: TextAlign.center),
                      selected: sel,
                      onSelected: (v) {
                        if (v) {
                          setState(() { 
                          _speedLabel = k;
                          _scanCps = _speedMap[k]!;
                          if (_running) _scheduleEngine();
                        });
                        }
                      },
                      selectedColor: accentB.withValues(alpha: 0.2),
                      backgroundColor: bg,
                      labelStyle: TextStyle(color: sel ? accentB : muted, fontWeight: FontWeight.w600),
                      side: BorderSide(color: sel ? accentB : Colors.transparent),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  }).toList()),
                  const SizedBox(height: 28),
                  
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 20),
                  const Text('Maximum Logs', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), 
                  const SizedBox(height: 12),
                  TextField(controller: maxCtrl, keyboardType: TextInputType.number, style: TextStyle(color: neon, fontWeight: FontWeight.w600), decoration: InputDecoration(filled: true, fillColor: bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Prune After (sec)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), const SizedBox(height: 12), TextField(controller: pruneCtrl, keyboardType: TextInputType.number, style: TextStyle(color: neon, fontWeight: FontWeight.w600), decoration: InputDecoration(filled: true, fillColor: bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)))])), 
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Keep Percentage', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), const SizedBox(height: 12), TextField(controller: keepCtrl, keyboardType: TextInputType.number, style: TextStyle(color: neon, fontWeight: FontWeight.w600), decoration: InputDecoration(filled: true, fillColor: bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)))])), 
                  ]),
                  const SizedBox(height: 28),
                  
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _maxLogs = int.tryParse(maxCtrl.text.trim())?.clamp(200, 50000) ?? _maxLogs;
                            _pruneAfter = Duration(seconds: int.tryParse(pruneCtrl.text.trim())?.clamp(3, 3600) ?? _pruneAfter.inSeconds);
                            _pruneKeepPercent = int.tryParse(keepCtrl.text.trim())?.clamp(0, 50) ?? _pruneKeepPercent;
                          });
                          Navigator.pop(ctx);
                          _showSnack('Settings saved successfully.'); 
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: accentC, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Save & Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: muted, fontWeight: FontWeight.w600))), 
                  ]),
                  const SizedBox(height: 20),
                ]),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showSnack(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t, style: TextStyle(color: neon, fontWeight: FontWeight.w600)), 
      backgroundColor: surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(16),
    ));
  }
  
  void _updateDisplays() {
    double targetGenerated = _totalGenerated.toDouble();
    displayGenerated.value = (displayGenerated.value * 0.9) + (targetGenerated * 0.1);
    if ((targetGenerated - displayGenerated.value).abs() < 10) {
      displayGenerated.value = targetGenerated;
    }

    double targetChecked = _totalChecked.toDouble();
    displayChecked.value = (displayChecked.value * 0.9) + (targetChecked * 0.1);
    if ((targetChecked - displayChecked.value).abs() < 10) {
      displayChecked.value = targetChecked;
    }
    
    double targetFound = _totalFound.toDouble();
    displayFound.value = (displayFound.value * 0.95) + (targetFound * 0.05);
    if ((targetFound - displayFound.value).abs() < 1) {
      displayFound.value = targetFound;
    }

    double targetHighest = _highestFound;
    displayHighest.value = (displayHighest.value * 0.9) + (targetHighest * 0.1);
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatDuration(Duration d) {
    String two(int x) => x.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }
  
  Future<void> _flushPendingSafe() async {
    if (_inListOp) return;
    if (_pending.isEmpty) return;
    _inListOp = true;

    final to = min(_flushLimit, _pending.length);
    final batch = _pending.sublist(0, to);
    _pending.removeRange(0, to);

    for (int i = 0; i < batch.length; i++) {
      final s = batch[i];
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final idx = _seedLogs.length;
        _seedLogs.add(s);
        try {
          _listKey.currentState?.insertItem(idx, duration: const Duration(milliseconds: 260));
        } catch (_) {}
        _listNotifier.value++;
      });
      
      await Future.delayed(Duration(milliseconds: 10 + _rnd.nextInt(20))); 

      if (_autoScrollEnabled && _scrollController.hasClients) {
        _scrollToBottomDeferred();
      }
    }

    while (_seedLogs.length > _maxLogs) {
      final removed = _seedLogs.removeAt(0);
      try {
        _listKey.currentState?.removeItem(
          0,
          (ctx, anim) => SizeTransition(sizeFactor: anim, child: _seedTile(removed)),
          duration: const Duration(milliseconds: 160),
        );
      } catch (_) {}
      _listNotifier.value++;
      await Future.delayed(const Duration(milliseconds: 12));
    }

    _inListOp = false;
  }
  
  void _scrollToBottomDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_scrollController.hasClients) return;
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final max = _scrollController.position.maxScrollExtent;
        await _scrollController.animateTo(max.clamp(0.0, double.infinity), duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
      } catch (_) {}
    });
  }

  void _pruneIfNeeded() {
    if (_seedLogs.isEmpty) return;
    final now = DateTime.now();
    final old = <int>[];
    for (int i = 0; i < _seedLogs.length; i++) {
      if (now.difference(_seedLogs[i].time) >= _pruneAfter) old.add(i);
    }
    if (old.isEmpty) return;
    final keep = max(1, ((old.length * _pruneKeepPercent) / 100).round());
    final removeCount = max(0, old.length - keep);
    for (int i = 0; i < removeCount; i++) {
      if (_seedLogs.isEmpty) break;
      final removed = _seedLogs.removeAt(0);
      try {
        _listKey.currentState?.removeItem(
          0,
          (ctx, anim) => SizeTransition(sizeFactor: anim, child: _seedTile(removed)),
          duration: const Duration(milliseconds: 160),
        );
      } catch (_) {}
      _listNotifier.value++;
    }
  }

  Widget _dockButton({required IconData icon, required String label, required VoidCallback onTap, required Color color, int? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: soft.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: neon.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600)),
            if (badge != null && badge > 0) ...[
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(badge.toString(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))
              )
            ]
          ]
        ),
      ),
    );
  }

  Widget _fabBig({required VoidCallback onTap, required bool running}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: running ? [WalletConfig.ALERT_COLOR, WalletConfig.ACCENT_D] : [WalletConfig.ACCENT_A, WalletConfig.ACCENT_B],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (running ? WalletConfig.ALERT_COLOR : WalletConfig.ACCENT_A).withValues(alpha: running ? 0.6 : 0.3),
              blurRadius: running ? 30 : 15,
              spreadRadius: running ? 5 : 0,
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: Center(child: Icon(running ? Iconsax.stop : Iconsax.play, color: Colors.white, size: 28)),
      ),
    );
  }
}