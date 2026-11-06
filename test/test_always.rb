# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'timeout'
require_relative '../lib/always'
require_relative 'test__helper'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2026 Yegor Bugayenko
# License:: MIT
class TestAlways < Minitest::Test
  def test_simple
    a =
      Always.new(3) do
        raise(StandardError, 'intentionally')
      end
    a.start!
    a.stop!
  end

  def test_threads_have_names
    gate = Queue.new
    names = Queue.new
    total = 3
    a =
      Always.new(total, name: 'foo') do
        gate.pop
        names << Thread.current.name
        Thread.stop
      end
    a.start!
    total.times { gate << true }
    actual = Timeout.timeout(10) { Array.new(total) { names.pop } }
    assert_equal(total, actual.uniq.size)
    total.times do |i|
      assert_includes(actual, "foo-#{i + 1}")
    end
  ensure
    a.stop!
  end

  def test_with_error
    a =
      Always.new(5) do
        raise(StandardError, 'intentionally')
      end
    failures = 0
    a.on_error { |_e| failures += 1 }
    a.start!
    sleep(0.1)
    a.stop!
    assert_predicate(failures, :positive?)
  end

  def test_with_failing_handler
    a = Always.new(1) { raise(StandardError, 'task failed') }
    failures = 0
    a.on_error do
      failures += 1
      raise(StandardError, 'handler failed') if failures == 1
    end
    pauses = []
    a.define_singleton_method(:sleep) do |pause|
      pauses << pause
      throw(:finished)
    end
    catch(:finished) { a.__send__(:body, 60) }
    assert_equal(1, failures)
    assert_equal([60], pauses)
    assert_equal('0/1/1', a.to_s)
  end

  def test_read_backtraces
    max = 5
    a =
      Always.new(5, max_backtraces: max) do
        raise(StandardError, 'intentionally')
      end
    failures = 0
    a.on_error { |_e| failures += 1 }.start!
    sleep(0.1)
    a.stop!
    assert_predicate(failures, :positive?)
    assert_equal(max, a.backtraces.size)
  end

  def test_converts_to_string
    a = Always.new(6) { sleep(0.01) }
    a.start!
    sleep(0.1)
    threads, cycles, errors = a.to_s.split('/')
    assert_equal(6, Integer(threads, 10))
    assert_predicate(Integer(cycles, 10), :positive?)
    assert_predicate(Integer(errors, 10), :zero?)
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
    refute_predicate(Integer(errors, 10), :zero?)
    refute_predicate(failures, :zero?)
    a.stop!
  end
end
