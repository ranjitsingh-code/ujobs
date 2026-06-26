import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';
import '../api/dio_client.dart';
import 'auth_provider.dart';

class FeatureFlags {
  final bool otpLogin;
  final bool otpSignup;
  final bool companiesHouse;
  final bool jobApprovalRequired;
  final bool plansWallet;
  final bool stripe;
  final bool extraApplyMethods;
  final bool chat;

  const FeatureFlags({
    this.otpLogin = false,
    this.otpSignup = false,
    this.companiesHouse = false,
    this.jobApprovalRequired = false,
    this.plansWallet = false,
    this.stripe = false,
    this.extraApplyMethods = false,
    this.chat = false,
  });

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      otpLogin: json['otp_login'] ?? false,
      otpSignup: json['otp_signup'] ?? false,
      companiesHouse: json['companies_house'] ?? false,
      jobApprovalRequired: json['job_approval_required'] ?? false,
      plansWallet: json['plans_wallet'] ?? false,
      stripe: json['stripe'] ?? false,
      extraApplyMethods: json['extra_apply_methods'] ?? false,
      chat: json['chat'] ?? false,
    );
  }
}

class FeatureFlagsNotifier extends StateNotifier<AsyncValue<FeatureFlags>> {
  final DioClient _dioClient;

  FeatureFlagsNotifier(this._dioClient) : super(const AsyncValue.loading()) {
    fetchFeatureFlags();
  }

  Future<void> fetchFeatureFlags() async {
    try {
      final response = await _dioClient.dio.get(Ep.employerFeatureFlags);
      final data = response.data['data'] as Map<String, dynamic>;
      state = AsyncValue.data(FeatureFlags.fromJson(data));
    } catch (e, st) {
      // Graceful fallback if API fails
      state = AsyncValue.data(const FeatureFlags());
    }
  }
}

final featureFlagsProvider = StateNotifierProvider<FeatureFlagsNotifier, AsyncValue<FeatureFlags>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FeatureFlagsNotifier(dioClient);
});
