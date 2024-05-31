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

require 'concurrent/atom'

# Always.
#
# In order to start five threads performing the same piece of code
# over and over again, with a 60-seconds pause between cycles, do this:
#
#  require 'always'
#  a = Always.new(5)
#  a.start(60) do
#    puts 'Hello, world!
#  end
#
# Then, in order stop them all together:
#
#  a.stop
#
# It's possible to get a quick summary of the thread pool, by calling +to_s+.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Yegor Bugayenko
# License:: MIT
class Always
  # The version of the framework.
  VERSION = '0.0.0'

  # Constructor.
  # @param [Integer] total The number of threads to run
  def initialize(total)
    raise "The number of threads (#{total}) must be positive" unless total.positive?

    @total = total
    @on_error = nil
    @threads = []
    @cycles = Concurrent::Atom.new(0)
    @errors = Concurrent::Atom.new(0)
  end

  # What to do when an exception occurs?
  #
  # Call it like this (the +e+ provided is the exception and +i+ is the
  # number of the thread where it occured):
  #
  #  a = Always.new(5)
  #  a.on_error do |e, i|
  #    puts e.message
  #  end
  #
  # If the block that you provided will also throw an error, it will
  # simply be ignored (not logged anywhere, just ignored!)
  # @return [Always] Returns itself
  def on_error(&block)
    @on_error = block
    self
  end

  # Start them all.
  # @param [Integer] pause The delay between cycles, in seconds
  def start(pause = 0)
    raise 'It is running now, call .stop() first' unless @threads.empty?

    (0..@total - 1).each do |i|
      @threads[i] = Thread.new do
        body(i, pause)
        @cycles.swap { |c| c + 1 }
      end
    end
  end

  # Stop them all.
  def stop
    @threads.each(&:terminate)
    @threads = []
  end

  # Represent its internal state as a string.
  # @return [String] Something like "4/230/23", where 4 is the number of running
  #  threads, 230 is the number of successfull loops, and 23 is the number
  #  of failures occured so far.
  def to_s
    "#{@threads.size}/#{@cycles.value}/#{@errors.value}"
  end

  private

  # rubocop:disable Lint/RescueException
  def body(idx, pause)
    loop do
      begin
        yield
      rescue Exception => e
        @errors.swap { |c| c + 1 }
        @on_error&.call(e, idx)
      end
      sleep(pause)
    rescue Exception
      # If we reach this point, we must not even try to
      # do anything. Here we must quietly ignore everything
      # and let the daemon go to the next cycle.
    end
  end
  # rubocop:enable Lint/RescueException
end
