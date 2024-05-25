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

require 'judges'

# Returns a decorated global factbase, which only touches facts once
def once(fb, judge: $judge)
  Judges::Once.new(fb, judge)
end

# Runs only once.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Yegor Bugayenko
# License:: MIT
class Judges::Once
  def initialize(fb, func)
    @fb = fb
    @func = func
  end

  def query(expr)
    expr = "(and #{expr} (not (eq seen '#{@func}')))"
    After.new(@fb.query(expr), @func)
  end

  def insert
    @fb.insert
  end

  # What happens after a fact is processed.
  class After
    def initialize(query, func)
      @query = query
      @func = func
    end

    def each
      return to_enum(__method__) unless block_given?
      @query.each do |f|
        yield f
        f.seen = @func
      end
    end
  end
end
