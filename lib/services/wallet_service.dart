// lib/services/wallet_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WalletService extends ChangeNotifier {
  // Singleton instance
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // Formatting
  final NumberFormat _moneyFmt = NumberFormat('###,##0.00', 'en_US');
  
  // State
  bool isFetching = false;
  final Map<String, double> _prices = {};
  
  // Assets list (همون لیست wallet.dart)
  final List<_AssetData> _assets = [
    _AssetData('Bitcoin', 'BTC', 'bitcoin', 0.0),
    _AssetData('Ethereum', 'ETH', 'ethereum', 0.0),
    _AssetData('Tether', 'USDT', 'tether', 0.0),
    _AssetData('USD Coin', 'USDC', 'usd-coin', 0.0),
    _AssetData('BNB', 'BNB', 'binancecoin', 0.0),
    _AssetData('Cardano', 'ADA', 'cardano', 0.0),
    _AssetData('Solana', 'SOL', 'solana', 0.0),
    _AssetData('XRP', 'XRP', 'ripple', 0.0),
    _AssetData('Dogecoin', 'DOGE', 'dogecoin', 0.0),
    _AssetData('Polkadot', 'DOT', 'polkadot', 0.0),
    _AssetData('Litecoin', 'LTC', 'litecoin', 0.0),
    _AssetData('Chainlink', 'LINK', 'chainlink', 0.0),
    _AssetData('Tron', 'TRX', 'tron', 0.0),
    _AssetData('Polygon', 'MATIC', 'polygon', 0.0),
    _AssetData('Uniswap', 'UNI', 'uniswap', 0.0),
    _AssetData('Avalanche', 'AVAX', 'avalanche-2', 0.0),
    _AssetData('Stellar', 'XLM', 'stellar', 0.0),
    _AssetData('Dai', 'DAI', 'dai', 0.0),
    _AssetData('SushiSwap', 'SUSHI', 'sushi', 0.0),
    _AssetData('Aave', 'AAVE', 'aave', 0.0),
    _AssetData('TON', 'TON', 'toncoin', 0.0),
    _AssetData('Monero', 'XMR', 'monero', 0.0),
    _AssetData('EOS', 'EOS', 'eos', 0.0),
    _AssetData('Dash', 'DASH', 'dash', 0.0),
    _AssetData('The Sandbox', 'SAND', 'the-sandbox', 0.0),
    _AssetData('Harmony', 'ONE', 'harmony', 0.0),
  ];

  List<_AssetData> get assets => _assets;
  Map<String, double> get prices => _prices;

  // محاسبه موجودی کل
  double get totalBalance {
    return _assets.fold(0.0, (sum, asset) {
      final id = asset.coingeckoId;
      if (id.isNotEmpty && _prices.containsKey(id)) {
        return sum + (asset.quantity * _prices[id]!);
      }
      // Stablecoins
      if (id == 'tether' || id == 'usd-coin' || id == 'dai') {
        return sum + asset.quantity;
      }
      return sum;
    });
  }

  String get formattedBalance => _moneyFmt.format(totalBalance);

  // دریافت قیمت‌ها (همون منطق wallet.dart)
  Future<void> fetchPrices() async {
    isFetching = true;
    notifyListeners();

    try {
      // CoinGecko API
      final ids = _assets
          .map((a) => a.coingeckoId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (ids.isNotEmpty) {
        final idsParam = ids.map(Uri.encodeComponent).join(',');
        final url = Uri.parse(
            'https://api.coingecko.com/api/v3/simple/price?ids=$idsParam&vs_currencies=usd');
        
        try {
          final resp = await http.get(url).timeout(const Duration(seconds: 8));
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

      // اینجا می‌تونی fallback های دیگه (Binance, Coinbase, etc) رو هم اضافه کنی
      // برای سادگی فقط CoinGecko رو نگه داشتم

    } catch (e) {
      print('Error fetching prices: $e');
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }
}

class _AssetData {
  final String name;
  final String symbol;
  final String coingeckoId;
  final double quantity;

  _AssetData(this.name, this.symbol, this.coingeckoId, this.quantity);
}