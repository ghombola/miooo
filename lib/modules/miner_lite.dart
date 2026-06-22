// lib/modules/miner_lite.dart
// Minimalist Miner Lite - Highly Optimized for low battery/resource usage
// Modernized UI with professional layout, responsive design, and modern icons.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ---------------- Supporting Classes and Enums ----------------
enum MiningMode { eco, standard, performance, extreme }
enum PowerMode { eco, balanced, performance }

class MiningConfig {
  final String name;
  final double baseHashrate;
  final double powerConsumption;
  final double rewardMultiplier;
  final Color color;
  final String description;

  const MiningConfig({
    required this.name,
    required this.baseHashrate,
    required this.powerConsumption,
    required this.rewardMultiplier,
    required this.color,
    required this.description,
  });
}

class PowerConfig {
  final String name;
  final double multiplier;
  final Color color;

  const PowerConfig(this.name, this.multiplier, this.color);
}
// ---------------- END Supporting Classes and Enums ----------------

/// Miner Lite - Minimalist & Highly Optimized Screen
class MinerLiteScreen extends StatefulWidget {
  const MinerLiteScreen({super.key});

  @override
  State<MinerLiteScreen> createState() => _MinerLiteScreenState();
}

class _MinerLiteScreenState extends State<MinerLiteScreen> {
  // --- Mining Data
  double _minedAmount = 0.0;
  double _currentHashrate = 0.0;
  double _averageHashrate = 0.0;
  double _peakHashrate = 0.0;
  double _sessionEarnings = 0.0;
  int _totalShares = 0;
  int _acceptedShares = 0;
  Duration _miningUptime = Duration.zero;
  DateTime? _miningStartTime; 

  // --- State
  bool _isMining = false;
  bool _isInitializing = false;
  String _miningStatus = 'Ready to start';
  MiningMode _miningMode = MiningMode.standard;
  PowerMode _powerMode = PowerMode.balanced;

  // --- Timers
  Timer? _initializationTimer;
  Timer? _miningCoreTimer; 
  Timer? _autoSaveTimer;

  // --- Theme / Colors (Modern Dark Slate Palette)
  final Color _bgPrimary = const Color(0xFF0B0F19); // Deep dark navy
  final Color _bgSecondary = const Color(0xFF111827); // Slightly lighter navy
  final Color _cardBg = const Color(0xFF1F2937); // Card background
  final Color _cardBorder = const Color(0xFF374151); // Subtle border
  final Color _textPrimary = const Color(0xFFF9FAFB); // Almost white
  final Color _textSecondary = const Color(0xFF9CA3AF); // Gray
  final Color _textMuted = const Color(0xFF6B7280); // Darker gray
  final Color _accentBitcoin = const Color(0xFFF7931A); // Bitcoin orange
  final Color _accentGreen = const Color(0xFF10B981); // Emerald
  final Color _accentRed = const Color(0xFFEF4444); // Red
  final Color _accentBlue = const Color(0xFF3B82F6); // Blue
  final Color _accentPurple = const Color(0xFF8B5CF6); // Purple
  final String _currency = 'BTC';

  // --- Configs
  static const Map<MiningMode, MiningConfig> _miningConfigs = {
    MiningMode.eco: MiningConfig(
      name: 'Eco Mode',
      baseHashrate: 450.0,
      powerConsumption: 0.6,
      rewardMultiplier: 0.8,
      color: Color(0xFF10B981), 
      description: 'Energy efficient mining',
    ),
    MiningMode.standard: MiningConfig(
      name: 'Standard Mode',
      baseHashrate: 650.0,
      powerConsumption: 1.0,
      rewardMultiplier: 1.0,
      color: Color(0xFF3B82F6), 
      description: 'Balanced performance',
    ),
    MiningMode.performance: MiningConfig(
      name: 'Performance Mode',
      baseHashrate: 850.0,
      powerConsumption: 1.4,
      rewardMultiplier: 1.3,
      color: Color(0xFFF59E0B), 
      description: 'Maximum performance',
    ),
    MiningMode.extreme: MiningConfig(
      name: 'Extreme Mode',
      baseHashrate: 1200.0,
      powerConsumption: 2.0,
      rewardMultiplier: 1.8,
      color: Color(0xFFEF4444), 
      description: 'Overclock settings',
    ),
  };

  static const Map<PowerMode, PowerConfig> _powerConfigs = {
    PowerMode.eco: PowerConfig('Power Saver', 0.7, Color(0xFF10B981)),
    PowerMode.balanced: PowerConfig('Balanced', 1.0, Color(0xFF3B82F6)),
    PowerMode.performance: PowerConfig('High Performance', 1.4, Color(0xFFF59E0B)),
  };

  final Random _random = Random();
  final Uri _telegramUri = Uri.parse('https://t.me/im_abi_oo');

  static const List<String> _initSteps = [
    'Checking device compatibility...',
    'Connecting to network...',
    'Optimizing miner parameters...',
    'Starting mining engine...',
    'Mining successfully initiated!',
  ];

  @override
  void initState() {
    super.initState();
    _loadMiningData();
  }

  @override
  void dispose() {
    _cleanupTimers();
    super.dispose();
  }

  void _cleanupTimers() {
    _initializationTimer?.cancel();
    _miningCoreTimer?.cancel();
    _autoSaveTimer?.cancel();
  }

  Future<void> _loadMiningData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _minedAmount = prefs.getDouble('lite_mined_amount') ?? 0.0;
        _totalShares = prefs.getInt('lite_total_shares') ?? 0;
        _acceptedShares = prefs.getInt('lite_accepted_shares') ?? 0;
        _averageHashrate = prefs.getDouble('lite_average_hashrate') ?? 0.0;
        _peakHashrate = prefs.getDouble('lite_peak_hashrate') ?? 0.0;
        _miningMode = MiningMode.values[prefs.getInt('lite_mining_mode') ?? 1];
        _powerMode = PowerMode.values[prefs.getInt('lite_power_mode') ?? 1];
      });
    } catch (e) {
      debugPrint('Error loading mining data: $e');
    }
  }

  Future<void> _saveMiningData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lite_mined_amount', _minedAmount);
      await prefs.setInt('lite_total_shares', _totalShares);
      await prefs.setInt('lite_accepted_shares', _acceptedShares);
      await prefs.setDouble('lite_average_hashrate', _averageHashrate);
      await prefs.setDouble('lite_peak_hashrate', _peakHashrate);
      await prefs.setInt('lite_mining_mode', _miningMode.index);
      await prefs.setInt('lite_power_mode', _powerMode.index);
    } catch (e) {
      debugPrint('Error saving mining data: $e');
    }
  }

  void _updateMiningCore() {
    if (!_isMining || !mounted) return;

    final config = _miningConfigs[_miningMode]!;
    final powerConfig = _powerConfigs[_powerMode]!;
    final baseHashrate = config.baseHashrate * powerConfig.multiplier;
    
    final fluctuation = 0.9 + _random.nextDouble() * 0.2; 
    _currentHashrate = baseHashrate * fluctuation;

    if (_currentHashrate > _peakHashrate) {
      _peakHashrate = _currentHashrate;
    }

    _averageHashrate = (_averageHashrate * 0.94) + (_currentHashrate * 0.06);

    if (_random.nextDouble() < 0.3) { 
      _totalShares++;
      if (_random.nextDouble() < 0.97) {
        _acceptedShares++;
      }
    }

    if (_miningStartTime != null) {
      _miningUptime = DateTime.now().difference(_miningStartTime!);
    }

    final timePassed = _miningUptime.inSeconds % 45;
    if (timePassed < 5) { 
      _processMiningReward();
    }
    
    setState(() {});
  }

  void _processMiningReward() {
    final config = _miningConfigs[_miningMode]!;
    // Removed unused powerConfig variable to fix analyzer warning

    final baseReward = 0.00000065; 
    final hashrateBonus = (_currentHashrate / config.baseHashrate).clamp(0.5, 2.0);
    final modeMultiplier = config.rewardMultiplier;
    final randomFactor = 0.75 + _random.nextDouble() * 0.5;

    final reward = baseReward * hashrateBonus * modeMultiplier * randomFactor;

    setState(() {
      _minedAmount += reward;
      _sessionEarnings += reward;
    });
  }

  void _startLiteMining() {
    if (_isMining) return;

    setState(() {
      _isMining = true;
      _isInitializing = true;
      _miningStatus = 'Initializing...';
      _sessionEarnings = 0.0;
      _miningUptime = Duration.zero;
      _miningStartTime = DateTime.now();
    });

    _runInitializationSequence();
  }

  void _runInitializationSequence() {
    int currentStep = 0;

    _initializationTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (currentStep < _initSteps.length) {
        setState(() {
          _miningStatus = _initSteps[currentStep];
        });
        currentStep++;
      } else {
        timer.cancel();
        _finishInitialization();
      }
    });
  }

  void _finishInitialization() {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _miningStatus = 'Mining Active';
    });

    _startMiningOperations();
  }

  void _startMiningOperations() {
    _miningCoreTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_isMining) return;
      _updateMiningCore();
    });

    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (!mounted) return;
      _saveMiningData();
    });
  }

  void _stopLiteMining() {
    _cleanupTimers();

    if (!mounted) return;

    _updateMiningCore(); 

    setState(() {
      _isMining = false;
      _isInitializing = false;
      _miningStatus = 'Stopped';
      _currentHashrate = 0.0;
      _miningStartTime = null;
    });

    _saveMiningData();
    _showMiningCompletedDialog();
  }

  void _showMiningCompletedDialog() {
    final uptimeStr = _formatDuration(_miningUptime);
    final avgHashrateStr = _averageHashrate.toStringAsFixed(1);
    final sessionEarningsStr = _sessionEarnings.toStringAsFixed(8);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _cardBorder)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(FontAwesomeIcons.circleCheck, color: _accentGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Session Summary', style: GoogleFonts.outfit(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogStat('Duration', uptimeStr),
            _buildDialogStat('Earnings', '$sessionEarningsStr BTC'),
            _buildDialogStat('Avg Hashrate', '$avgHashrateStr TH/s'),
            _buildDialogStat('Peak Hashrate', '${_peakHashrate.toStringAsFixed(1)} TH/s'),
            _buildDialogStat('Shares', '$_acceptedShares / $_totalShares'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _accentBitcoin.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentBitcoin.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.bitcoin, color: _accentBitcoin, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Balance', style: GoogleFonts.inter(color: _textSecondary, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          '${_minedAmount.toStringAsFixed(8)} BTC',
                          style: GoogleFonts.outfit(color: _accentBitcoin, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(color: _textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showWithdrawDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentBitcoin,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Withdraw', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: _textSecondary, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(color: _textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _showWithdrawDialog() async {
    if (_minedAmount <= 0) {
      _showNotification('No BTC balance to withdraw', isError: true);
      return;
    }

    final estimatedValue = _minedAmount * 45000.0; 

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _cardBorder)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentBitcoin.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(FontAwesomeIcons.bitcoin, color: _accentBitcoin, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Withdraw BTC', style: GoogleFonts.outfit(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Balance', style: GoogleFonts.inter(color: _textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text('${_minedAmount.toStringAsFixed(8)} BTC', style: GoogleFonts.outfit(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('≈ \$${estimatedValue.toStringAsFixed(2)} USD', style: GoogleFonts.inter(color: _accentGreen, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _accentBitcoin.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentBitcoin.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    FaIcon(FontAwesomeIcons.circleInfo, color: _accentBitcoin, size: 16),
                    const SizedBox(width: 8),
                    Text('Feature Locked', style: GoogleFonts.inter(color: _accentBitcoin, fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    'This module is disabled in the preview build. Contact support via Telegram for full access.',
                    style: GoogleFonts.inter(color: _textSecondary, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                await _openTelegram();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0088CC).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0088CC).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.telegram, color: const Color(0xFF0088CC), size: 20),
                    const SizedBox(width: 12),
                    Text('Contact: @im_abi_oo', style: GoogleFonts.inter(color: const Color(0xFF0088CC), fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: _textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088CC),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Contact Dev', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _openTelegram();
    }
  }

  Future<void> _openTelegram() async {
    try {
      final launched = await launchUrl(_telegramUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        await Clipboard.setData(const ClipboardData(text: '@im_abi_oo'));
        _showNotification('Telegram ID copied: @im_abi_oo');
      }
    } catch (e) {
      await Clipboard.setData(const ClipboardData(text: '@im_abi_oo'));
      _showNotification('Telegram ID copied: @im_abi_oo');
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            FaIcon(
              isError ? FontAwesomeIcons.circleExclamation : FontAwesomeIcons.circleCheck,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? _accentRed : _accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(isDesktop),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isDesktop 
                      ? _buildDesktopLayout() 
                      : _buildMobileLayout(),
                  ),
                ),
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildMiningCard(),
              const SizedBox(height: 16),
              _buildQuickStatsRow(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildPowerModeControls(),
              const SizedBox(height: 16),
              _buildMiningPresetControls(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMiningCard(),
        const SizedBox(height: 16),
        _buildQuickStatsRow(),
        const SizedBox(height: 16),
        _buildPowerModeControls(),
        const SizedBox(height: 16),
        _buildMiningPresetControls(),
      ],
    );
  }

  Widget _buildModernAppBar(bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 100.0,
      pinned: true,
      backgroundColor: _bgPrimary,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bgSecondary, _bgPrimary],
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentBitcoin.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentBitcoin.withValues(alpha: 0.3)),
              ),
              child: FaIcon(FontAwesomeIcons.bitcoin, color: _accentBitcoin, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Miner Lite',
              style: GoogleFonts.outfit(
                color: _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      actions: [
        _buildModeSelector(),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildModeSelector() {
    final currentConfig = _miningConfigs[_miningMode]!;

    return PopupMenuButton<MiningMode>(
      initialValue: _miningMode,
      onSelected: (mode) {
        if (_isMining) {
          _showNotification('Cannot change mode while mining', isError: true);
          return;
        }
        setState(() => _miningMode = mode);
        _saveMiningData();
      },
      color: _cardBg,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _cardBorder)),
      itemBuilder: (context) => MiningMode.values.map((mode) {
        final config = _miningConfigs[mode]!;
        return PopupMenuItem<MiningMode>(
          value: mode,
          child: Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: config.color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(config.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _textPrimary)),
                  Text(config.description, style: GoogleFonts.inter(fontSize: 11, color: _textMuted)),
                ]),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: currentConfig.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: currentConfig.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.gaugeHigh, color: currentConfig.color, size: 16),
            const SizedBox(width: 8),
            Text(
              currentConfig.name.split(' ').first,
              style: GoogleFonts.inter(color: currentConfig.color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            FaIcon(FontAwesomeIcons.chevronDown, color: currentConfig.color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMiningCard() {
    final config = _miningConfigs[_miningMode]!;
    final powerCfg = _powerConfigs[_powerMode]!;
    final maxHashrate = config.baseHashrate * powerCfg.multiplier;
    final progress = (_currentHashrate / maxHashrate).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.wallet, color: _textSecondary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Total Balance',
                          style: GoogleFonts.inter(color: _textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _minedAmount.toStringAsFixed(8),
                          style: GoogleFonts.outfit(
                            color: _textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currency,
                          style: GoogleFonts.inter(
                            color: _accentBitcoin,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Hashrate',
                style: GoogleFonts.inter(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                '${_currentHashrate.toStringAsFixed(1)} TH/s',
                style: GoogleFonts.inter(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildModernProgressBar(progress),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildMiniStat('Session Earnings', '${_sessionEarnings.toStringAsFixed(8)} BTC', FontAwesomeIcons.coins),
              ),
              Container(width: 1, height: 40, color: _cardBorder),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStat('Uptime', _formatDuration(_miningUptime), FontAwesomeIcons.clock),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildModernProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: _bgSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accentBlue, _accentPurple],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, FaIconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(icon, color: _textMuted, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isMining ? _accentGreen.withValues(alpha: 0.15) : _textMuted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isMining ? _accentGreen.withValues(alpha: 0.3) : _textMuted.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            _isMining ? FontAwesomeIcons.bolt : FontAwesomeIcons.circlePause,
            color: _isMining ? _accentGreen : _textSecondary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _miningStatus,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _isMining ? _accentGreen : _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              if (_isInitializing) return;
              if (_isMining) {
                _stopLiteMining();
              } else {
                _startLiteMining();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isMining ? _accentRed : _accentBitcoin,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isInitializing)
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                else
                  FaIcon(
                    _isMining ? FontAwesomeIcons.circleStop : FontAwesomeIcons.play,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  _isMining ? 'Stop Mining' : 'Start Mining',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _showWithdrawDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: _accentBitcoin,
              side: BorderSide(color: _accentBitcoin.withValues(alpha: 0.5), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.wallet, size: 18),
                const SizedBox(width: 8),
                Text('Withdraw', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Core Statistics',
            style: GoogleFonts.outfit(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildStatCard('Avg Hashrate', '${_averageHashrate.toStringAsFixed(1)} TH/s', FontAwesomeIcons.gaugeHigh, _accentBlue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Peak Hashrate', '${_peakHashrate.toStringAsFixed(1)} TH/s', FontAwesomeIcons.arrowTrendUp, _accentPurple)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Shares', '$_acceptedShares / $_totalShares', FontAwesomeIcons.circleCheck, _accentGreen)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, FaIconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPowerModeControls() {
    return _buildSettingsCard(
      title: 'Power Mode',
      icon: FontAwesomeIcons.bolt,
      child: _buildSegmentedControl<PowerMode>(
        values: PowerMode.values,
        selectedValue: _powerMode,
        labels: {
          PowerMode.eco: 'Eco',
          PowerMode.balanced: 'Balanced',
          PowerMode.performance: 'Performance',
        },
        colors: {
          PowerMode.eco: _accentGreen,
          PowerMode.balanced: _accentBlue,
          PowerMode.performance: _accentBitcoin,
        },
        onSelected: (mode) {
          if (_isMining) {
            _showNotification('Cannot change power while mining', isError: true);
            return;
          }
          setState(() => _powerMode = mode);
          _saveMiningData();
        },
      ),
    );
  }

  Widget _buildMiningPresetControls() {
    return _buildSettingsCard(
      title: 'Mining Preset',
      icon: FontAwesomeIcons.gear,
      child: _buildSegmentedControl<MiningMode>(
        values: MiningMode.values,
        selectedValue: _miningMode,
        labels: {
          MiningMode.eco: 'Eco',
          MiningMode.standard: 'Standard',
          MiningMode.performance: 'Performance',
          MiningMode.extreme: 'Extreme',
        },
        colors: {
          MiningMode.eco: _accentGreen,
          MiningMode.standard: _accentBlue,
          MiningMode.performance: _accentBitcoin,
          MiningMode.extreme: _accentRed,
        },
        onSelected: (mode) {
          if (_isMining) {
            _showNotification('Cannot change mode while mining', isError: true);
            return;
          }
          setState(() => _miningMode = mode);
          _saveMiningData();
        },
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required FaIconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: _textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSegmentedControl<T>({
    required List<T> values,
    required T selectedValue,
    required Map<T, String> labels,
    required Map<T, Color> colors,
    required ValueChanged<T> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: values.map((val) {
          final isSelected = val == selectedValue;
          final color = colors[val] ?? _textPrimary;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(val),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(color: color.withValues(alpha: 0.4)) : null,
                ),
                child: Text(
                  labels[val]!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isSelected ? color : _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.bolt, color: _accentPurple.withValues(alpha: 0.6), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Powered by Sora Elite',
                  style: GoogleFonts.inter(
                    color: _textMuted.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
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