import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("bodySm", "caption")

old_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

# Actually, the original file has:
#                 ],
#               ),
#             ),
#           ],
#         ),
#       ),
#     );

old_end2 = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_end2 = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
    );
  }"""

text = text.replace(old_end2, new_end2)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
