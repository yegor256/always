# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative '../lib/always'
require_relative 'test__helper'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Yegor Bugayenko
# License:: MIT
class TestAlways < Minitest::Test
  def test_simple
    a = Always.new(3)
    a.start do
      raise 'intentionally'
    end
    a.stop
  end

  def test_with_error
    a = Always.new(5)
    failures = 0
    a.on_error { |_e| failures += 1 }.start do
      raise 'intentionally'
    end
    sleep(0.1)
    a.stop
    assert_predicate(failures, :positive?)
  end

  def test_read_backtraces
    max = 5
    a = Always.new(5, max_backtraces: max)
    failures = 0
    a.on_error { |_e| failures += 1 }.start do
      raise 'intentionally'
    end
    sleep(0.1)
    a.stop
    assert_predicate(failures, :positive?)
    assert_equal(max, a.backtraces.size)
  end

  def test_converts_to_string
    n = 6
    a = Always.new(6)
    a.start { sleep(0.01) }
    sleep(0.1)
    threads, cycles, errors = a.to_s.split('/')
    assert_equal(n, threads.to_i)
    assert_predicate(cycles.to_i, :positive?)
    assert_predicate(errors.to_i, :zero?)
    a.stop
  end

  def test_stops_correctly
    a = Always.new(6)
    a.start { sleep(0.01) }
    sleep(0.01)
    a.stop
    assert_equal('0/0/0', a.to_s)
  end

  def test_with_counter
    a = Always.new(1)
    done = 0
    a.start do
      done += 1
    end
    sleep(0.1)
    a.stop
    assert_predicate(done, :positive?)
  end

  def test_with_broken_syntax
    a = Always.new(1)
    failures = 0
    a.on_error { |_e| failures += 1 }.start do
      eval('broken$ruby$syntax')
    end
    sleep(0.1)
    _, _, errors = a.to_s.split('/')
    refute_predicate(errors.to_i, :zero?)
    refute_predicate(failures, :zero?)
    a.stop
  end
end
