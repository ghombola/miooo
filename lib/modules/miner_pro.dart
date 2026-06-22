// lib/modules/miner_pro.dart
// Cloud Mining Application - PRODUCTION | Modern UI Refresh
// Class Name: MinerProScreen
// Design System: Glassmorphism + Adaptive Layout + Professional Iconography

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✨ Modern Icon Package

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 DESIGN TOKENS & CONFIGURATION
// ─────────────────────────────────────────────────────────────────────────────

class AppDesignTokens {
  // Color Palette
  static const Color backgroundPrimary = Color(0xFF040408);
  static const Color backgroundSecondary = Color(0xFF0F0F1A);
  static const Color surfaceGlass = Color(0x14FFFFFF);
  static const Color surfaceGlassHover = Color(0x1EFFFFFF);
  
  // Accent Gradients
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ];
  
  static const List<Color> gradientSuccess = [
    Color(0xFF10B981), // Emerald
    Color(0xFF34D399),
  ];
  
  // Typography Scale
  static const TextStyle headline1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5,
  );
  static const TextStyle headline2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2,
  );
  
  // Spacing Scale
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;
  
  // Shadows & Elevation
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x05000000), blurRadius: 40, offset: Offset(0, 12)),
  ];
  
  static const List<BoxShadow> shadowGlow = [
    BoxShadow(color: Color(0x406366F1), blurRadius: 30, offset: Offset(0, 0)),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// 📊 GLOBAL CONSTANTS & CONFIGURATION (UNCHANGED LOGIC)
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _kCurrencyList = ['BTC', 'ETH', 'DOGE', 'TRX', 'TON'];
const double _kRewardTickSeconds = 600.0; // 10 minutes (Pool Payout Cycle)
const double _kHashrateUpdateSeconds = 1.0;

// Dynamic Minimum Payouts
const Map<String, double> _kMinPayouts = {
  'BTC': 0.005,
  'ETH': 0.05,
  'DOGE': 50.0,
  'TRX': 50.0,
  'TON': 5.0,
};

// Configuration per Currency (Hashrate Unit, Base Rate, Initial Power)
const Map<String, dynamic> _kCurrencyConfig = {
  'BTC': {'unit': 'TH/s', 'rate_per_sec': 0.00000023148148148148148, 'base_power': 1000.0, 'max_fluctuation': 0.005, 'icon': FontAwesomeIcons.bitcoin, 'color': Color(0xFFF7931A)},
  'ETH': {'unit': 'MH/s', 'rate_per_sec': 0.00000038580246913580245, 'base_power': 300.0, 'max_fluctuation': 0.015, 'icon': FontAwesomeIcons.ethereum, 'color': Color(0xFF627EEA)},
  'DOGE': {'unit': 'KH/s', 'rate_per_sec': 0.0000023148148148148148, 'base_power': 5000.0, 'max_fluctuation': 0.03, 'icon': FontAwesomeIcons.dog, 'color': Color(0xFFC2A633)},
  'TRX': {'unit': 'GH/s', 'rate_per_sec': 0.00018518518518518518, 'base_power': 50.0, 'max_fluctuation': 0.02, 'icon': FontAwesomeIcons.solidCircle, 'color': Color(0xFFEB0029)},
  'TON': {'unit': 'MH/s', 'rate_per_sec': 0.000011574074074074073, 'base_power': 400.0, 'max_fluctuation': 0.01, 'icon': FontAwesomeIcons.telegram, 'color': Color(0xFF0088CC)},
};

// Network Difficulty Map
const Map<String, double> _kNetworkDifficulty = {
  'BTC': 10000.0,
  'ETH': 500.0,
  'DOGE': 10.0,
  'TRX': 80.0,
  'TON': 400.0,
};

// Default Balances
const Map<String, double> _kDefaultBalances = {
  'BTC': 0.0,
  'ETH': 0.0,
  'DOGE': 0.0,
  'TRX': 0.0,
  'TON': 0.0,
};

// Other Constants
const String _kTelegramId = 'im_abi_oo';
const String _kFooterText = 'Powered by Sora Elite';
const double _kPoolFeePercent = 1.0;
const double _kWithdrawFlatFee = 0.00004;

// ─────────────────────────────────────────────────────────────────────────────
// 🔧 MODELS & UTILITIES
// ─────────────────────────────────────────────────────────────────────────────

// Responsive Breakpoints
class Breakpoint {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

// ─────────────────────────────────────────────────────────────────────────────
// 🖥️ MAIN WIDGET: MinerProScreen
// ─────────────────────────────────────────────────────────────────────────────

class MinerProScreen extends StatefulWidget {
  const MinerProScreen({super.key});
  
  @override
  State<MinerProScreen> createState() => _MinerProScreenState();
}

class _MinerProScreenState extends State<MinerProScreen> with TickerProviderStateMixin {
  // ── State Variables (UNCHANGED) ───────────────────────────────────────────
  final Map<String, double> _balances = {};
  String _selectedCurrency = _kCurrencyList.first;
  bool _isMining = false;
  double _currentHashrate = 0.0;
  double _userBaseHashrate = 0.0;
  Timer? _miningTimer;
  Timer? _hashrateUpdateTimer;
  Timer? _progressTimer;
  String _userId = 'User-001';
  
  // UI State
  double _rewardProgress = 0.0;
  bool _isHoveringFAB = false;
  
  // Animations
  late final AnimationController _coinController;
  late final AnimationController _glowController;
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _pulseAnimation;
  late final TabController _tabController;
  
  // Persistence
  late SharedPreferences _prefs;
  final Random _rand = Random();
  
  // ignore: unused_field
  bool _timersActive = false;
  
  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initializeBalances();
    _initializeAnimations();
    _initializeTabController();
    _initApp();
  }
  
  void _initializeBalances() {
    for (final c in _kCurrencyList) {
      _balances[c] = _kDefaultBalances[c] ?? 0.0;
    }
  }
  
  void _initializeAnimations() {
    _coinController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    
    _glowAnimation = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
  }
  
  void _initializeTabController() {
    _tabController = TabController(length: _kCurrencyList.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  // ── Core Initialization & Persistence (UNCHANGED LOGIC) ───────────────────
  double _calculateInitialHashrate(String id, String currency) {
    final base = _kCurrencyConfig[currency]!['base_power'] as double;
    final hash = id.codeUnits.reduce((a, b) => a + b) + currency.length;
    final seed = Random(hash);
    return base * (0.9 + seed.nextDouble() * 0.2);
  }
  
  Future<void> _initApp() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString('user_id') ?? 'User-${Random().nextInt(999).toString().padLeft(3, '0')}';
      _prefs.setString('user_id', _userId);
      
      for (final c in _kCurrencyList) {
        _balances[c] = _prefs.getDouble('cloud_balance_$c') ?? (_kDefaultBalances[c] ?? 0.0);
      }
      
      _userBaseHashrate = _prefs.getDouble('user_base_hashrate') ?? _calculateInitialHashrate(_userId, _selectedCurrency);
      _currentHashrate = 0.0;
    });
    debugPrint('System: Dashboard initialized. Asset: $_selectedCurrency. UserId: $_userId');
  }
  
  Future<void> _saveHashrate() async {
    await _prefs.setDouble('user_base_hashrate', _userBaseHashrate);
  }
  
  @override
  void dispose() {
    _cancelAllTimers();
    _coinController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _cancelAllTimers() {
    _miningTimer?.cancel(); _miningTimer = null;
    _hashrateUpdateTimer?.cancel(); _hashrateUpdateTimer = null;
    _progressTimer?.cancel(); _progressTimer = null;
    _timersActive = false;
  }
  
  // ── Event Handlers (UNCHANGED LOGIC) ──────────────────────────────────────
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final newCurrency = _kCurrencyList[_tabController.index];
    if (newCurrency == _selectedCurrency) return;
    _handleCurrencyChange(newCurrency);
  }
  
  void _handleCurrencyChange(String newCurrency) {
    if (_isMining) {
      debugPrint('Error: Cannot switch asset while active.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabController.index = _kCurrencyList.indexOf(_selectedCurrency);
      });
      return;
    }
    
    final newBaseRate = _calculateInitialHashrate(_userId, newCurrency);
    
    setState(() {
      _selectedCurrency = newCurrency;
      _userBaseHashrate = newBaseRate;
      _currentHashrate = 0.0;
      _rewardProgress = 0.0;
    });
    debugPrint('System: Asset switched to: $_selectedCurrency');
    _saveHashrate();
  }
  
  // ── Mining Logic (UNCHANGED) ──────────────────────────────────────────────
  void _startMining() {
    if (_isMining || _userBaseHashrate <= 0) return;
    _cancelAllTimers();
    
    setState(() {
      _isMining = true;
      _currentHashrate = _userBaseHashrate;
      _coinController.repeat();
      _pulseController.repeat();
    });
    
    _runStartupSequence();
    
    _miningTimer = Timer.periodic(Duration(seconds: _kRewardTickSeconds.toInt()), (_) => _miningTick());
    _hashrateUpdateTimer = Timer.periodic(Duration(seconds: _kHashrateUpdateSeconds.toInt()), (_) => _hashrateTick());
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _updateProgress());
    _timersActive = true;
    
    debugPrint('System: Mining started for $_selectedCurrency');
  }
  
  void _hashrateTick() {
    if (!_isMining) return;
    final config = _kCurrencyConfig[_selectedCurrency]!;
    final maxFluctuation = config['max_fluctuation'] as double;
    final base = _userBaseHashrate;
    final fluctuationFactor = 1.0 + (_rand.nextDouble() * maxFluctuation * 4 - (maxFluctuation * 2));
    final targetHashrate = base * fluctuationFactor;
    
    setState(() {
      _currentHashrate = (_currentHashrate * 0.9) + (targetHashrate * 0.1);
    });
    _saveHashrate();
  }
  
  void _updateProgress() {
    if (!_isMining) {
      _progressTimer?.cancel();
      _progressTimer = null;
      return;
    }
    setState(() {
      final step = 1.0 / (_kRewardTickSeconds * 10);
      _rewardProgress += step;
      if (_rewardProgress >= 1.0) _rewardProgress = 0.0;
    });
  }
  
  void _miningTick() {
    final config = _kCurrencyConfig[_selectedCurrency]!;
    final ratePerSec = config['rate_per_sec'] as double;
    final assetDifficulty = _kNetworkDifficulty[_selectedCurrency] ?? 1.0;
    final effectiveHashrate = _currentHashrate;
    final reward = effectiveHashrate * ratePerSec * _kRewardTickSeconds / assetDifficulty;
    
    setState(() {
      _balances[_selectedCurrency] = (_balances[_selectedCurrency] ?? 0.0) + reward;
      _rewardProgress = 0.0;
    });
    
    debugPrint('Job accepted. +${reward.toStringAsFixed(8)} $_selectedCurrency.');
    _saveBalance(_selectedCurrency);
  }
  
  void _stopMining() {
    if (!_isMining) return;
    _cancelAllTimers();
    setState(() {
      _isMining = false;
      _coinController.stop();
      _pulseController.stop();
      _currentHashrate = 0.0;
      _rewardProgress = 0.0;
      _saveHashrate();
    });
    debugPrint('Mining stopped by user.');
  }
  
  // ── Utilities ─────────────────────────────────────────────────────────────
  Future<void> _saveBalance(String currency) async {
    await _prefs.setDouble('cloud_balance_$currency', _balances[currency] ?? 0.0);
  }
  
  Future<void> _runStartupSequence() async {
    final steps = [
      '// Executing Startup Protocol...',
      '\\> Connecting to pool nodes...',
      '\\> Validating Security Keys (OK)...',
      '\\> Allocating resources...',
      '// Core Online. Asset unit: ${_kCurrencyConfig[_selectedCurrency]!['unit']}',
    ];
    for (final s in steps) {
      debugPrint(s);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
  
  // ──────────────────────────────────────────────────────────────────────────
  // 🎨 MODERN UI COMPONENTS
  // ──────────────────────────────────────────────────────────────────────────
  
  // ✨ Enhanced Glass Card with Hover & Glow Effects
  Widget _buildGlassCard({
    required Widget child,
    required Color borderColor,
    double opacity = 0.08,
    bool enableGlow = false,
    bool enableHover = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: enableHover ? (_) => setState(() => _isHoveringFAB = true) : null,
          onExit: enableHover ? (_) => setState(() => _isHoveringFAB = false) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
              border: Border.all(
                color: borderColor.withValues(alpha: _isHoveringFAB && enableHover ? 0.7 : 0.4),
                width: _isHoveringFAB && enableHover ? 2 : 1.5,
              ),
              boxShadow: enableGlow && _isMining 
                  ? [...AppDesignTokens.shadowSoft, ...AppDesignTokens.shadowGlow] 
                  : AppDesignTokens.shadowSoft,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: opacity * (_isHoveringFAB && enableHover ? 1.3 : 1)),
                        Colors.white.withValues(alpha: opacity * 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // ✨ Animated Currency Tab with Professional Icons
  Widget _buildCurrencySelection(double screenWidth) {
    final isDesktop = Breakpoint.isDesktop(screenWidth);
    final isMobile = Breakpoint.isMobile(screenWidth);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? AppDesignTokens.spaceXL : AppDesignTokens.spaceMD),
      padding: EdgeInsets.all(isMobile ? AppDesignTokens.spaceXS : AppDesignTokens.spaceSM),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceGlass,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: !isDesktop,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusSM),
          gradient: LinearGradient(colors: AppDesignTokens.gradientPrimary),
          boxShadow: [BoxShadow(color: Colors.deepPurpleAccent.withValues(alpha: 0.4), blurRadius: 12)],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: isMobile ? 12 : 14),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: isMobile ? 11 : 13),
        tabs: _kCurrencyList.map((currency) {
          final config = _kCurrencyConfig[currency]!;
          final isSelected = currency == _selectedCurrency;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 10 : 12,
              horizontal: isMobile ? 8 : 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Professional Icon with Color
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (config['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    config['icon'] as FaIconData,
                    size: isMobile ? 16 : 18,
                    color: isSelected ? config['color'] : Colors.white70,
                  ),
                ),
                if (!isMobile) const SizedBox(width: 8),
                if (!isMobile)
                  Text(
                    currency,
                    style: GoogleFonts.inter(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // ✨ Enhanced Balance Panel with Animated Icon
  Widget _buildBalancePanel(double screenWidth) {
    final isMobile = Breakpoint.isMobile(screenWidth);
    final bal = (_balances[_selectedCurrency] ?? 0.0);
    final minPayout = _kMinPayouts[_selectedCurrency] ?? 0.0;
    final config = _kCurrencyConfig[_selectedCurrency]!;
    
    return _buildGlassCard(
      opacity: 0.1,
      borderColor: config['color'] as Color,
      enableGlow: true,
      enableHover: true,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppDesignTokens.spaceMD : AppDesignTokens.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: AppDesignTokens.labelSmall.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedCurrency,
                      style: GoogleFonts.inter(
                        color: config['color'],
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                // Animated Currency Icon
                AnimatedBuilder(
                  animation: _coinController,
                  builder: (_, child) => Transform.rotate(
                    angle: _isMining ? _coinController.value * 2 * pi : 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (config['color'] as Color).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (config['color'] as Color).withValues(alpha: 0.3)),
                      ),
                      child: FaIcon(
                        config['icon'] as FaIconData,
                        size: 28,
                        color: config['color'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Balance Display
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.inter(
                color: _isMining ? Colors.white : Colors.white70,
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
              child: Text(
                bal.toStringAsFixed(8),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payout Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bal >= minPayout 
                    ? Colors.green.withValues(alpha: 0.15) 
                    : Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSM),
                border: Border.all(
                  color: bal >= minPayout 
                      ? Colors.green.withValues(alpha: 0.3) 
                      : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    bal >= minPayout ? Icons.check_circle_outline : Icons.access_time_filled,
                    size: 14,
                    color: bal >= minPayout ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bal >= minPayout 
                        ? 'Ready for withdrawal' 
                        : 'Min: ${minPayout.toStringAsFixed(minPayout < 1 ? 6 : 2)}',
                    style: GoogleFonts.inter(
                      color: bal >= minPayout ? Colors.green : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ✨ Professional Hashrate Panel with Live Progress
  Widget _buildHashratePanel(double screenWidth) {
    final isMobile = Breakpoint.isMobile(screenWidth);
    final unit = _kCurrencyConfig[_selectedCurrency]!['unit'];
    final config = _kCurrencyConfig[_selectedCurrency]!;
    
    final timeRemaining = _kRewardTickSeconds * (1 - _rewardProgress);
    final minutes = (timeRemaining / 60).floor();
    final seconds = (timeRemaining % 60).floor();
    final timeText = minutes > 0 
        ? '${minutes}m ${seconds.toString().padLeft(2, '0')}s' 
        : '${timeRemaining.toStringAsFixed(1)}s';
    
    return _buildGlassCard(
      opacity: 0.12,
      borderColor: Colors.cyanAccent.shade700,
      enableGlow: true,
      enableHover: true,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppDesignTokens.spaceMD : AppDesignTokens.spaceLG),
        child: Column(
          children: [
            // Title
            Text(
              'HASHRATE PERFORMANCE',
              style: AppDesignTokens.labelSmall.copyWith(color: Colors.white60, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            
            // Animated Hashrate Value
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) => Text(
                _currentHashrate.toStringAsFixed(2),
                style: GoogleFonts.inter(
                  color: _isMining ? Colors.cyanAccent : Colors.white54,
                  fontSize: isMobile ? 32 : 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  shadows: _isMining 
                      ? [BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: _glowAnimation.value * 0.8),
                          blurRadius: 30,
                          spreadRadius: 2,
                        )]
                      : [],
                ),
              ),
            ),
            
            // Unit Badge
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (config['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (config['color'] as Color).withValues(alpha: 0.4)),
              ),
              child: Text(
                unit,
                style: GoogleFonts.inter(
                  color: config['color'],
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            
            // Progress Bar
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: MediaQuery.of(context).size.width * (_isMining ? _rewardProgress : 0) * 0.9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isMining ? AppDesignTokens.gradientSuccess : [Colors.white24, Colors.white10],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Status Text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isMining ? 'NEXT PAYOUT: $timeText' : 'MINING PAUSED',
                key: ValueKey(_isMining),
                style: GoogleFonts.inter(
                  color: _isMining ? Colors.greenAccent : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ✨ Modern Withdraw Button
  Widget _buildWithdrawButton(double screenWidth) {
    final isMobile = Breakpoint.isMobile(screenWidth);
    final bal = _balances[_selectedCurrency] ?? 0.0;
    final minPayout = _kMinPayouts[_selectedCurrency] ?? 0.0;
    final canWithdraw = bal >= minPayout;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        onPressed: canWithdraw ? () => _withdrawFlow(context) : null,
        icon: FaIcon(
          FontAwesomeIcons.wallet,
          size: 18,
          color: canWithdraw ? Colors.black87 : Colors.white54,
        ),
        label: Text(
          'WITHDRAW FUNDS',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 14 : 15,
            letterSpacing: 0.5,
            color: canWithdraw ? Colors.black87 : Colors.white54,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canWithdraw ? Colors.amber.shade600 : Colors.grey.shade800,
          foregroundColor: canWithdraw ? Colors.black87 : Colors.white54,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 28 : 40,
            vertical: isMobile ? 14 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD),
            side: BorderSide(
              color: canWithdraw 
                  ? Colors.amber.shade400.withValues(alpha: 0.5) 
                  : Colors.transparent,
              width: 1,
            ),
          ),
          elevation: canWithdraw ? 12 : 0,
          shadowColor: canWithdraw ? Colors.amber.withValues(alpha: 0.4) : Colors.transparent,
          disabledBackgroundColor: Colors.grey.shade800,
          disabledForegroundColor: Colors.white54,
        ),
      ),
    );
  }
  
  // ✨ Adaptive Main Layout
  Widget _buildResponsiveLayout(double screenWidth) {
    final isDesktop = Breakpoint.isDesktop(screenWidth);
    
    // Desktop: Grid Layout | Mobile: Vertical Stack
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Balance & Controls
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: AppDesignTokens.spaceMD),
              child: Column(
                children: [
                  _buildBalancePanel(screenWidth),
                  const SizedBox(height: AppDesignTokens.spaceMD),
                  _buildHashratePanel(screenWidth),
                ],
              ),
            ),
          ),
          // Right Column: Actions & Info
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: AppDesignTokens.spaceMD),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDesignTokens.spaceLG),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.surfaceGlass,
                      borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUICK ACTIONS',
                          style: AppDesignTokens.labelSmall.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: AppDesignTokens.spaceMD),
                        Center(child: _buildWithdrawButton(screenWidth)),
                        const SizedBox(height: AppDesignTokens.spaceLG),
                        Text(
                          'SESSION INFO',
                          style: AppDesignTokens.labelSmall.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: AppDesignTokens.spaceSM),
                        _buildSessionInfoItem('User ID', _userId),
                        _buildSessionInfoItem('Asset', _selectedCurrency),
                        _buildSessionInfoItem('Status', _isMining ? '🟢 Active' : '⚪ Idle', 
                            color: _isMining ? Colors.green : Colors.white70),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    // Mobile/Tablet: Vertical Stack
    return Column(
      children: [
        _buildBalancePanel(screenWidth),
        const SizedBox(height: AppDesignTokens.spaceMD),
        _buildHashratePanel(screenWidth),
        const SizedBox(height: AppDesignTokens.spaceXL),
        Center(child: _buildWithdrawButton(screenWidth)),
      ],
    );
  }
  
  Widget _buildSessionInfoItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(
            color: color ?? Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          )),
        ],
      ),
    );
  }
  
  // ──────────────────────────────────────────────────────────────────────────
  // 🎬 MAIN BUILD METHOD
  // ──────────────────────────────────────────────────────────────────────────
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.backgroundPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isDesktop = Breakpoint.isDesktop(screenWidth);
          
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  AppDesignTokens.backgroundPrimary,
                  Colors.deepPurple.shade900.withValues(alpha: 0.3),
                  AppDesignTokens.backgroundPrimary,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: isDesktop ? 80 : 70,
                    floating: true,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: isDesktop ? 40 : 16, bottom: 16),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppDesignTokens.gradientPrimary),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.microchip,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'CLOUD MINING PRO',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: isDesktop ? 22 : 18,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    elevation: 0,
                  ),
                  
                  // Main Content
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: isDesktop ? AppDesignTokens.spaceXL : AppDesignTokens.spaceLG,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Currency Selector
                          _buildCurrencySelection(screenWidth),
                          const SizedBox(height: AppDesignTokens.spaceLG),
                          
                          // Responsive Content Grid
                          _buildResponsiveLayout(screenWidth),
                          
                          const SizedBox(height: AppDesignTokens.spaceXXL),
                          
                          // Footer
                          Text(
                            _kFooterText,
                            style: GoogleFonts.inter(
                              color: Colors.white30,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      
      // ✨ Enhanced Floating Action Button
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, child) => Transform.scale(
          scale: _isMining ? 1.0 + (_pulseAnimation.value * 0.05) : 1.0,
          child: child,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _isMining ? _stopMining() : _startMining(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isMining
                ? FaIcon(FontAwesomeIcons.pause, key: const ValueKey('pause'), size: 24)
                : FaIcon(FontAwesomeIcons.play, key: const ValueKey('play'), size: 24),
          ),
          label: Text(
            _isMining ? 'PAUSE MINING' : 'START MINING',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.3,
              color: Colors.black,
            ),
          ),
          backgroundColor: _isMining 
              ? Colors.redAccent.shade400 
              : Colors.greenAccent.shade400,
          foregroundColor: Colors.black,
          elevation: _isMining ? 16 : 12,
          splashColor: Colors.white.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusXL),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  // ──────────────────────────────────────────────────────────────────────────
  // 💸 WITHDRAW FLOW (UNCHANGED LOGIC, ENHANCED UI)
  // ──────────────────────────────────────────────────────────────────────────
  
  Future<void> _withdrawFlow(BuildContext ctx) async {
    final bal = _balances[_selectedCurrency] ?? 0.0;
    final minPayout = _kMinPayouts[_selectedCurrency] ?? 0.0;
    final config = _kCurrencyConfig[_selectedCurrency]!;
    
    if (bal < minPayout) {
      ScaffoldMessenger.of(ctx).showSnackBar(_buildSnackBar(
        'Minimum: ${minPayout.toStringAsFixed(minPayout < 1 ? 8 : 2)} $_selectedCurrency',
        isSuccess: false,
      ));
      return;
    }
    
    final fee = bal * (_kPoolFeePercent / 100.0) + _kWithdrawFlatFee;
    final net = bal > fee ? bal - fee : 0.0;
    
    Widget buildDetailRow(String label, String value, Color valueColor) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
            Text(value, style: GoogleFonts.inter(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            )),
          ],
        ),
      );
    }
    
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => Dialog(
        backgroundColor: AppDesignTokens.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG)),
        child: Container(
          padding: const EdgeInsets.all(AppDesignTokens.spaceLG),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG),
            border: Border.all(color: (config['color'] as Color).withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (config['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FaIcon(config['icon'] as FaIconData, color: config['color'], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'WITHDRAW $_selectedCurrency',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              
              // Details
              buildDetailRow('Available', bal.toStringAsFixed(8), Colors.white),
              buildDetailRow('Pool Fee (1%)', '-${(bal * 0.01).toStringAsFixed(8)}', Colors.redAccent.shade200),
              buildDetailRow('Network Fee', '-${_kWithdrawFlatFee.toStringAsFixed(8)}', Colors.orangeAccent),
              const Divider(color: Colors.white10, height: 24),
              buildDetailRow('NET PAYOUT', net.toStringAsFixed(8), Colors.greenAccent),
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.white60)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config['color'],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSM),
                      ),
                    ),
                    child: Text('CONTACT SUPPORT', style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (confirmed == true) await _launchContact();
  }
  
  SnackBar _buildSnackBar(String message, {bool isSuccess = false}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.info_outline, 
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 14))),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade700 : Colors.deepPurpleAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    );
  }
  
  Future<void> _launchContact() async {
    final Uri contactUri = Uri.parse('https://t.me/$_kTelegramId');
    try {
      await launchUrl(contactUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: _kTelegramId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(
          'Telegram ID copied: $_kTelegramId',
          isSuccess: true,
        ));
      }
    }
  }
}