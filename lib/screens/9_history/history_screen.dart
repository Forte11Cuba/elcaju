import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../src/rust/api/token.dart' as cdk;
import '../../src/rust/api/wallet.dart' show Transaction, TransactionDirection, TransactionStatus;
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../data/transaction_meta_storage.dart';
import '../../data/pending_token.dart';
import '../../data/pending_send.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/p2pk_provider.dart';
import '../../core/utils/p2pk_utils.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/bottom_sheet_container.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Filtros disponibles para el historial
enum HistoryFilter {
  all,
  pending,
  toReceive, // Tokens pendientes de reclamar (Receive Later)
  cashu,
  lightning,
}

/// Pantalla de historial de transacciones.
/// Muestra todas las transacciones con filtros y detalles.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _currentFilter = HistoryFilter.all;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Reconciliar al entrar para capturar envíos que el receptor reclamó
    // desde la última vez. Evita que el usuario tenga que pull-to-refresh
    // manualmente para que un pending offline pase a histórico.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            L10n.of(context)!.history,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            // Botón de refrescar
            IconButton(
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.refreshCw, color: Colors.white),
              onPressed: _isRefreshing ? null : _refreshTransactions,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Filtros
              _buildFilters(),

              // Lista de transacciones
              Expanded(
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = L10n.of(context)!;
    final walletProvider = context.watch<WalletProvider>();
    final pendingCount = walletProvider.pendingTokenCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.filterAll,
            icon: LucideIcons.list,
            isSelected: _currentFilter == HistoryFilter.all,
            onTap: () => _setFilter(HistoryFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.filterPending,
            icon: LucideIcons.clock,
            isSelected: _currentFilter == HistoryFilter.pending,
            onTap: () => _setFilter(HistoryFilter.pending),
          ),
          const SizedBox(width: 8),
          _FilterChipWithBadge(
            label: l10n.filterToReceive,
            icon: LucideIcons.download,
            isSelected: _currentFilter == HistoryFilter.toReceive,
            badgeCount: pendingCount,
            onTap: () => _setFilter(HistoryFilter.toReceive),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.filterEcash,
            icon: LucideIcons.coins,
            isSelected: _currentFilter == HistoryFilter.cashu,
            onTap: () => _setFilter(HistoryFilter.cashu),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.filterLightning,
            icon: LucideIcons.zap,
            isSelected: _currentFilter == HistoryFilter.lightning,
            onTap: () => _setFilter(HistoryFilter.lightning),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final walletProvider = context.watch<WalletProvider>();

    // Si el filtro es "toReceive", mostrar pending tokens
    if (_currentFilter == HistoryFilter.toReceive) {
      return _buildPendingTokensList(walletProvider);
    }

    // Envíos offline activos (receptor aún no reclamó) → tile warning arriba
    // con botón de cancel. Son Cashu por definición, así que aparecen en
    // "all", "pending" y "cashu" (consistente con los settled).
    final activeSends =
        (_currentFilter == HistoryFilter.all ||
                _currentFilter == HistoryFilter.pending ||
                _currentFilter == HistoryFilter.cashu)
            ? walletProvider.listActivePendingSends()
            : <PendingSend>[];

    // Envíos offline liquidados (receptor reclamó) → se mezclan con las
    // transactions de CDK por timestamp, renderizados como outgoing settled.
    // Visibles en "all" y "cashu" (son cashu por definición).
    final settledSends =
        (_currentFilter == HistoryFilter.all ||
                _currentFilter == HistoryFilter.cashu)
            ? walletProvider.listSettledPendingSends()
            : <PendingSend>[];

    return FutureBuilder<List<Transaction>>(
      future: walletProvider.getAllTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryAction,
            ),
          );
        }

        final allTransactions = snapshot.data ?? [];
        final filteredTransactions =
            _applyFilter(allTransactions, walletProvider);

        if (filteredTransactions.isEmpty &&
            activeSends.isEmpty &&
            settledSends.isEmpty) {
          return _buildEmptyState();
        }

        // Merge settled sends + transactions en una sola lista ordenada por
        // timestamp descendente. Cada item es Transaction o PendingSend.
        final merged = <Object>[
          ...filteredTransactions,
          ...settledSends,
        ]..sort((a, b) {
            final ta = a is Transaction
                ? a.timestamp.toInt() * 1000
                : (a as PendingSend)
                    .effectiveTimestamp
                    .millisecondsSinceEpoch;
            final tb = b is Transaction
                ? b.timestamp.toInt() * 1000
                : (b as PendingSend)
                    .effectiveTimestamp
                    .millisecondsSinceEpoch;
            return tb.compareTo(ta);
          });

        final totalCount = activeSends.length + merged.length;

        return RefreshIndicator(
          onRefresh: _refreshTransactions,
          color: AppColors.primaryAction,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: totalCount,
            itemBuilder: (context, index) {
              // Activos primero (pin al tope).
              if (index < activeSends.length) {
                return _PendingSendTile(
                  send: activeSends[index],
                  walletProvider: walletProvider,
                );
              }
              final item = merged[index - activeSends.length];
              if (item is Transaction) {
                return _HistoryTransactionTile(
                  transaction: item,
                  walletProvider: walletProvider,
                );
              }
              return _SettledPendingSendTile(
                send: item as PendingSend,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPendingTokensList(WalletProvider walletProvider) {
    final pendingTokens = walletProvider.listPendingTokens();

    if (pendingTokens.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      color: AppColors.primaryAction,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: pendingTokens.length,
        itemBuilder: (context, index) {
          final token = pendingTokens[index];
          return _PendingTokenTile(
            token: token,
            walletProvider: walletProvider,
            onClaim: () => _claimPendingToken(token),
          );
        },
      ),
    );
  }

  Future<void> _claimPendingToken(PendingToken token) async {
    final l10n = L10n.of(context)!;
    final walletProvider = context.read<WalletProvider>();
    final p2pkProvider = context.read<P2PKProvider>();

    try {
      // Detectar P2PK y obtener clave privada si es necesario
      String? p2pkKey;
      if (P2PKUtils.isP2PKLocked(token.encoded)) {
        p2pkKey = p2pkProvider.getPrivateKeyForToken(token.encoded);
      }

      final amount = await walletProvider.claimPendingToken(token.id, p2pkPrivateKey: p2pkKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pendingTokenClaimedSuccess(
              UnitFormatter.formatBalance(amount, token.unit ?? 'sat'),
              token.unit ?? 'sat',
            )),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().toLowerCase();
        String message;
        Color bgColor = AppColors.error;
        if (errorStr.contains('already spent') || errorStr.contains('token already')) {
          message = l10n.tokenAlreadyClaimed;
        } else if (errorStr.contains('no connection')) {
          message = l10n.noConnectionTryLater;
          bgColor = AppColors.warning;
        } else {
          message = l10n.claimError(e.toString());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
          ),
        );
      }
    }
  }

  List<Transaction> _applyFilter(List<Transaction> transactions, WalletProvider walletProvider) {
    switch (_currentFilter) {
      case HistoryFilter.all:
        return transactions;

      case HistoryFilter.pending:
        return transactions
            .where((tx) => tx.status == TransactionStatus.pending)
            .toList();

      case HistoryFilter.toReceive:
        // Pending tokens se manejan por separado en _buildPendingTokensList
        return [];

      case HistoryFilter.cashu:
        return transactions
            .where((tx) => walletProvider.getTransactionType(tx) == TransactionType.cashu)
            .toList();

      case HistoryFilter.lightning:
        return transactions
            .where((tx) => walletProvider.getTransactionType(tx) == TransactionType.lightning)
            .toList();
    }
  }

  Widget _buildEmptyState() {
    final l10n = L10n.of(context)!;
    String message;
    String submessage;

    switch (_currentFilter) {
      case HistoryFilter.all:
        message = l10n.noTransactions;
        submessage = l10n.receiveTokensToStart;
        break;
      case HistoryFilter.pending:
        message = l10n.noPendingTransactions;
        submessage = l10n.allTransactionsCompleted;
        break;
      case HistoryFilter.toReceive:
        message = l10n.noPendingTokens;
        submessage = l10n.noPendingTokensHint;
        break;
      case HistoryFilter.cashu:
        message = l10n.noEcashTransactions;
        submessage = l10n.sendOrReceiveTokens;
        break;
      case HistoryFilter.lightning:
        message = l10n.noLightningTransactions;
        submessage = l10n.depositOrWithdrawLightning;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            submessage,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _setFilter(HistoryFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  Future<void> _refreshTransactions() async {
    setState(() => _isRefreshing = true);

    try {
      final walletProvider = context.read<WalletProvider>();
      // CDK reconcilia sus Transaction pendientes (online); reconcilePendingSends
      // hace lo mismo para el storage de envíos offline. Paralelos e
      // independientes.
      await Future.wait([
        walletProvider.checkPendingTransactions(),
        walletProvider.reconcilePendingSends(),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
}

/// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAction.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAction.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryAction : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryAction : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile de transacción para la pantalla de historial
class _HistoryTransactionTile extends StatelessWidget {
  final Transaction transaction;
  final WalletProvider walletProvider;

  const _HistoryTransactionTile({
    required this.transaction,
    required this.walletProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.direction == TransactionDirection.incoming;
    final fee = transaction.fee.toInt();
    final unit = transaction.unit;

    // Obtener tipo de transacción (Lightning o Cashu)
    final txType = walletProvider.getTransactionType(transaction);
    final isLightning = txType == TransactionType.lightning;

    // Convertir timestamp (BigInt unix) a DateTime
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      transaction.timestamp.toInt() * 1000,
    );

    // Formatear fecha
    final dateStr = _formatDate(timestamp, context);

    // Estado (pending o settled)
    final isPending = transaction.status == TransactionStatus.pending;

    // Formatear monto con unidad
    final formattedAmount = UnitFormatter.formatBalance(
      transaction.amount,
      unit,
    );
    final unitLabel = UnitFormatter.getUnitLabel(unit);

    // Etiqueta del tipo de transacción
    final typeLabel = isLightning ? 'Lightning' : 'Ecash';

    return GestureDetector(
      onTap: () => _showTransactionDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono según tipo (Lightning o Cashu)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLightning ? LucideIcons.zap : LucideIcons.coins,
                color: AppColors.primaryAction,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),

            // Info de la transacción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tipo (Ecash o Lightning)
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            L10n.of(context)!.pendingStatus,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Dirección
                      Icon(
                        isIncoming ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                        size: 12,
                        color: isIncoming ? AppColors.success : AppColors.primaryAction,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPending
                            ? (isIncoming
                                ? L10n.of(context)!.receiving
                                : L10n.of(context)!.sending)
                            : (isIncoming
                                ? L10n.of(context)!.receivedStatus
                                : L10n.of(context)!.sentStatus),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: isIncoming ? AppColors.success : AppColors.primaryAction,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $dateStr',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.memo!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Monto con signo y unidad
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncoming ? '+' : '-'}$formattedAmount',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isIncoming ? AppColors.success : AppColors.primaryAction,
                  ),
                ),
                Text(
                  unitLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                if (fee > 0)
                  Text(
                    'fee: $fee',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),

            // Chevron
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TransactionDetailScreen(
          transaction: transaction,
          walletProvider: walletProvider,
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = L10n.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return l10n.now;
    } else if (diff.inHours < 1) {
      return l10n.agoMinutes(diff.inMinutes);
    } else if (diff.inDays < 1) {
      return l10n.agoHours(diff.inHours);
    } else if (diff.inDays < 7) {
      return l10n.agoDays(diff.inDays);
    } else {
      final locale = Localizations.localeOf(context).toString();
      return DateFormat.yMd(locale).format(date);
    }
  }
}

/// Pantalla de detalle de una transacción (estilo cashu.me)
/// Orden: Título estado → QR → Controles → Monto → Detalles → Copiar
class _TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  final WalletProvider walletProvider;

  const _TransactionDetailScreen({
    required this.transaction,
    required this.walletProvider,
  });

  @override
  State<_TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<_TransactionDetailScreen> {
  // QR dinámico (UR fragments)
  List<String> _urFragments = [];
  int _currentFragment = 0;
  Timer? _animationTimer;

  // Configuración de velocidad
  static const int _intervalFast = 100;
  static const int _intervalMedium = 200;
  static const int _intervalSlow = 400;
  int _currentInterval = _intervalMedium;
  String _speedLabel = 'M';

  // Datos de la transacción
  late final bool _isIncoming;
  late final bool _isLightning;
  String? _tokenOrInvoice;
  late final bool _shouldShowQR;
  bool _isLoadingPendingInvoice = false;
  bool _isReclaiming = false;

  @override
  void initState() {
    super.initState();
    _isIncoming = widget.transaction.direction == TransactionDirection.incoming;
    final txType = widget.walletProvider.getTransactionType(widget.transaction);
    _isLightning = txType == TransactionType.lightning;

    final meta = widget.walletProvider.getTransactionMeta(widget.transaction.id);
    _tokenOrInvoice = meta?.token ?? meta?.invoice;

    // Si es Lightning incoming sin invoice, buscar en pending mint invoices
    if (_tokenOrInvoice == null && _isLightning && _isIncoming) {
      _loadPendingMintInvoice();
    }

    // Mostrar QR para todo EXCEPTO Lightning saliente
    _shouldShowQR = !_isLightning || _isIncoming;

    // Inicializar QR dinámico si es token Cashu
    if (_tokenOrInvoice != null && !_isLightning && _shouldShowQR) {
      _encodeTokenToUR();
    }
  }

  /// Busca el invoice en pending mint invoices si no hay metadata.
  Future<void> _loadPendingMintInvoice() async {
    setState(() => _isLoadingPendingInvoice = true);
    String? invoice;
    try {
      invoice = await widget.walletProvider.findPendingMintInvoice(
        widget.transaction.mintUrl,
        widget.transaction.unit,
      );
    } catch (e, st) {
      debugPrint('findPendingMintInvoice failed: $e\n$st');
    }
    if (mounted) {
      setState(() {
        _isLoadingPendingInvoice = false;
        if (invoice != null) _tokenOrInvoice = invoice;
      });
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _encodeTokenToUR() {
    try {
      final token = cdk.Token.parse(encoded: _tokenOrInvoice!);
      _urFragments = cdk.encodeQrToken(token: token);

      if (_urFragments.length > 1) {
        _startAnimation();
      }
    } catch (e) {
      // Si falla el parsing, usar el string directamente
      _urFragments = [_tokenOrInvoice!];
    }
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      Duration(milliseconds: _currentInterval),
      (timer) {
        if (mounted) {
          setState(() {
            _currentFragment = (_currentFragment + 1) % _urFragments.length;
          });
        }
      },
    );
  }

  void _cycleSpeed() {
    setState(() {
      if (_currentInterval == _intervalMedium) {
        _currentInterval = _intervalFast;
        _speedLabel = 'F';
      } else if (_currentInterval == _intervalFast) {
        _currentInterval = _intervalSlow;
        _speedLabel = 'S';
      } else {
        _currentInterval = _intervalMedium;
        _speedLabel = 'M';
      }
    });
    if (_urFragments.length > 1) {
      _startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = UnitFormatter.formatBalance(
      widget.transaction.amount,
      widget.transaction.unit,
    );
    final unitLabel = UnitFormatter.getUnitLabel(widget.transaction.unit);
    final mintDisplay = UnitFormatter.getMintDisplayName(widget.transaction.mintUrl);
    final isPending = widget.transaction.status == TransactionStatus.pending;

    // Título del estado (como cashu.me)
    final l10n = L10n.of(context)!;
    final statusTitle = _isLightning
        ? l10n.lightningInvoice
        : (_isIncoming ? l10n.receivedEcash : l10n.sentEcash);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // 1. Título de estado (espaciado como cashu.me)
                Text(
                  statusTitle.split('').join(' ').toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. QR Code (si aplica)
                if (_shouldShowQR && _tokenOrInvoice != null) ...[
                  _buildQRCode(),
                  const SizedBox(height: 12),
                  // 3. Controles del QR (si es animado)
                  if (!_isLightning && _urFragments.length > 1) _buildQRControls(),
                  const SizedBox(height: 32),
                ],

                // Mensaje si no hay QR (Lightning saliente)
                if (!_shouldShowQR && _tokenOrInvoice != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.zap,
                          color: AppColors.primaryAction,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.outgoingLightningPayment,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Mensaje si no hay token/invoice (ocultar mientras carga)
                if (_tokenOrInvoice == null && !_isLoadingPendingInvoice) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.fileQuestion,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLightning ? l10n.invoiceNotAvailable : l10n.tokenNotAvailable,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // 4. Monto grande (centrado)
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // 5. Lista de detalles (minimalista como cashu.me)
                _buildDetailsList(
                  unitLabel: unitLabel,
                  mintDisplay: mintDisplay,
                  isPending: isPending,
                ),

                const SizedBox(height: 32),

                // 6. Botón COPY (grande, prominente)
                if (_tokenOrInvoice != null) _buildCopyButton(),

                // 7. Botón CANCEL / RECLAIM — solo para pending outgoing ecash
                if (isPending && !_isIncoming && !_isLightning) ...[
                  const SizedBox(height: 12),
                  _buildReclaimButton(),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildQRCode() {
    final qrData = _isLightning
        ? 'lightning:${_tokenOrInvoice!.toUpperCase()}'
        : (_urFragments.isNotEmpty ? _urFragments[_currentFragment] : _tokenOrInvoice!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: 240,
        backgroundColor: Colors.white,
        errorCorrectionLevel: _isLightning ? QrErrorCorrectLevel.M : QrErrorCorrectLevel.L,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildQRControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Indicador de fragmento
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentFragment + 1}/${_urFragments.length}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Control de velocidad
        GestureDetector(
          onTap: _cycleSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.gauge,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${L10n.of(context)!.speed} $_speedLabel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList({
    required String unitLabel,
    required String mintDisplay,
    required bool isPending,
  }) {
    final l10n = L10n.of(context)!;
    final fee = widget.transaction.fee;
    final feeFormatted = fee > BigInt.zero
        ? UnitFormatter.formatBalance(fee, widget.transaction.unit)
        : null;

    return Column(
      children: [
        // Fee (si existe)
        if (feeFormatted != null)
          _MinimalDetailRow(
            icon: LucideIcons.arrowUpDown,
            label: l10n.fee,
            value: feeFormatted,
          ),
        // Unit
        _MinimalDetailRow(
          icon: LucideIcons.coins,
          label: l10n.unit,
          value: widget.transaction.unit.toUpperCase(),
        ),
        // Mint
        _MinimalDetailRow(
          icon: LucideIcons.landmark,
          label: l10n.mint,
          value: mintDisplay,
        ),
        // Estado (si pendiente)
        if (isPending)
          _MinimalDetailRow(
            icon: LucideIcons.clock,
            label: l10n.status,
            value: l10n.pending,
            valueColor: AppColors.warning,
          ),
        // Memo (si existe)
        if (widget.transaction.memo != null && widget.transaction.memo!.isNotEmpty)
          _MinimalDetailRow(
            icon: LucideIcons.messageSquare,
            label: l10n.memo,
            value: widget.transaction.memo!,
          ),
      ],
    );
  }

  Widget _buildCopyButton() {
    final l10n = L10n.of(context)!;
    final label = _isLightning ? l10n.copyInvoiceButton : l10n.copyButton;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: _tokenOrInvoice!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLightning ? l10n.invoiceCopied : l10n.tokenCopied),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildReclaimButton() {
    final l10n = L10n.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isReclaiming ? null : _confirmReclaim,
        icon: _isReclaiming
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              )
            : const Icon(LucideIcons.undo2, size: 18, color: Colors.white70),
        label: Text(
          l10n.cancelSend,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReclaim() async {
    final l10n = L10n.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BottomSheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.undo2,
                color: AppColors.warning,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              l10n.cancelSendConfirmTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              l10n.cancelSendConfirmBody,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: l10n.cancel,
                    onPressed: () => Navigator.pop(ctx, false),
                    height: 52,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: PrimaryButton(
                    text: l10n.cancelSend,
                    onPressed: () => Navigator.pop(ctx, true),
                    height: 52,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await _doReclaim();
    }
  }

  Future<void> _doReclaim() async {
    final l10n = L10n.of(context)!;
    setState(() => _isReclaiming = true);
    try {
      final result = await widget.walletProvider
          .reclaimTransaction(widget.transaction);
      if (!mounted) return;
      if (result.count > BigInt.zero) {
        final formatted = UnitFormatter.formatBalance(
          result.amount,
          widget.transaction.unit,
        );
        final unitLabel = UnitFormatter.getUnitLabel(widget.transaction.unit);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cancelSendSuccess(formatted, unitLabel)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cancelSendAlreadyClaimed),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isReclaiming = false);
    }
  }
}

/// Chip de filtro con badge
class _FilterChipWithBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _FilterChipWithBadge({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warning.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.warning.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.warning : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.warning : Colors.white70,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tile para un token pendiente de reclamar
class _PendingTokenTile extends StatefulWidget {
  final PendingToken token;
  final WalletProvider walletProvider;
  final Future<void> Function() onClaim;

  const _PendingTokenTile({
    required this.token,
    required this.walletProvider,
    required this.onClaim,
  });

  @override
  State<_PendingTokenTile> createState() => _PendingTokenTileState();
}

class _PendingTokenTileState extends State<_PendingTokenTile> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final token = widget.token;
    final unit = token.unit ?? 'sat';
    final formattedAmount = UnitFormatter.formatBalance(token.amount, unit);
    final unitLabel = UnitFormatter.getUnitLabel(unit);
    final mintDisplay = UnitFormatter.getMintDisplayName(token.mintUrl);
    final daysRemaining = token.daysRemaining;

    // Color según días restantes
    Color daysColor;
    if (daysRemaining <= 3) {
      daysColor = AppColors.error;
    } else if (daysRemaining <= 7) {
      daysColor = AppColors.warning;
    } else {
      daysColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Primera fila: icono, info, monto
          Row(
            children: [
              // Icono con badge PENDING
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.clock,
                      color: AppColors.warning,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.paddingMedium),

              // Info del token
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.pendingBadge,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mintDisplay,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.timer,
                          size: 12,
                          color: daysColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.expiresInDays(daysRemaining),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: daysColor,
                          ),
                        ),
                        if (token.hasError) ...[
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.alertTriangle,
                            size: 12,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.retryCount(token.retryCount),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Monto
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    unitLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Botón reclamar (ancho completo)
          GestureDetector(
            onTap: _isClaiming
                ? null
                : () async {
                    setState(() => _isClaiming = true);
                    try {
                      await widget.onClaim();
                    } finally {
                      if (mounted) {
                        setState(() => _isClaiming = false);
                      }
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: _isClaiming
                    ? null
                    : const LinearGradient(colors: AppColors.buttonGradient),
                color: _isClaiming ? Colors.grey : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isClaiming)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      LucideIcons.download,
                      size: 16,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    _isClaiming ? l10n.claiming : l10n.claimNow,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de detalle minimalista (estilo cashu.me)
class _MinimalDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MinimalDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile para mostrar un envío offline pendiente en el historial.
/// Se renderiza arriba de las Transactions de CDK.
/// Tile para un envío offline activo (receptor aún no reclamó).
/// Visualmente idéntico a una Transaction saliente pending (ecash online):
/// fondo blanco 5%, ícono coins, título "Ecash", badge Pendiente y fila
/// "↗ Enviando • timestamp". Al tap abre el detail screen con QR + cancel.
class _PendingSendTile extends StatelessWidget {
  final PendingSend send;
  final WalletProvider walletProvider;

  const _PendingSendTile({
    required this.send,
    required this.walletProvider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final formattedAmount = UnitFormatter.formatBalance(send.amount, send.unit);
    final unitLabel = UnitFormatter.getUnitLabel(send.unit);
    final dateStr = _formatRelativeDate(send.createdAt, context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _PendingSendDetailScreen(send: send),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.coins,
                color: AppColors.primaryAction,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ecash',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.pendingStatus,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.arrowUpRight,
                        size: 12,
                        color: AppColors.primaryAction,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.sending,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.primaryAction,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $dateStr',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (send.memo != null && send.memo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      send.memo!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-$formattedAmount',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAction,
                  ),
                ),
                Text(
                  unitLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile para un envío offline liquidado (receptor ya reclamó). Visualmente
/// equivalente a una Transaction saliente Cashu settled, para que el
/// historial sea uniforme entre online y offline.
class _SettledPendingSendTile extends StatelessWidget {
  final PendingSend send;

  const _SettledPendingSendTile({required this.send});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final formattedAmount =
        UnitFormatter.formatBalance(send.amount, send.unit);
    final unitLabel = UnitFormatter.getUnitLabel(send.unit);
    final dateStr = _formatRelativeDate(
      send.effectiveTimestamp,
      context,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _PendingSendDetailScreen(send: send),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.coins,
                color: AppColors.primaryAction,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ecash',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.arrowUpRight,
                        size: 12,
                        color: AppColors.primaryAction,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.sentStatus,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.primaryAction,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $dateStr',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (send.memo != null && send.memo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      send.memo!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-$formattedAmount',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAction,
                  ),
                ),
                Text(
                  unitLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Formateo relativo de fecha. Compartido por los tiles del historial.
String _formatRelativeDate(DateTime date, BuildContext context) {
  final l10n = L10n.of(context)!;
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return l10n.now;
  if (diff.inHours < 1) return l10n.agoMinutes(diff.inMinutes);
  if (diff.inDays < 1) return l10n.agoHours(diff.inHours);
  if (diff.inDays < 7) return l10n.agoDays(diff.inDays);
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMd(locale).format(date);
}

/// Pantalla de detalle para un envío offline. Si el envío está activo,
/// muestra QR + botón cancel. Si está liquidado (receptor reclamó), muestra
/// solo el audit trail.
class _PendingSendDetailScreen extends StatefulWidget {
  final PendingSend send;

  const _PendingSendDetailScreen({required this.send});

  @override
  State<_PendingSendDetailScreen> createState() =>
      _PendingSendDetailScreenState();
}

class _PendingSendDetailScreenState extends State<_PendingSendDetailScreen> {
  List<String> _urFragments = [];
  int _currentFragment = 0;
  Timer? _animationTimer;
  bool _isReclaiming = false;

  // Control de velocidad del QR animado (alineado con _TransactionDetailScreen)
  static const int _intervalFast = 100;
  static const int _intervalMedium = 200;
  static const int _intervalSlow = 400;
  int _currentInterval = _intervalMedium;
  String _speedLabel = 'M';

  @override
  void initState() {
    super.initState();
    // Para settled el QR ya no sirve (receptor reclamó), no desperdiciamos
    // ciclos codificándolo.
    if (widget.send.isActive) _encodeTokenToUR();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _encodeTokenToUR() {
    try {
      final token = cdk.Token.parse(encoded: widget.send.encoded);
      _urFragments = cdk.encodeQrToken(token: token);
      if (_urFragments.length > 1) {
        _startAnimation();
      }
    } catch (_) {
      _urFragments = [widget.send.encoded];
    }
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      Duration(milliseconds: _currentInterval),
      (_) {
        if (mounted) {
          setState(() {
            _currentFragment =
                (_currentFragment + 1) % _urFragments.length;
          });
        }
      },
    );
  }

  void _cycleSpeed() {
    setState(() {
      if (_currentInterval == _intervalMedium) {
        _currentInterval = _intervalFast;
        _speedLabel = 'F';
      } else if (_currentInterval == _intervalFast) {
        _currentInterval = _intervalSlow;
        _speedLabel = 'S';
      } else {
        _currentInterval = _intervalMedium;
        _speedLabel = 'M';
      }
    });
    if (_urFragments.length > 1) _startAnimation();
  }

  Widget _buildQRControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentFragment + 1}/${_urFragments.length}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _cycleSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.gauge,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${L10n.of(context)!.speed} $_speedLabel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReclaim() async {
    final l10n = L10n.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BottomSheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.undo2,
                  color: AppColors.warning, size: 32),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              l10n.cancelSendConfirmTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              l10n.cancelSendConfirmBody,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: l10n.cancel,
                    onPressed: () => Navigator.pop(ctx, false),
                    height: 52,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: PrimaryButton(
                    text: l10n.cancelSend,
                    onPressed: () => Navigator.pop(ctx, true),
                    height: 52,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) await _doReclaim();
  }

  Future<void> _doReclaim() async {
    final l10n = L10n.of(context)!;
    final walletProvider = context.read<WalletProvider>();
    setState(() => _isReclaiming = true);
    try {
      final result = await walletProvider.reclaimPendingSend(widget.send);
      if (!mounted) return;
      if (result.count > BigInt.zero) {
        final formatted =
            UnitFormatter.formatBalance(result.amount, widget.send.unit);
        final unitLabel = UnitFormatter.getUnitLabel(widget.send.unit);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cancelSendSuccess(formatted, unitLabel)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cancelSendAlreadyClaimed),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isReclaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final formattedAmount =
        UnitFormatter.formatBalance(widget.send.amount, widget.send.unit);
    final unitLabel = UnitFormatter.getUnitLabel(widget.send.unit);
    final mintDisplay =
        UnitFormatter.getMintDisplayName(widget.send.mintUrl);
    final isActive = widget.send.isActive;
    final qrData = _urFragments.isNotEmpty
        ? _urFragments[_currentFragment]
        : widget.send.encoded;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // 1. Título estado (mismo formato que la pantalla online)
                Text(
                  l10n.sentEcash.split('').join(' ').toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                // 2. QR — solo cuando el envío está activo (receptor aún no
                // reclamó). Cuando está settled, el token ya es obsoleto.
                if (isActive) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.L,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // 3. Controles del QR (si es animado)
                  if (_urFragments.length > 1) ...[
                    const SizedBox(height: 12),
                    _buildQRControls(),
                  ],
                ],
                const SizedBox(height: 32),
                // 4. Monto grande
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // 5. Lista de detalles (mismo formato que la pantalla online)
                Column(
                  children: [
                    _MinimalDetailRow(
                      icon: LucideIcons.coins,
                      label: l10n.unit,
                      value: unitLabel,
                    ),
                    _MinimalDetailRow(
                      icon: LucideIcons.landmark,
                      label: l10n.mint,
                      value: mintDisplay,
                    ),
                    _MinimalDetailRow(
                      icon: isActive ? LucideIcons.clock : LucideIcons.check,
                      label: l10n.status,
                      value: isActive ? l10n.pending : l10n.sentStatus,
                      valueColor:
                          isActive ? AppColors.warning : AppColors.success,
                    ),
                    if (widget.send.memo != null &&
                        widget.send.memo!.isNotEmpty)
                      _MinimalDetailRow(
                        icon: LucideIcons.messageSquare,
                        label: l10n.memo,
                        value: widget.send.memo!,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.send.encoded));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.tokenCopied),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.copyButton,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                // Botón cancel sólo cuando el envío está activo.
                if (isActive) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isReclaiming ? null : _confirmReclaim,
                    icon: _isReclaiming
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white70),
                            ),
                          )
                        : const Icon(LucideIcons.undo2,
                            size: 18, color: Colors.white70),
                    label: Text(
                      l10n.cancelSend,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

