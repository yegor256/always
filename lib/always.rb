# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'concurrent/atom'
require 'securerandom'

# Always.
#
# In order to start five threads performing the same piece of code
# over and over again, with a 60-seconds pause between cycles, do this:
#
#  require 'always'
#  a = Always.new(5) do
#    puts 'Hello, world!'
#  end
#  a.start!(60)
#
# Then, in order to stop them all together:
#
#  a.stop!
#
# It's possible to get a quick summary of the thread pool, by calling +to_s+.
# The result will be a +"T/C/E"+ string, where +T+ is the total number of
# currently running threads, +C+ is the total number of all cycles
# so far, and +E+ is the total number of all errors seen so far.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2026 Yegor Bugayenko
# License:: MIT
class Always
  # Get the array of most recent exception backtraces.
  # @return [Array<Exception>] The array of exceptions caught
  # @example
  #  a = Always.new(5, max_backtraces: 10)
  #  a.start { raise 'Oops' }
  #  sleep 1
  #  puts a.backtraces.size # => number of exceptions caught
  attr_reader :backtraces

  # The version of the framework.
  VERSION = '0.0.0'

  # Constructor.
  # @param [Integer] total The number of threads to run
  # @param [Integer] max_backtraces How many backtraces to keep in memory?
  # @param [Block] block The block to execute
  def initialize(total, max_backtraces: 32, name: "always-#{SecureRandom.hex(4)}", &block)
    raise "The number of threads (#{total}) must be positive" unless total.positive?

    @total = total
    @block = block
    @on_error = nil
    @name = name
    @threads = []
    @backtraces = []
    @cycles = Concurrent::Atom.new(0)
    @errors = Concurrent::Atom.new(0)
    @max_backtraces = max_backtraces
  end

  # What to do when an exception occurs?
  #
  # Call it like this (the +e+ provided is the exception and +i+ is the
  # number of the thread where it occurred):
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

  # Start them all and let them run forever (until the +stop+ method is called).
  # @param [Integer] pause The delay between cycles, in seconds
  def start!(pause = 0)
    raise 'It is running now, call .stop() first' unless @threads.empty?

    (0..(@total - 1)).each do |i|
      t =
        Thread.new do
          body(pause)
        end
      t.name = "#{@name}-#{i + 1}"
      @threads[i] = t
    end
  end

  # Stop them all.
  def stop!
    raise 'It is not running now, call .start() first' if @threads.empty?

    @threads.delete_if do |t|
      t.kill
      sleep(0.001) while t.alive?
      true
    end
    @cycles.swap { |_| 0 }
    @errors.swap { |_| 0 }
  end

  # Represent its internal state as a string.
  # @return [String] Something like "4/230/23", where 4 is the number of running
  #  threads, 230 is the number of successful loops, and 23 is the number
  #  of failures occurred so far.
  # @example
  #  a = Always.new(5)
  #  a.start(60) { puts 'Working...' }
  #  puts a.to_s # => "5/42/3"
  def to_s
    "#{@threads.size}/#{@cycles.value}/#{@errors.value}"
  end

  private

  # rubocop:disable Lint/RescueException
  def body(pause)
    loop do
      one
      @cycles.swap { |c| c + 1 }
      sleep(pause) unless pause.zero?
    rescue Exception
      # If we reach this point, we must not even try to
      # do anything. Here we must quietly ignore everything
      # and let the daemon go to the next cycle.
    end
  end
  # rubocop:enable Lint/RescueException

  # rubocop:disable Lint/RescueException
  def one
    @block.call
  rescue Exception => e
    @errors.swap { |c| c + 1 }
    @backtraces << e
    @backtraces.shift if @backtraces.size > @max_backtraces
    @on_error&.call(e, Thread.current.object_id)
  end
  # rubocop:enable Lint/RescueException
end
