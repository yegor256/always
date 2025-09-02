# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>=3.2'
  s.name = 'always'
  s.version = '0.0.0'
  s.license = 'MIT'
  s.summary = 'A simple Ruby framework that spins a loop forever, in a background thread'
  s.description =
    'You may need this framework if you have a routine task ' \
    'that must be performed every once in a while, but may raise exceptions ' \
    'which you don\'t want to cause a termination of the entire routine cycle.'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/yegor256/always'
  s.files = `git ls-files | grep -v -E '^(test/|\\.|renovate)'`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_dependency 'concurrent-ruby', '~>1.1'
  s.metadata['rubygems_mfa_required'] = 'true'
end
