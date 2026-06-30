import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_dropdown_field.dart';
import '../../core/widgets/ujob_terms_agreement.dart';
import '../../core/widgets/ujob_text_field.dart';

import 'package:dio/dio.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/l10n_extensions.dart';
import '../../core/utils/api_error_parser.dart';
import '../../core/widgets/ujob_auth_links.dart';
import '../../core/widgets/ujob_role_switch_card.dart';
import '../../core/providers/role_provider.dart';
import '../../core/widgets/ujob_toast.dart';

class RegisterEmployerScreen extends ConsumerStatefulWidget {
  const RegisterEmployerScreen({super.key});

  @override
  ConsumerState<RegisterEmployerScreen> createState() =>
      _RegisterEmployerScreenState();
}

class _RegisterEmployerScreenState extends ConsumerState<RegisterEmployerScreen>
    with SingleTickerProviderStateMixin {
  int _step = 1;

  // Step 1
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _acceptedTerms = false;

  // Step 2
  final _companyCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _companySearchFocusNode = FocusNode();
  final _companyResultsScrollController = ScrollController();
  String? _country;
  bool? _isLimitedCompany = true;
  Timer? _companySearchDebounce;
  List<_CompaniesHouseSearchItem> _companySearchResults = [];
  _CompaniesHouseCompanyDetail? _selectedCompanyDetail;
  bool _isSearchingCompanies = false;
  bool _isLoadingCompanyDetail = false;
  String? _companyLookupMessage;
  bool _companySelectionLocked = false;
  int _companySearchRequestId = 0;
  int _companyDetailRequestId = 0;

  bool _loading = false;
  String? _error;

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animCtrl.forward();

    // Rebuild when password changes to update matchValue in confirm field
    _passCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _companyCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _cityCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (final c in [
      _firstCtrl,
      _lastCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmCtrl,
      _companyCtrl,
      _cityCtrl,
      _websiteCtrl,
    ]) {
      c.dispose();
    }
    _companySearchFocusNode.dispose();
    _companyResultsScrollController.dispose();
    _companySearchDebounce?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  void _goStep2() {
    final l10n = context.l10n;
    if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.errorFirstLast);
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      setState(() => _error = l10n.errorValidWorkEmail);
      return;
    }
    if (_passCtrl.text.length < 8) {
      setState(() => _error = l10n.errorPasswordLength);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = l10n.errorPasswordMatch);
      return;
    }
    if (!_acceptedTerms) {
      setState(() => _error = l10n.errorAcceptTerms);
      return;
    }
    setState(() {
      _step = 2;
      _error = null;
    });
    _animCtrl.forward(from: 0);
  }

  void _setTermsAccepted(bool value) {
    setState(() {
      _acceptedTerms = value;
      if (value && _error == context.l10n.errorAcceptTerms) _error = null;
    });
  }

  Future<void> _register() async {
    if (_isLimitedCompany == null) {
      setState(() => _error = context.l10n.selectLimitedCompanyOption);
      return;
    }
    if (_isLimitedCompany == true && _selectedCompanyDetail == null) {
      setState(() => _error = context.l10n.selectCompaniesHouseCompany);
      return;
    }
    if (_isLimitedCompany == false && _companyCtrl.text.trim().isEmpty) {
      setState(() => _error = context.l10n.errorCompanyName);
      return;
    }
    if (_cityCtrl.text.trim().isEmpty || _country == null) {
      setState(() => _error = context.l10n.errorCityCountry);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final dio = ref.read(dioClientProvider).dio;
      final selectedDetail = _selectedCompanyDetail;
      final res = await dio.post(
        Ep.registerEmployer,
        data: {
          'first_name': _firstCtrl.text.trim(),
          'last_name': _lastCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
          'company_name':
              selectedDetail?.companyName ?? _companyCtrl.text.trim(),
          'company_city': _cityCtrl.text.trim(),
          'company_country': _country,
          'company_website': _websiteCtrl.text.trim(),
          'is_non_limited': !(_isLimitedCompany ?? false),
          if (selectedDetail != null) ...{
            'ch_company_number': selectedDetail.companyNumber,
            'ch_company_status': selectedDetail.companyStatus,
            'ch_company_type': selectedDetail.companyType,
          },
        },
      );

      final rawData = res.data as Map<String, dynamic>;
      if (!mounted) return;
      if (rawData['success'] == false) {
        setState(() => _loading = false);
        UJobToast.error(
          context,
          'Registration Failed',
          sub:
              rawData['error']?['message']?.toString() ??
              'Registration failed.',
        );
        return;
      }

      final data = (rawData['data'] ?? rawData) as Map<String, dynamic>;

      final userId =
          data['user_id']?.toString() ??
          data['id']?.toString() ??
          data['user']?['id']?.toString() ??
          '';

      UJobToast.success(context, 'Success', sub: 'Registration Successful!');

      setState(() => _loading = false);
      if (data['requires_otp'] == true) {
        context.go('/otp', extra: userId);
      } else {
        final token = data['accessToken']?.toString() ?? '';
        if (token.isNotEmpty) {
          await ref.read(secureStorageProvider).saveTokens(token, '');
          ref.read(activeRoleProvider.notifier).setRole('employer');
          if (!mounted) return;
        }
        context.go('/employer');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = parseApiError(e);
      UJobToast.error(context, 'Error', sub: msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      UJobToast.error(context, 'Error', sub: 'An unexpected error occurred.');
    }
  }

  void _setLimitedCompany(bool isLimited) {
    _companySearchDebounce?.cancel();
    _companySearchRequestId++;
    _companyDetailRequestId++;
    setState(() {
      _isLimitedCompany = isLimited;
      _error = null;
      _companyLookupMessage = null;
      _companySearchResults = [];
      _isSearchingCompanies = false;
      _isLoadingCompanyDetail = false;
      _selectedCompanyDetail = null;
      _companySelectionLocked = false;
      _companyCtrl.clear();
      if (!isLimited) {
        _cityCtrl.clear();
      }
      if (isLimited && _country == null) {
        _country = 'GB';
      }
    });
    _companySearchFocusNode.unfocus();
  }

  void _onCompaniesHouseQueryChanged(String value) {
    if (_isLimitedCompany != true) return;

    _companySearchDebounce?.cancel();
    final requestId = ++_companySearchRequestId;
    setState(() {
      if (_companySelectionLocked) {
        _companySelectionLocked = false;
      }
      _selectedCompanyDetail = null;
      _companyLookupMessage = null;
    });

    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _companySearchResults = [];
        _isSearchingCompanies = false;
      });
      return;
    }

    _companySearchDebounce = Timer(const Duration(milliseconds: 350), () {
      _searchCompaniesHouse(query, requestId);
    });
  }

  Future<void> _searchCompaniesHouse(String query, int requestId) async {
    if (!mounted ||
        _isLimitedCompany != true ||
        requestId != _companySearchRequestId) {
      return;
    }

    setState(() {
      _isSearchingCompanies = true;
      _companyLookupMessage = null;
    });

    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.get(
        Ep.publicCompaniesHouseSearch,
        queryParameters: {'q': query},
      );
      final raw = res.data as Map<String, dynamic>;
      final data = (raw['data'] as List<dynamic>? ?? [])
          .map((e) => _CompaniesHouseSearchItem.fromJson(e))
          .where((item) => _hasValue(item.companyName))
          .toList();

      if (!mounted ||
          requestId != _companySearchRequestId ||
          _isLimitedCompany != true ||
          _companySelectionLocked) {
        return;
      }
      setState(() {
        _companySearchResults = data;
        _companyLookupMessage = data.isEmpty
            ? (raw['error']?.toString().isNotEmpty == true
                  ? raw['error'].toString()
                  : context.l10n.noCompaniesFound)
            : null;
      });
    } catch (_) {
      if (!mounted ||
          requestId != _companySearchRequestId ||
          _isLimitedCompany != true ||
          _companySelectionLocked) {
        return;
      }
      setState(() {
        _companySearchResults = [];
        _companyLookupMessage = context.l10n.companyDetailsUnavailable;
      });
    } finally {
      if (mounted && requestId == _companySearchRequestId) {
        setState(() => _isSearchingCompanies = false);
      }
    }
  }

  Future<void> _selectCompaniesHouseCompany(
    _CompaniesHouseSearchItem item,
  ) async {
    _companySearchDebounce?.cancel();
    _companySearchRequestId++;
    final detailRequestId = ++_companyDetailRequestId;
    _companySearchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    _companyCtrl.value = TextEditingValue(
      text: item.companyName,
      selection: TextSelection.collapsed(offset: item.companyName.length),
    );
    setState(() {
      _companySearchResults = [];
      _companyLookupMessage = null;
      _isSearchingCompanies = false;
      _isLoadingCompanyDetail = true;
      _selectedCompanyDetail = null;
      _companySelectionLocked = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.get(
        Ep.publicCompaniesHouseCompany(item.companyNumber),
      );
      final raw = res.data as Map<String, dynamic>;
      final detail = _CompaniesHouseCompanyDetail.fromJson(
        raw['data'] as Map<String, dynamic>,
      );

      if (!mounted ||
          detailRequestId != _companyDetailRequestId ||
          _isLimitedCompany != true ||
          !_companySelectionLocked) {
        return;
      }
      final authoritativeName = detail.companyName.trim();
      if (authoritativeName.isNotEmpty) {
        _companyCtrl.value = TextEditingValue(
          text: authoritativeName,
          selection: TextSelection.collapsed(offset: authoritativeName.length),
        );
      }
      setState(() {
        _selectedCompanyDetail = detail;
        if (_cityCtrl.text.trim().isEmpty &&
            detail.registeredAddress.locality != null) {
          _cityCtrl.text = detail.registeredAddress.locality!;
        }
        _country ??= 'GB';
      });
    } on DioException catch (e) {
      if (!mounted || detailRequestId != _companyDetailRequestId) return;
      setState(() {
        _companyLookupMessage = parseApiError(e).isNotEmpty
            ? parseApiError(e)
            : context.l10n.companyDetailsUnavailable;
      });
    } catch (_) {
      if (!mounted || detailRequestId != _companyDetailRequestId) return;
      setState(() {
        _companyLookupMessage = context.l10n.companyDetailsUnavailable;
      });
    } finally {
      if (mounted && detailRequestId == _companyDetailRequestId) {
        setState(() => _isLoadingCompanyDetail = false);
      }
    }
  }

  void _clearCompaniesHouseSelection() {
    _companySearchDebounce?.cancel();
    _companySearchRequestId++;
    _companyDetailRequestId++;
    setState(() {
      _companyCtrl.clear();
      _companySearchResults = [];
      _selectedCompanyDetail = null;
      _companyLookupMessage = null;
      _companySelectionLocked = false;
      _isSearchingCompanies = false;
      _isLoadingCompanyDetail = false;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _companySearchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              step: _step,
              total: 2,
              onBack: _step == 1
                  ? () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/role-picker');
                      }
                    }
                  : () => setState(() {
                      _step = 1;
                      _error = null;
                    }),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previousChildren, ?currentChild],
                ),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _step == 1
                    ? _EmpStep1(
                        key: const ValueKey(1),
                        firstCtrl: _firstCtrl,
                        lastCtrl: _lastCtrl,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        confirmCtrl: _confirmCtrl,
                        acceptedTerms: _acceptedTerms,
                        onTermsChanged: _setTermsAccepted,
                        error: _error,
                        onContinue: _goStep2,
                        onSignIn: () => context.go('/login', extra: 'employer'),
                        onOtherRole: () => context.go('/register/seeker'),
                      )
                    : _EmpStep2(
                        key: const ValueKey(2),
                        companyCtrl: _companyCtrl,
                        cityCtrl: _cityCtrl,
                        country: _country,
                        isLimitedCompany: _isLimitedCompany,
                        companySearchResults: _companySearchResults,
                        selectedCompanyDetail: _selectedCompanyDetail,
                        isSearchingCompanies: _isSearchingCompanies,
                        isLoadingCompanyDetail: _isLoadingCompanyDetail,
                        companyLookupMessage: _companyLookupMessage,
                        companySearchFocusNode: _companySearchFocusNode,
                        companyResultsScrollController:
                            _companyResultsScrollController,
                        onLimitedCompanyChanged: _setLimitedCompany,
                        onCompanyQueryChanged: _onCompaniesHouseQueryChanged,
                        onCompanySelected: _selectCompaniesHouseCompany,
                        onCompanyCleared: _clearCompaniesHouseSelection,
                        onCountryChanged: (value) =>
                            setState(() => _country = value),
                        websiteCtrl: _websiteCtrl,
                        error: _error,
                        loading: _loading,
                        onRegister: _register,
                        onSignIn: () => context.go('/login', extra: 'employer'),
                        onOtherRole: () => context.go('/register/seeker'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmpStep1 extends StatelessWidget {
  final TextEditingController firstCtrl,
      lastCtrl,
      emailCtrl,
      passCtrl,
      confirmCtrl;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final String? error;
  final VoidCallback onContinue, onSignIn, onOtherRole;

  const _EmpStep1({
    super.key,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.error,
    required this.onContinue,
    required this.onSignIn,
    required this.onOtherRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.employerAccountTitle, style: AppText.heading2),
          SizedBox(height: 4.h),
          Text(
            l10n.employerAccountSub,
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: UJobTextField(
                  label: l10n.firstName,
                  hint: l10n.firstNameHint,
                  controller: firstCtrl,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: UJobTextField(
                  label: l10n.lastName,
                  hint: l10n.lastNameHint,
                  controller: lastCtrl,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.workEmailLabel,
            hint: l10n.workEmailHint,
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            isRequired: true,
            isEmail: true,
          ),
          SizedBox(height: 16.h),

          UJobTextField(
            label: l10n.password,
            hint: l10n.passwordCreateHint,
            controller: passCtrl,
            isPassword: true,
            textInputAction: TextInputAction.next,
            isRequired: true,
            isSecurePassword: true,
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.confirmPassword,
            hint: l10n.confirmPasswordHint,
            controller: confirmCtrl,
            isPassword: true,
            textInputAction: TextInputAction.done,
            isRequired: true,
            isConfirmPassword: true,
            matchValue: passCtrl.text,
          ),
          SizedBox(height: 12.h),
          UJobTermsAgreement(
            value: acceptedTerms,
            onChanged: onTermsChanged,
            onTermsTap: () => context.push('/pages/terms'),
            onPrivacyTap: () => context.push('/pages/privacy-policy'),
          ),
          if (error != null) ...[SizedBox(height: 16.h), _ErrorBox(error!)],
          SizedBox(height: 24.h),
          UJobButton(label: l10n.continueButton, onTap: onContinue),
          SizedBox(height: 16.h),
          UJobAuthLinks(
            primaryText: l10n.alreadyHaveAccount,
            primaryLinkText: l10n.logIn,
            onPrimaryTap: onSignIn,
          ),
          SizedBox(height: 24.h),
          UJobRoleSwitchCard(
            text: l10n.lookingForJob,
            linkText: l10n.registerAsJobSeeker,
            icon: HugeIcons.strokeRoundedJobSearch,
            onTap: onOtherRole,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _EmpStep2 extends StatelessWidget {
  final TextEditingController companyCtrl, cityCtrl, websiteCtrl;
  final String? country;
  final bool? isLimitedCompany;
  final List<_CompaniesHouseSearchItem> companySearchResults;
  final _CompaniesHouseCompanyDetail? selectedCompanyDetail;
  final bool isSearchingCompanies;
  final bool isLoadingCompanyDetail;
  final String? companyLookupMessage;
  final FocusNode companySearchFocusNode;
  final ScrollController companyResultsScrollController;
  final ValueChanged<bool> onLimitedCompanyChanged;
  final ValueChanged<String> onCompanyQueryChanged;
  final ValueChanged<_CompaniesHouseSearchItem> onCompanySelected;
  final VoidCallback onCompanyCleared;
  final ValueChanged<String?> onCountryChanged;
  final String? error;
  final bool loading;
  final VoidCallback onRegister, onSignIn, onOtherRole;

  const _EmpStep2({
    super.key,
    required this.companyCtrl,
    required this.cityCtrl,
    required this.country,
    required this.isLimitedCompany,
    required this.companySearchResults,
    required this.selectedCompanyDetail,
    required this.isSearchingCompanies,
    required this.isLoadingCompanyDetail,
    required this.companyLookupMessage,
    required this.companySearchFocusNode,
    required this.companyResultsScrollController,
    required this.onLimitedCompanyChanged,
    required this.onCompanyQueryChanged,
    required this.onCompanySelected,
    required this.onCompanyCleared,
    required this.onCountryChanged,
    required this.websiteCtrl,
    required this.error,
    required this.loading,
    required this.onRegister,
    required this.onSignIn,
    required this.onOtherRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canSubmit =
        isLimitedCompany != null &&
        cityCtrl.text.trim().isNotEmpty &&
        country != null &&
        ((isLimitedCompany == true && selectedCompanyDetail != null) ||
            (isLimitedCompany == false && companyCtrl.text.trim().isNotEmpty));
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.companyDetailsTitle, style: AppText.heading2),
          SizedBox(height: 4.h),
          Text(
            l10n.companyDetailsSub,
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 24.h),
          _LimitedCompanyChoice(
            label: l10n.limitedCompanyQuestion,
            value: isLimitedCompany,
            yesLabel: l10n.yesOption,
            noLabel: l10n.noOption,
            onChanged: onLimitedCompanyChanged,
          ),
          SizedBox(height: 16.h),
          if (isLimitedCompany == true) ...[
            _CompaniesHouseSearchSection(
              controller: companyCtrl,
              label: l10n.companiesHouseSearchLabel,
              hint: l10n.companiesHouseSearchHint,
              isSearching: isSearchingCompanies,
              results: companySearchResults,
              message: companyLookupMessage,
              focusNode: companySearchFocusNode,
              scrollController: companyResultsScrollController,
              onChanged: onCompanyQueryChanged,
              onSelected: onCompanySelected,
              isSelected:
                  selectedCompanyDetail != null || isLoadingCompanyDetail,
              onClear: onCompanyCleared,
            ),
            if (isLoadingCompanyDetail) ...[
              SizedBox(height: 12.h),
              _LookupStatusCard(message: l10n.searchingCompanies),
            ],
            if (selectedCompanyDetail != null) ...[
              SizedBox(height: 12.h),
              _CompaniesHouseVerifiedCard(detail: selectedCompanyDetail!),
            ],
            SizedBox(height: 16.h),
          ] else if (isLimitedCompany == false) ...[
            UJobTextField(
              label: l10n.companyNameLabel,
              hint: l10n.companyNameHint,
              controller: companyCtrl,
              textInputAction: TextInputAction.next,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
          ],
          UJobTextField(
            label: l10n.city,
            hint: l10n.cityHint,
            controller: cityCtrl,
            textInputAction: TextInputAction.next,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          UJobCountryDropdown(
            value: country,
            onChanged: onCountryChanged,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.websiteLabel,
            hint: l10n.websiteHint,
            controller: websiteCtrl,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          if (error != null) ...[SizedBox(height: 16.h), _ErrorBox(error!)],
          SizedBox(height: 24.h),
          UJobButton(
            label: l10n.createEmployerAccount,
            onTap: canSubmit ? onRegister : null,
            isLoading: loading,
          ),
          SizedBox(height: 16.h),
          UJobAuthLinks(
            primaryText: l10n.alreadyHaveAccount,
            primaryLinkText: l10n.logIn,
            onPrimaryTap: onSignIn,
          ),
          SizedBox(height: 24.h),
          UJobRoleSwitchCard(
            text: l10n.lookingForJob,
            linkText: l10n.registerAsJobSeeker,
            icon: HugeIcons.strokeRoundedJobSearch,
            onTap: onOtherRole,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _LimitedCompanyChoice extends StatelessWidget {
  final String label;
  final bool? value;
  final String yesLabel;
  final String noLabel;
  final ValueChanged<bool> onChanged;

  const _LimitedCompanyChoice({
    required this.label,
    required this.value,
    required this.yesLabel,
    required this.noLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: AppText.label.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _ChoiceTile(
                label: yesLabel,
                isSelected: value == true,
                onTap: () => onChanged(true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ChoiceTile(
                label: noLabel,
                isSelected: value == false,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.bodyBold.copyWith(
              color: isSelected ? AppColors.primary : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompaniesHouseSearchSection extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isSearching;
  final List<_CompaniesHouseSearchItem> results;
  final String? message;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final ValueChanged<String> onChanged;
  final ValueChanged<_CompaniesHouseSearchItem> onSelected;
  final bool isSelected;
  final VoidCallback onClear;

  const _CompaniesHouseSearchSection({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isSearching,
    required this.results,
    required this.message,
    required this.focusNode,
    required this.scrollController,
    required this.onChanged,
    required this.onSelected,
    required this.isSelected,
    required this.onClear,
  });

  @override
  State<_CompaniesHouseSearchSection> createState() =>
      _CompaniesHouseSearchSectionState();
}

class _CompaniesHouseSearchSectionState
    extends State<_CompaniesHouseSearchSection> {
  bool get _shouldShowResults =>
      widget.results.isNotEmpty &&
      !widget.isSelected &&
      widget.focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _CompaniesHouseSearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildResultsList(BuildContext context) {
    final rowHeight = 64.h;
    final visibleResultCount = widget.results.length > 5
        ? 5
        : widget.results.length;
    final resultsHeight = visibleResultCount * rowHeight;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SizedBox(
        height: resultsHeight,
        child: ClipRRect(
          borderRadius: AppRadius.md,
          child: RawScrollbar(
            controller: widget.scrollController,
            thumbVisibility: widget.results.length > 5,
            trackVisibility: widget.results.length > 5,
            interactive: true,
            thickness: 3.w,
            radius: Radius.circular(999.r),
            thumbColor: AppColors.primary.withValues(alpha: 0.7),
            trackColor: AppColors.borderLight,
            trackBorderColor: Colors.transparent,
            mainAxisMargin: 6.h,
            crossAxisMargin: 3.w,
            child: ListView.builder(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              itemExtent: rowHeight,
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final item = widget.results[index];
                return Material(
                  color: AppColors.surface,
                  child: InkWell(
                    onTap: () => widget.onSelected(item),
                    child: Container(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        14.w,
                        8.h,
                        12.w,
                        8.h,
                      ),
                      decoration: BoxDecoration(
                        border: index == widget.results.length - 1
                            ? null
                            : Border(
                                bottom: BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.companyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyBold.copyWith(
                                    color: AppColors.text,
                                    height: 1.2,
                                  ),
                                ),
                                if (_hasValue(item.companyNumber)) ...[
                                  SizedBox(height: 3.h),
                                  Text(
                                    item.companyNumber,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.small.copyWith(
                                      color: AppColors.muted2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (_hasValue(item.companyStatus)) ...[
                            SizedBox(width: 8.w),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 72.w),
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: _StatusChip(
                                  status: item.companyStatus,
                                  maxWidth: 72.w,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppText.label.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: AppText.label.copyWith(color: AppColors.error),
              ),
              TextSpan(
                text: ' (${widget.hint})',
                style: AppText.small.copyWith(
                  color: AppColors.muted2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          readOnly: widget.isSelected,
          textInputAction: TextInputAction.next,
          onChanged: widget.onChanged,
          cursorColor: AppColors.text,
          style: AppText.body.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppText.body.copyWith(color: AppColors.muted2),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            suffixIcon: widget.isSelected
                ? IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: widget.onClear,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.muted,
                      size: 20.r,
                    ),
                  )
                : widget.isSearching
                ? Padding(
                    padding: EdgeInsets.all(14.r),
                    child: SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        if (_shouldShowResults) _buildResultsList(context),
        if (widget.results.isEmpty &&
            widget.message != null &&
            widget.message!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _LookupStatusCard(message: widget.message!),
        ],
      ],
    );
  }
}

class _LookupStatusCard extends StatelessWidget {
  final String message;

  const _LookupStatusCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        message,
        style: AppText.small.copyWith(color: AppColors.muted),
      ),
    );
  }
}

class _CompaniesHouseVerifiedCard extends StatelessWidget {
  final _CompaniesHouseCompanyDetail detail;

  const _CompaniesHouseVerifiedCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final companyName = detail.companyName.trim();
    final detailItems = <MapEntry<String, String>>[
      if (_hasValue(companyName)) MapEntry(l10n.companyNameLabel, companyName),
      if (_hasValue(detail.companyNumber))
        MapEntry(l10n.companyNumberLabel, detail.companyNumber),
      if (_hasValue(detail.companyStatus))
        MapEntry(l10n.statusLabel, _humanizeSlug(detail.companyStatus)),
      if (_hasValue(detail.companyType))
        MapEntry(l10n.companyTypeLabel, _humanizeSlug(detail.companyType)),
      if (_hasValue(detail.dateOfCreation))
        MapEntry(l10n.incorporatedLabel, _formatChDate(detail.dateOfCreation!)),
      if (_hasValue(detail.jurisdiction))
        MapEntry(l10n.jurisdictionLabel, _humanizeSlug(detail.jurisdiction!)),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBF4),
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: AppRadius.md.topLeft,
                topRight: AppRadius.md.topRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: AppColors.success,
                    size: 14.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    l10n.companiesHouseVerified,
                    style: AppText.bodyBold.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detailItems.isNotEmpty)
                  Wrap(
                    spacing: 14.w,
                    runSpacing: 14.h,
                    children: detailItems
                        .map(
                          (entry) => SizedBox(
                            width: 150.w,
                            child: _CompanyInfoField(
                              label: entry.key,
                              value: entry.value,
                              isStatus:
                                  entry.key == l10n.statusLabel &&
                                  _hasValue(detail.companyStatus),
                              statusValue: detail.companyStatus,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                if (detail.registeredAddress.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _CompanyInfoField(
                    label: l10n.registeredAddressLabel,
                    value: detail.registeredAddress.formattedAddress,
                    fullWidth: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoField extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final String? statusValue;
  final bool fullWidth;

  const _CompanyInfoField({
    required this.label,
    required this.value,
    this.isStatus = false,
    this.statusValue,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedLabel = label.replaceAll('*', '').trim().toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          normalizedLabel,
          style: AppText.small.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: 4.h),
        if (isStatus && _hasValue(statusValue))
          _StatusChip(
            status: statusValue!,
            maxWidth: fullWidth ? double.infinity : 96.w,
            compact: true,
          )
        else
          Text(
            value,
            style: AppText.body.copyWith(
              color: AppColors.text2,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final double? maxWidth;
  final bool compact;

  const _StatusChip({
    required this.status,
    this.maxWidth,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9.w : 10.w,
          vertical: compact ? 4.h : 5.h,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Text(
          _humanizeSlug(status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: compact ? 10.5.sp : 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int step, total;
  final VoidCallback onBack;
  const _TopBar({
    required this.step,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
    child: Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 20.r,
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.pill,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: step / total,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.authGradient,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          '$step/$total',
          style: AppText.small.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: AppColors.errorBg,
      borderRadius: AppRadius.md,
    ),
    child: Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedAlert01,
          color: AppColors.error,
          size: 16.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            message,
            style: AppText.small.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}

class _CompaniesHouseSearchItem {
  final String companyNumber;
  final String companyName;
  final String companyStatus;

  const _CompaniesHouseSearchItem({
    required this.companyNumber,
    required this.companyName,
    required this.companyStatus,
  });

  factory _CompaniesHouseSearchItem.fromJson(Map<String, dynamic> json) {
    final companyName = _firstJsonValue(json, const [
      'company_name',
      'companyName',
      'title',
      'name',
    ]);
    return _CompaniesHouseSearchItem(
      companyNumber: _firstJsonValue(json, const [
        'company_number',
        'companyNumber',
        'number',
      ]),
      companyName: companyName,
      companyStatus: _firstJsonValue(json, const [
        'company_status',
        'companyStatus',
        'status',
      ]),
    );
  }
}

class _CompaniesHouseCompanyDetail {
  final String companyNumber;
  final String companyName;
  final String companyStatus;
  final String companyType;
  final String? dateOfCreation;
  final String? jurisdiction;
  final _CompaniesHouseAddress registeredAddress;

  const _CompaniesHouseCompanyDetail({
    required this.companyNumber,
    required this.companyName,
    required this.companyStatus,
    required this.companyType,
    required this.registeredAddress,
    this.dateOfCreation,
    this.jurisdiction,
  });

  factory _CompaniesHouseCompanyDetail.fromJson(Map<String, dynamic> json) {
    return _CompaniesHouseCompanyDetail(
      companyNumber: _firstJsonValue(json, const [
        'company_number',
        'companyNumber',
        'number',
      ]),
      companyName: _firstJsonValue(json, const [
        'company_name',
        'companyName',
        'title',
        'name',
      ]),
      companyStatus: _firstJsonValue(json, const [
        'company_status',
        'companyStatus',
        'status',
      ]),
      companyType: _firstJsonValue(json, const [
        'company_type',
        'companyType',
        'type',
      ]),
      dateOfCreation: json['date_of_creation']?.toString().trim(),
      jurisdiction: json['jurisdiction']?.toString().trim(),
      registeredAddress: _CompaniesHouseAddress.fromJson(
        json['registered_office_address'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class _CompaniesHouseAddress {
  final String? addressLine1;
  final String? addressLine2;
  final String? locality;
  final String? region;
  final String? postalCode;
  final String? country;

  const _CompaniesHouseAddress({
    this.addressLine1,
    this.addressLine2,
    this.locality,
    this.region,
    this.postalCode,
    this.country,
  });

  factory _CompaniesHouseAddress.fromJson(Map<String, dynamic> json) {
    return _CompaniesHouseAddress(
      addressLine1: json['address_line_1']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      locality: json['locality']?.toString(),
      region: json['region']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString(),
    );
  }

  bool get isNotEmpty => [
    addressLine1,
    addressLine2,
    locality,
    region,
    postalCode,
    country,
  ].any((e) => e != null && e.trim().isNotEmpty);

  String get formattedAddress => [
    addressLine1,
    addressLine2,
    locality,
    region,
    postalCode,
    country,
  ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
}

String _formatChDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

String _humanizeSlug(String value) {
  return value
      .replaceAll('-', ' ')
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _firstJsonValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

Color _statusColor(String status) {
  final normalized = status.trim().toLowerCase();
  switch (normalized) {
    case 'active':
      return AppColors.success;
    case 'dissolved':
    case 'liquidation':
    case 'closed':
    case 'struck off':
      return AppColors.error;
    default:
      return AppColors.warning;
  }
}
