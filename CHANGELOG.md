## [0.1.10] - 2023-10-15
- [#10] Refactor implementation to avoid thread safety issues for user inputs

  *Adam Kiczula (@adamkiczula)*

## [0.1.9] - 2023-01-27
- [#6] [#7] Security/Performance fix to vulnerability to DoS attacks.

## [0.1.8] - 2023-01-22
- How to find information on translations on README.
- Drop automatic tests on ruby 2.5 (It still works on it but development gems are failing to build).
- Update dev gems to prepare to test on Ruby 3.1 and 3.2. (mini_racer, rubocop and bundler)
- Fix Style/RedundantStringEscape on frequency_lists.rb.
- Add automated tests for Ruby 3.1 and 3.2.
- Add MFA requirement on release.
- Trim non-production files from final gem.

## [0.1.7] - 2021-06-12
- Ported original specs
- Fix difference found on enumerate_l33t_subs
- Setup to also test against current versions of ruby

## [0.1.6] - 2021-05-28
- Added test methods for compatibility with zxcvbn-js and zxcvbn-ruby.

## [0.1.5] - 2021-05-27
- Fix classification of scoring causing differences between js and ruby.

## [0.1.4] - 2021-05-16

- Bunch of fixes, all example passwords included have same result as js version.
- consistent code style applied.

## [0.1.0] - 2021-05-16

- Initial release
