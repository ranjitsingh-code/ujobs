import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_app_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'providers/wallet_provider.dart';
import '../../../../core/models/wallet.dart';
import '../../../../core/models/payment.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: l10n.walletAndBilling,
        showBack: true,
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.borderLight,
          labelStyle: AppText.bodyBold,
          unselectedLabelStyle: AppText.body,
          tabs: [
            Tab(text: l10n.transactions),
            Tab(text: l10n.paymentHistory),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WalletTab(),
          _PaymentsTab(),
        ],
      ),
    );
  }
}

// ── Wallet & Transactions Tab ──────────────────────────────────────────────────
class _WalletTab extends ConsumerStatefulWidget {
  const _WalletTab();

  @override
  ConsumerState<_WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends ConsumerState<_WalletTab> {
  int _currentPage = 1;
  final List<WalletTransaction> _transactions = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    
    try {
      final nextTxs = await ref.read(walletTransactionsProvider(_currentPage + 1).future);
      if (mounted) {
        setState(() {
          _currentPage++;
          if (nextTxs.isEmpty) {
            _hasMore = false;
          } else {
            _transactions.addAll(nextTxs);
          }
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncWallet = ref.watch(walletProvider);
    final asyncTxs = ref.watch(walletTransactionsProvider(1));

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _transactions.clear();
          _hasMore = true;
        });
        ref.invalidate(walletProvider);
        ref.invalidate(walletTransactionsProvider);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: asyncWallet.when(
              data: (wallet) => _BalanceCard(balance: wallet.balance),
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            sliver: asyncTxs.when(
              data: (initialTxs) {
                if (_currentPage == 1 && _transactions.isEmpty) {
                  _transactions.addAll(initialTxs);
                  if (initialTxs.isEmpty) _hasMore = false;
                }

                if (_transactions.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        l10n.noTransactions,
                        style: AppText.body.copyWith(color: AppColors.muted),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _transactions.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      }
                      return _TransactionCard(tx: _transactions[index]);
                    },
                    childCount: _transactions.length + (_hasMore ? 1 : 0),
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.error,
                    style: AppText.body.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: EdgeInsets.all(20.r),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedWallet01,
                color: Colors.white70,
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.walletBalance,
                style: AppText.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            NumberFormat.currency(symbol: '\$').format(balance),
            style: AppText.heroTitle.copyWith(color: Colors.white, fontSize: 36.sp),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type.toLowerCase() == 'credit';
    final sign = isCredit ? '+' : '-';
    final color = isCredit ? AppColors.success : AppColors.error;
    final icon = isCredit ? HugeIcons.strokeRoundedArrowDownLeft01 : HugeIcons.strokeRoundedArrowUpRight01;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: icon,
              color: color,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: AppText.bodyBold.copyWith(color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(tx.createdAt),
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$sign${NumberFormat.currency(symbol: '\$').format(tx.amount)}',
            style: AppText.bodyBold.copyWith(color: color, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

// ── Payments Tab ───────────────────────────────────────────────────────────────
class _PaymentsTab extends ConsumerStatefulWidget {
  const _PaymentsTab();

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  int _currentPage = 1;
  final List<Payment> _payments = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    
    try {
      final nextPymts = await ref.read(paymentsProvider(_currentPage + 1).future);
      if (mounted) {
        setState(() {
          _currentPage++;
          if (nextPymts.isEmpty) {
            _hasMore = false;
          } else {
            _payments.addAll(nextPymts);
          }
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncPymts = ref.watch(paymentsProvider(1));

    return asyncPymts.when(
      data: (initialPymts) {
        if (_currentPage == 1 && _payments.isEmpty) {
          _payments.addAll(initialPymts);
          if (initialPymts.isEmpty) _hasMore = false;
        }

        if (_payments.isEmpty) {
          return Center(
            child: Text(
              l10n.noPayments,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            setState(() {
              _currentPage = 1;
              _payments.clear();
              _hasMore = true;
            });
            ref.invalidate(paymentsProvider);
          },
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.all(20.w),
            itemCount: _payments.length + (_hasMore ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index == _payments.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return _PaymentCard(payment: _payments[index]);
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, _) => Center(
        child: Text(
          l10n.error,
          style: AppText.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPaid = payment.status.toLowerCase() == 'paid';
    final statusColor = isPaid ? AppColors.success : AppColors.warning;

    // e.g. GBP or USD symbol mapping
    String currencySymbol = '\$';
    if (payment.currency.toUpperCase() == 'GBP') currencySymbol = '£';
    if (payment.currency.toUpperCase() == 'EUR') currencySymbol = '€';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.planName.isNotEmpty ? payment.planName : l10n.paymentHistory,
                style: AppText.bodyBold.copyWith(color: AppColors.text, fontSize: 16.sp),
              ),
              Text(
                '$currencySymbol${payment.amount.toStringAsFixed(2)}',
                style: AppText.bodyBold.copyWith(color: AppColors.text, fontSize: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppColors.borderLight, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.invoice}: ${payment.invoiceRef.isNotEmpty ? payment.invoiceRef : '--'}',
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('MMM dd, yyyy').format(payment.createdAt),
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  payment.status.toUpperCase(),
                  style: AppText.small.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
