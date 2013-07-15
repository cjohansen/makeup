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
require "pygments"
require "htmlentities"
require "linguist"

module Makeup
  CodeBlock = Struct.new(:lexer, :code)

  class SyntaxHighlighter
    def initialize
      @entities = HTMLEntities.new
    end

    def highlight(path, code, options = {})
      options[:lexer] ||= lexer(path, code)
      lexer = Pygments::Lexer.find(options[:lexer])
      code = lexer.nil? ? code : Pygments.highlight(code, highlight_options(options))
      CodeBlock.new(lexer && lexer.aliases.first, code)
    rescue MentosError => e
      # "MentosError" is what Pyments.rb raises when an unknown lexer is
      # attempted used
      CodeBlock.new(nil, @entities.encode(code))
    end

    def lexer(path, code = nil, mode = nil)
      self.class.lexer(path, code, mode)
    end

    def self.lexer(path, code = nil, mode = nil)
      lexer = Linguist::Language.detect(path, code, mode)
      lexer && (lexer.aliases.first || lexer.name)
    end

    private
    def highlight_options(options = {})
      options[:options] ||= {}
      options[:options][:nowrap] = true
      options[:options][:encoding] ||= "utf-8"
      options
    end
  end
end
