// lib/modules/wallet.dart
// Sora Elite Wallet — Premium Responsive Edition
// - Modern Glassmorphism UI & Professional Layout (Grid for Desktop, List for Mobile)
// - Material 3 Rounded Icons & Premium Typography (SpaceGrotesk + Inter)
// - Fallback order: CoinGecko -> CoinCap -> Binance (symbolUSDT) -> Coinbase -> CoinLore -> CoinPaprika
// - Retry + timeout + graceful UI
// - All texts English & professional
// Note: keep assets/icons/*.svg in place; flutter_svg filter-stripping preserved.

import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WalletEliteScreen extends StatefulWidget {
  const WalletEliteScreen({super.key});

  @override
  State<WalletEliteScreen> createState() => _WalletEliteScreenState();
}

class _WalletEliteScreenState extends State<WalletEliteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final Random _rnd = Random();
  final Uri _telegramUri = Uri.parse('https://t.me/im_abi_oo');

  // formatting helpers
  final NumberFormat _qtyFmtLarge = NumberFormat('#,##0.####', 'en_US');
  final NumberFormat _qtyFmtSmall = NumberFormat('#,##0.########', 'en_US');
  final NumberFormat _moneyFmt = NumberFormat('###,##0.00', 'en_US');

  // state
  final double _todayProfit = 0.00; // default zero; edit in code if needed
  bool _isFetching = false;

  // Enable live updates (we try robust multi-API fallback)
  final bool _liveUpdatesEnabled = true;

  // Theme Colors
  final Color _bgColor = const Color(0xFF07090F);
  final Color _accentCyan = const Color(0xFF00E5FF);
  final Color _accentPurple = const Color(0xFF7C4DFF);

  // Assets (edit here to change assets/quantities)
  static const List<_Asset> _defaultAssets = [
    _Asset('Bitcoin', 'BTC', 'assets/icons/btc.svg', 'bitcoin', 1.0),
    _Asset('Ethereum', 'ETH', 'assets/icons/eth.svg', 'ethereum', 0.0),
    _Asset('Tether', 'USDT', 'assets/icons/usdt.svg', 'tether', 0.0),
    _Asset('USD Coin', 'USDC', 'assets/icons/usdc.svg', 'usd-coin', 0.0),
    _Asset('BNB', 'BNB', 'assets/icons/bnb.svg', 'binancecoin', 0.0),
    _Asset('Cardano', 'ADA', 'assets/icons/ada.svg', 'cardano', 0.0),
    _Asset('Solana', 'SOL', 'assets/icons/sol.svg', 'solana', 0.0),
    _Asset('XRP', 'XRP', 'assets/icons/xrp.svg', 'ripple', 0.0),
    _Asset('Dogecoin', 'DOGE', 'assets/icons/doge.svg', 'dogecoin', 0.0),
    _Asset('Polkadot', 'DOT', 'assets/icons/dot.svg', 'polkadot', 0.0),
    _Asset('Litecoin', 'LTC', 'assets/icons/ltc.svg', 'litecoin', 0.0),
    _Asset('Chainlink', 'LINK', 'assets/icons/link.svg', 'chainlink', 0.0),
    _Asset('Tron', 'TRX', 'assets/icons/trx.svg', 'tron', 0.0),
    _Asset('Polygon', 'Matic', 'assets/icons/matic.svg', 'polygon', 0.0),
    _Asset('Uniswap', 'UNI', 'assets/icons/uni.svg', 'uniswap', 0.0),
    _Asset('Avalanche', 'AVAX', 'assets/icons/avax.svg', 'avalanche-2', 0.0),
    _Asset('Stellar', 'XLM', 'assets/icons/xlm.svg', 'stellar', 0.0),
    _Asset('Dai', 'DAI', 'assets/icons/dai.svg', 'dai', 0.0),
    _Asset('SushiSwap', 'SUSHI', 'assets/icons/sushi.svg', 'sushi', 0.0),
    _Asset('Aave', 'AAVE', 'assets/icons/aave.svg', 'aave', 0.0),
    _Asset('TON', 'TON', 'assets/icons/ton.svg', 'toncoin', 0.0),
    _Asset('Monero', 'XMR', 'assets/icons/xmr.svg', 'monero', 0.0),
    _Asset('EOS', 'EOS', 'assets/icons/eos.svg', 'eos', 0.0),
    _Asset('Dash', 'DASH', 'assets/icons/dash.svg', 'dash', 0.0),
    _Asset('The Sandbox', 'SAND', 'assets/icons/sand.svg', 'the-sandbox', 0.0),
    _Asset('Harmony', 'ONE', 'assets/icons/one.svg', 'harmony', 0.0),
  ];

  List<_Asset> get _assets => _defaultAssets;

  // prices map
  final Map<String, double> _prices = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    if (_liveUpdatesEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPrices());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------------- Multi-API price fetch with fallbacks (UNCHANGED LOGIC)
  Future<void> _fetchPrices() async {
    if (mounted) setState(() => _isFetching = true);

    final missing = <_Asset>[];
    try {
      final ids = _assets
          .map((a) => a.coingeckoId)
          .where((id) => id != null && id.isNotEmpty)
          .map((e) => e!.trim())
          .toSet()
          .toList();

      if (ids.isNotEmpty) {
        final idsParam = ids.map(Uri.encodeComponent).join(',');
        final cgUrl = Uri.parse(
            'https://api.coingecko.com/api/v3/simple/price?ids=$idsParam&vs_currencies=usd');
        try {
          final resp = await http.get(cgUrl).timeout(const Duration(seconds: 8));
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body) as Map<String, dynamic>;
            for (final id in ids) {
              final val = data[id];
              if (val != null && val['usd'] != null) {
                _prices[id] = (val['usd'] as num).toDouble();
              }
            }
          }
        } catch (_) {}
      }

      for (final a in _assets) {
        final id = a.coingeckoId ?? '';
        final known = id.isNotEmpty ? _prices.containsKey(id) : false;
        if (!known) missing.add(a);
      }

      if (missing.isNotEmpty) {
        final stillMissing = <_Asset>[];
        for (final asset in missing) {
          final id = asset.coingeckoId;
          if (id != null && id.isNotEmpty) {
            final url = Uri.parse('https://api.coincap.io/v2/assets/$id');
            try {
              final resp = await http.get(url).timeout(const Duration(seconds: 6));
              if (resp.statusCode == 200) {
                final data = json.decode(resp.body) as Map<String, dynamic>?;
                final d = data?['data'] as Map<String, dynamic>?;
                final priceStr = d?['priceUsd']?.toString();
                final p = priceStr != null ? double.tryParse(priceStr) : null;
                if (p != null) {
                  _prices[id] = p;
                  continue;
                }
              }
            } catch (_) {}
          }
          stillMissing.add(asset);
        }
        missing..clear()..addAll(stillMissing);
      }

      if (missing.isNotEmpty) {
        const binanceBases = [
          'https://api.binance.com',
          'https://api1.binance.com',
          'https://api2.binance.com',
          'https://api3.binance.com'
        ];
        final stillMissing = <_Asset>[];
        for (final asset in missing) {
          final sym = asset.symbol.toUpperCase();
          final pair = '${sym}USDT';
          bool got = false;
          for (final base in binanceBases) {
            final url = Uri.parse('$base/api/v3/ticker/price?symbol=$pair');
            try {
              final resp = await http.get(url).timeout(const Duration(seconds: 6));
              if (resp.statusCode == 200) {
                final map = json.decode(resp.body);
                if (map != null && map['price'] != null) {
                  final p = double.tryParse(map['price'].toString());
                  if (p != null) {
                    if (asset.coingeckoId != null && asset.coingeckoId!.isNotEmpty) {
                      _prices[asset.coingeckoId!] = p;
                    } else {
                      _prices[sym] = p;
                    }
                    got = true;
                    break;
                  }
                }
              }
            } catch (_) {}
          }
          if (!got) stillMissing.add(asset);
        }
        missing..clear()..addAll(stillMissing);
      }

      if (missing.isNotEmpty) {
        final stillMissing = <_Asset>[];
        for (final asset in missing) {
          final sym = asset.symbol.toUpperCase();
          final pair = '$sym-USD';
          final url = Uri.parse('https://api.coinbase.com/v2/prices/$pair/spot');
          try {
            final resp = await http.get(url).timeout(const Duration(seconds: 6));
            if (resp.statusCode == 200) {
              final data = json.decode(resp.body) as Map<String, dynamic>?;
              final amtStr = (data?['data'] as Map<String, dynamic>?)?['amount']?.toString();
              final p = amtStr != null ? double.tryParse(amtStr) : null;
              if (p != null) {
                if (asset.coingeckoId != null && asset.coingeckoId!.isNotEmpty) {
                  _prices[asset.coingeckoId!] = p;
                } else {
                  _prices[sym] = p;
                }
                continue;
              }
            }
          } catch (_) {}
          stillMissing.add(asset);
        }
        missing..clear()..addAll(stillMissing);
      }

      if (missing.isNotEmpty) {
        try {
          final url = Uri.parse('https://api.coinlore.net/api/tickers/?start=0&limit=200');
          final resp = await http.get(url).timeout(const Duration(seconds: 8));
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body) as Map<String, dynamic>?;
            final list = (data?['data'] as List?)?.cast<dynamic>() ?? [];
            for (final asset in List<_Asset>.from(missing)) {
              final found = list.firstWhere(
                  (it) => (it is Map && it['symbol'] != null && it['symbol'].toString().toUpperCase() == asset.symbol.toUpperCase()),
                  orElse: () => null);
              if (found != null && found is Map && found['price_usd'] != null) {
                final p = double.tryParse(found['price_usd'].toString());
                if (p != null) {
                  if (asset.coingeckoId != null && asset.coingeckoId!.isNotEmpty) {
                    _prices[asset.coingeckoId!] = p;
                  } else {
                    _prices[asset.symbol.toUpperCase()] = p;
                  }
                  missing.remove(asset);
                }
              }
            }
          }
        } catch (_) {}
      }

      if (missing.isNotEmpty) {
        for (final asset in List<_Asset>.from(missing)) {
          final query = Uri.encodeComponent(asset.symbol);
          final searchUrl = Uri.parse('https://api.coinpaprika.com/v1/search?c=coins&q=$query');
          try {
            final resp = await http.get(searchUrl).timeout(const Duration(seconds: 6));
            if (resp.statusCode == 200) {
              final data = json.decode(resp.body) as Map<String, dynamic>;
              final coins = (data['coins'] as List?)?.cast<dynamic>() ?? [];
              if (coins.isNotEmpty) {
                final first = coins.first as Map<String, dynamic>;
                final coinId = first['id'] as String?;
                if (coinId != null && coinId.isNotEmpty) {
                  final tickUrl = Uri.parse('https://api.coinpaprika.com/v1/tickers/$coinId');
                  try {
                    final tResp = await http.get(tickUrl).timeout(const Duration(seconds: 6));
                    if (tResp.statusCode == 200) {
                      final tData = json.decode(tResp.body) as Map<String, dynamic>;
                      final quotes = tData['quotes'] as Map<String, dynamic>?;
                      final usd = quotes != null && quotes['USD'] != null ? (quotes['USD']['price'] as num?) : null;
                      if (usd != null) {
                        final p = usd.toDouble();
                        if (asset.coingeckoId != null && asset.coingeckoId!.isNotEmpty) {
                          _prices[asset.coingeckoId!] = p;
                        } else {
                          _prices[asset.symbol.toUpperCase()] = p;
                        }
                        missing.remove(asset);
                        continue;
                      }
                    }
                  } catch (_) {}
                }
              }
            }
          } catch (_) {}
        }
      }

      if (mounted) setState(() => _isFetching = false);

      if (mounted) {
        if (missing.isEmpty) {
          _showFancySnack('Prices updated successfully.', success: true);
        } else {
          _showFancySnack(
            'Partial update completed.',
            success: false,
            detail: '${missing.length} items could not be updated (will retry next time).',
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isFetching = false);
      if (mounted) _showFancySnack('Price update failed.', success: false, detail: e.toString());
    }
  }

  Future<void> _openTelegram() async {
    try {
      final launched = await launchUrl(_telegramUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) _showFancySnack('Unable to open Telegram', success: false);
    } catch (_) {
      if (mounted) _showFancySnack('Unable to open Telegram', success: false);
    }
  }

  // ---------------- calculations
  double _assetUsdValue(_Asset a) {
    final id = a.coingeckoId ?? '';
    if (id.isNotEmpty && _prices.containsKey(id)) return a.quantity * (_prices[id] ?? 0.0);
    if (a.coingeckoId == 'tether' || a.coingeckoId == 'usd-coin' || a.coingeckoId == 'dai') return a.quantity * 1.0;
    return 0.0;
  }

  double get _totalBalance => _assets.fold(0.0, (p, a) => p + _assetUsdValue(a));

  // ---------------- Format helpers
  String _fmtMoneySuffix(double value) {
    if (_isFetching) return 'Loading...';
    if (!_liveUpdatesEnabled) return 'Disabled';
    return '${_moneyFmt.format(value)}\$';
  }

  String _fmtQuantity(double q) {
    if (q == 0) return '0';
    if (q >= 1) return _qtyFmtLarge.format(q);
    return _qtyFmtSmall.format(q);
  }

  // ---------------- SVG loader with filter-stripping
  Widget _safeSvg(String assetPath, {double size = 52}) {
    return FutureBuilder<String>(
      future: _loadAndCleanSvg(assetPath),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Icon(Icons.currency_bitcoin, color: Colors.white24, size: size * 0.85);
        }
        if (snap.hasError || snap.data == null || snap.data!.trim().isEmpty) {
          return Icon(Icons.currency_bitcoin, color: Colors.white24, size: size * 0.85);
        }
        try {
          return SvgPicture.string(snap.data!, width: size, height: size, fit: BoxFit.contain);
        } catch (_) {
          return Icon(Icons.currency_bitcoin, color: Colors.white24, size: size * 0.85);
        }
      },
    );
  }

  Future<String> _loadAndCleanSvg(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final cleaned = raw.replaceAll(RegExp(r'<filter[\s\S]*?<\/filter>', multiLine: true), '');
      final cleaned2 = cleaned.replaceAll(RegExp(r'<metadata[\s\S]*?<\/metadata>', multiLine: true), '');
      return cleaned2;
    } catch (_) {
      return '';
    }
  }

  // ---------------- Glassmorphism Helper
  Widget _glass({required Widget child, EdgeInsetsGeometry? padding, BorderRadius? radius}) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: radius ?? BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: child,
        ),
      ),
    );
  }

  // ---------------- Fancy snack
  void _showFancySnack(String message, {bool success = true, String? detail}) {
    if (!mounted) return;
    final colorStart = success ? const Color(0xFF00E5FF) : const Color(0xFFFFA726);
    final colorEnd = success ? const Color(0xFF7C4DFF) : const Color(0xFFFF7043);
    final icon = success ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded;

    final content = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colorStart, colorEnd]),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
              if (detail != null) Text(detail, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );

    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      content: _glass(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: content,
      ),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  // ---------------- Preview Dialog
  void _showPreviewDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _glass(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_accentCyan, _accentPurple]),
                  boxShadow: [BoxShadow(color: _accentCyan.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Feature Locked', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'This module is disabled in the preview build.\nContact support via Telegram for full access.',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Close', style: GoogleFonts.inter(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _openTelegram();
                      },
                      icon: Icon(Icons.telegram, color: Colors.white),
                      label: Text('Contact Support', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _accentCyan,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI Components
  Widget _actionButton(IconData icon, String label, VoidCallback? onTap, {bool isLoading = false, bool isLarge = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isLarge ? 16 : 12, horizontal: isLarge ? 24 : 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: isLoading 
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _accentCyan))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: isLarge ? 22 : 18),
                  const SizedBox(width: 8),
                  Text(label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isLarge ? 15 : 13)),
                ],
              ),
        ),
      ),
    );
  }

  Widget _miniIconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, color: Colors.white38, size: 18),
        ),
      ),
    );
  }

  Widget _miniGridBtn(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(bool isDesktop) {
    final total = _totalBalance;
    final profit = _todayProfit;
    final isProfitPositive = profit >= 0;
    final profitColor = isProfitPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final profitStr = isProfitPositive ? '+${_fmtMoneySuffix(profit)}' : '-${_fmtMoneySuffix(profit.abs())}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: _glass(
        padding: const EdgeInsets.all(24),
        child: isDesktop ? _desktopOverviewContent(total, profitStr, profitColor) : _mobileOverviewContent(total, profitStr, profitColor),
      ),
    );
  }

  Widget _mobileOverviewContent(double total, String profitStr, Color profitColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: _accentCyan, size: 28),
            const SizedBox(width: 12),
            Text('Total Balance', style: GoogleFonts.inter(color: Colors.white60, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Text(_fmtMoneySuffix(total), style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: profitColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$profitStr (Today)', style: GoogleFonts.inter(color: profitColor, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _actionButton(Icons.arrow_downward_rounded, 'Receive', _showPreviewDialog)),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(Icons.arrow_outward_rounded, 'Send', _showPreviewDialog)),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(Icons.sync_rounded, 'Reload', _isFetching ? null : _fetchPrices, isLoading: _isFetching)),
          ],
        )
      ],
    );
  }

  Widget _desktopOverviewContent(double total, String profitStr, Color profitColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: _accentCyan, size: 28),
                  const SizedBox(width: 12),
                  Text('Total Balance', style: GoogleFonts.inter(color: Colors.white60, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Text(_fmtMoneySuffix(total), style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: profitColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$profitStr (Today)', style: GoogleFonts.inter(color: profitColor, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(Icons.arrow_downward_rounded, 'Receive', _showPreviewDialog, isLarge: true),
            const SizedBox(width: 16),
            _actionButton(Icons.arrow_outward_rounded, 'Send', _showPreviewDialog, isLarge: true),
            const SizedBox(width: 16),
            _actionButton(Icons.sync_rounded, 'Reload', _isFetching ? null : _fetchPrices, isLoading: _isFetching, isLarge: true),
          ],
        )
      ],
    );
  }

  Widget _buildListAssetCard(_Asset asset, int idx) {
    final usdValue = _assetUsdValue(asset);
    final usdStr = _fmtMoneySuffix(usdValue);
    
    return _glass(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => _openAssetSheet(asset),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_accentCyan.withValues(alpha: 0.2), _accentPurple.withValues(alpha: 0.2)]),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Center(child: _safeSvg(asset.iconPath, size: 32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(usdStr, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_fmtQuantity(asset.quantity)} ${asset.symbol}',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _miniIconBtn(Icons.arrow_downward_rounded, _showPreviewDialog),
                          _miniIconBtn(Icons.arrow_outward_rounded, _showPreviewDialog),
                          _miniIconBtn(Icons.history_toggle_off_rounded, _showPreviewDialog),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridAssetCard(_Asset asset, int idx) {
    final usdValue = _assetUsdValue(asset);
    final usdStr = _fmtMoneySuffix(usdValue);
    
    return _glass(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () => _openAssetSheet(asset),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Center(child: _safeSvg(asset.iconPath, size: 28)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(asset.symbol, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(usdStr, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 4),
            Text('${_fmtQuantity(asset.quantity)} ${asset.symbol}', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniGridBtn(Icons.arrow_downward_rounded, 'Receive', _showPreviewDialog),
                _miniGridBtn(Icons.arrow_outward_rounded, 'Send', _showPreviewDialog),
                _miniGridBtn(Icons.history_toggle_off_rounded, 'History', _showPreviewDialog),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openAssetSheet(_Asset asset) {
    final usdValue = _assetUsdValue(asset);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => _glass(
        radius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 56, height: 6, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white10)),
                  child: Center(child: _safeSvg(asset.iconPath, size: 40)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(asset.symbol, style: GoogleFonts.inter(color: Colors.white54)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmtMoneySuffix(usdValue), style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${_fmtQuantity(asset.quantity)} ${asset.symbol}', style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _actionButton(Icons.arrow_downward_rounded, 'Receive', () { Navigator.of(ctx).pop(); _showPreviewDialog(); })),
                const SizedBox(width: 12),
                Expanded(child: _actionButton(Icons.arrow_outward_rounded, 'Send', () { Navigator.of(ctx).pop(); _showPreviewDialog(); })),
                const SizedBox(width: 12),
                Expanded(child: _actionButton(Icons.history_toggle_off_rounded, 'History', () { Navigator.of(ctx).pop(); _showPreviewDialog(); })),
                const SizedBox(width: 12),
                Expanded(child: _actionButton(Icons.support_agent_rounded, 'Contact', () { Navigator.of(ctx).pop(); _openTelegram(); })),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _background() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          painter: _FancyParticlePainter(_animController.value, seed: _rnd.nextInt(100000)),
          child: Container(color: _bgColor),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Sora Elite', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openTelegram,
            icon: Icon(Icons.telegram, color: _accentCyan, size: 26),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          return Stack(
            children: [
              RepaintBoundary(child: _background()),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _overviewCard(isDesktop)),
                    if (isDesktop)
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400.0,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: 1.15,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildGridAssetCard(_assets[index], index),
                            childCount: _assets.length,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildListAssetCard(_assets[index], index),
                            ),
                            childCount: _assets.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Powered by Sora Elite',
                            style: GoogleFonts.inter(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Asset {
  final String name;
  final String symbol;
  final String iconPath;
  final String? coingeckoId;
  final double quantity;
  const _Asset(this.name, this.symbol, this.iconPath, this.coingeckoId, this.quantity);
}

class _FancyParticlePainter extends CustomPainter {
  final double t;
  final int seed;
  _FancyParticlePainter(this.t, {required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    final paint = Paint()..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 24);
    final base = const Color(0xFF00E5FF).withValues(alpha: 0.04);
    final count = (size.width / 120).clamp(4, 18).toInt();

    for (int i = 0; i < count; i++) {
      final phase = t * 2 * pi + rnd.nextDouble() * pi * 2 + i;
      final x = (0.5 + 0.45 * sin(phase * (0.4 + (i % 4) * 0.02))) * size.width;
      final y = (0.5 + 0.45 * cos(phase * (0.6 + (i % 3) * 0.03))) * size.height;
      paint.color = base.withValues(alpha: 0.02 + (i % 6) * 0.01);
      final r = 2.0 + (i % 4) * 1.2;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final grad = ui.Gradient.radial(
      Offset(size.width * 0.8, size.height * 0.1),
      size.shortestSide * 1.2,
      [Colors.transparent, Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.6)],
      [0.0, 0.5, 1.0],
    );
    final gPaint = Paint()..shader = grad;
    canvas.drawRect(rect, gPaint);
  }

  @override
  bool shouldRepaint(covariant _FancyParticlePainter old) => old.t != t || old.seed != seed;
}