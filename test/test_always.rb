# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'concurrent/set'
require_relative '../lib/always'
require_relative 'test__helper'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Yegor Bugayenko
# License:: MIT
class TestAlways < Minitest::Test
  def test_simple
    a = Always.new(3) do
      raise 'intentionally'
    end
    a.start!
    a.stop!
  end

  def test_threads_have_names
    names = Concurrent::Set.new
    total = 3
    a =
      Always.new(total, name: 'foo') do
        names.add(Thread.current.name)
      end
    a.on_error { |e| puts e }
    a.start!
    sleep(0.1)
    a.stop!
    assert_equal(total, names.size)
    total.times do |i|
      assert_includes(names, "foo-#{i + 1}")
    end
  end

  def test_with_error
    a =
      Always.new(5) do
        raise 'intentionally'
      end
    failures = 0
    a.on_error { |_e| failures += 1 }
    a.start!
    sleep(0.1)
    a.stop!
    assert_predicate(failures, :positive?)
  end

  def test_read_backtraces
    max = 5
    a =
      Always.new(5, max_backtraces: max) do
        raise 'intentionally'
      end
    failures = 0
    a.on_error { |_e| failures += 1 }.start!
    sleep(0.1)
    a.stop!
    assert_predicate(failures, :positive?)
    assert_equal(max, a.backtraces.size)
  end

  def test_converts_to_string
    n = 6
    a = Always.new(6) { sleep(0.01) }
    a.start!
    sleep(0.1)
    threads, cycles, errors = a.to_s.split('/')
    assert_equal(n, threads.to_i)
    assert_predicate(cycles.to_i, :positive?)
    assert_predicate(errors.to_i, :zero?)
    a.stop!
  end

  def test_stops_correctly
    a = Always.new(6) { sleep(0.01) }
    a.start!
    sleep(0.01)
    a.stop!
    assert_equal('0/0/0', a.to_s)
  end

  def test_with_counter
    done = 0
    a =
      Always.new(1) do
        done += 1
      end
    a.start!
    sleep(0.1)
    a.stop!
    assert_predicate(done, :positive?)
  end

  def test_with_broken_syntax
    a =
      Always.new(1) do
        eval('broken$ruby$syntax')
      end
    failures = 0
    a.on_error { |_e| failures += 1 }.start!
    sleep(0.1)
    _, _, errors = a.to_s.split('/')
    refute_predicate(errors.to_i, :zero?)
    refute_predicate(failures, :zero?)
    a.stop!
  end
end
