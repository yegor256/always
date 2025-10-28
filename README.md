# Runs a Background Loop Forever

[![DevOps By Rultor.com](https://www.rultor.com/b/yegor256/always)](https://www.rultor.com/p/yegor256/always)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/always/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/always/actions/workflows/rake.yml)
[![PDD status](https://www.0pdd.com/svg?name=yegor256/always)](https://www.0pdd.com/p?name=yegor256/always)
[![Gem Version](https://badge.fury.io/rb/always.svg)](https://badge.fury.io/rb/always)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/always.svg)](https://codecov.io/github/yegor256/always?branch=master)
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://rubydoc.info/github/yegor256/always/master/frames)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/always)](https://hitsofcode.com/view/github/yegor256/always)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/always/blob/master/LICENSE.txt)

This simple Ruby gem helps you run a loop forever, in a background thread.

```ruby
require 'always'
# Prepare, with five threads and a block:
a = Always.new(5) do
  puts "I'm alive"
end
# Start them all together spinning forever with 30-seconds delay between cycles:
a.start!(30)
# Stop them all together:
a.stop!
```

You may be interested to get the backtraces of the exceptions that
happened most recently:

```ruby
# Keep the last 10 error backtraces in memory:
a = Always.new(5, max_backtraces: 10)
# Set an error handler:
a.on_error do |exception, thread_id|
  puts "Error in thread #{thread_id}: #{exception.message}"
end
# Start them:
a.start!
# Retrieve the backtraces:
p a.backtraces
```

That's it.

## How to contribute

Read
[these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure your build is green before you contribute
your pull request. You will need to have
[Ruby](https://www.ruby-lang.org/en/) 3.0+ and
[Bundler](https://bundler.io/) installed. Then:

```bash
bundle update
bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.
