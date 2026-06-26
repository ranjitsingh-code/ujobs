import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/company.dart';
import '../providers/auth_provider.dart';
import '../api/api_endpoints.dart';

class UJobCompanyAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final ValueChanged<Company?>? onCompanySelected;

  const UJobCompanyAutocomplete({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.onCompanySelected,
  });

  @override
  ConsumerState<UJobCompanyAutocomplete> createState() =>
      _UJobCompanyAutocompleteState();
}

class _UJobCompanyAutocompleteState
    extends ConsumerState<UJobCompanyAutocomplete> {
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  Completer<Iterable<Company>>? _completer;
  bool _isLoading = false;

  Future<Iterable<Company>> _search(String query) async {
    if (query.trim().length < 2) {
      return const Iterable<Company>.empty();
    }

    _debounce?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(const Iterable<Company>.empty());
    }

    _completer = Completer<Iterable<Company>>();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) {
        if (!_completer!.isCompleted) _completer!.complete(const Iterable<Company>.empty());
        return;
      }
      setState(() => _isLoading = true);
      try {
        final dio = ref.read(dioClientProvider).dio;
        final res = await dio.get(
          Ep.publicCompanies,
          queryParameters: {'search': query.trim(), 'limit': 10},
        );
        final rawData = res.data as Map<String, dynamic>;
        if (rawData['success'] == true) {
          final data = rawData['data'] as List;
          final companies = data.map((e) => Company.fromJson(e)).toList();
          if (!_completer!.isCompleted) {
            _completer!.complete(companies.isEmpty 
                ? [Company(id: -1, name: 'NO_COMPANY_FOUND')]
                : companies);
          }
        } else {
          if (!_completer!.isCompleted) _completer!.complete(const Iterable<Company>.empty());
        }
      } catch (e) {
        if (!_completer!.isCompleted) _completer!.complete(const Iterable<Company>.empty());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });

    return _completer!.future;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(const Iterable<Company>.empty());
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppText.label.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: AppText.label.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<Company>(
              textEditingController: widget.controller,
              focusNode: _focusNode,
              displayStringForOption: (Company option) => option.name,
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                  textInputAction: TextInputAction.next,
                  style: AppText.body.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppText.body.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    suffixIcon: _isLoading
                        ? UnconstrainedBox(
                            child: SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (widget.onCompanySelected != null) {
                  widget.onCompanySelected!(null);
                }
                return _search(textEditingValue.text);
              },
              onSelected: (Company selection) {
                if (widget.onCompanySelected != null) {
                  widget.onCompanySelected!(selection);
                }
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<Company> onSelected,
                Iterable<Company> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.surface,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200.h,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border),
                        itemBuilder: (BuildContext context, int index) {
                          final Company option = options.elementAt(index);

                          if (option.id == -1 && option.name == 'NO_COMPANY_FOUND') {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              child: Text(
                                'Company not found.',
                                style: AppText.body.copyWith(
                                  color: AppColors.muted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }

                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedBuilding04,
                                    size: 20.r,
                                    color: AppColors.muted,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      option.name,
                                      style: AppText.body.copyWith(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        ),
      ],
    );
  }
}
