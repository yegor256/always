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

# Always.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Yegor Bugayenko
# License:: MIT
class Always
  # The version of the framework.
  VERSION = '0.0.1'

  # Constructor.
  def initialize(total, pause = 0)
    @total = total
    @pause = pause
    @on_error = nil
    @threads = []
  end

  # What to do when an exception occurs?
  def on_error(&block)
    @on_error = block
  end

  def start
    (0..@total - 1).each do |i|
      @threads[i] = Thread.new do
        body(i)
      end
    end
  end

  def stop
    @threads.each(&:terminate)
  end

  private

  # rubocop:disable Lint/RescueException
  def body(idx)
    loop do
      begin
        yield
      rescue Exception => e
        @on_error&.call(e, idx)
      end
      sleep(@pause)
    rescue Exception
      # If we reach this point, we must not even try to
      # do anything. Here we must quietly ignore everything
      # and let the daemon go to the next cycle.
    end
  end
  # rubocop:enable Lint/RescueException
end
