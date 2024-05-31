# Runs a Background Loop Forever

[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/always)](http://www.rultor.com/p/yegor256/always)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/always/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/always/actions/workflows/rake.yml)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/always)](http://www.0pdd.com/p?name=yegor256/always)
[![Gem Version](https://badge.fury.io/rb/always.svg)](http://badge.fury.io/rb/always)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/always.svg)](https://codecov.io/github/yegor256/always?branch=master)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/yegor256/always/master/frames)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/always)](https://hitsofcode.com/view/github/yegor256/always)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/always/blob/master/LICENSE.txt)

This simple Ruby gem helps you run a loop forever, in a background thread.

```ruby
# Start five threads with 30-seconds delay between loop cycles
Always.start(5, 30) do
  puts "I'm alive"
end
```

## How to contribute

Read
[these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have
[Ruby](https://www.ruby-lang.org/en/) 3.0+ and
[Bundler](https://bundler.io/) installed. Then:

```bash
bundle update
bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.
