# frozen_string_literal: true

# Copyright (c) 2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require_relative '../lib/always'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Yegor Bugayenko
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
    assert(failures.positive?)
  end

  def test_converts_to_string
    n = 6
    a = Always.new(6)
    a.start { sleep(0.01) }
    sleep(0.1)
    threads, cycles, errors = a.to_s.split('/')
    assert_equal(n, threads.to_i)
    assert(cycles.to_i.positive?)
    assert(errors.to_i.zero?)
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
    assert(done.positive?)
  end
end
