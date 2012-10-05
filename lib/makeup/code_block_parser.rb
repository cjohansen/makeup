# encoding: utf-8
# --
# The MIT License (MIT)
#
# Copyright (C) 2012 Gitorious AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

module Makeup
  class CodeBlockParser
    attr_reader :lines

    def self.parse(markup, &block)
      new(markup).parse(&block)
    end

    def initialize(markup)
      @lines = markup.split("\n")
      @current_code_bock = nil
    end

    def parse(&block)
      result = []

      while line = @lines.shift
        if closes_code_block?(line)
          result << block.call(*close_active_code_block)
        elsif active_code_block?
          append_active_code_block(line)
        elsif starts_code_block?(line)
          start_code_block(line)
        else
          result << line
        end
      end

      result.join("\n")
    end

    def active_code_block?
      !@current_code_bock.nil?
    end

    def starts_code_block?(line)
      line.match(/^```.*/)
    end

    def closes_code_block?(line)
      active_code_block? && line == "```"
    end

    def start_code_block(line)
      m = line.match(/```([^\s]+)/)
      @current_code_bock = [m && m[1], []]
    end

    def append_active_code_block(line)
      @current_code_bock[1] << line
    end

    def close_active_code_block
      lexer = @current_code_bock[0]
      code = @current_code_bock[1].join("\n")
      @current_code_bock = nil
      [lexer, code]
    end
  end
end
