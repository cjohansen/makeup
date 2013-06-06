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
require "rouge"
require "htmlentities"

module Makeup
  CodeBlock = Struct.new(:lexer, :code)

  class SyntaxHighlighter
    def initialize
      @entities = HTMLEntities.new
    end

    def highlight(path, code, options = {})
      lx = options[:lexer] || lexer(path, code)
      lexer = Rouge::Lexer.find(lx)
      CodeBlock.new(lexer.tag, Rouge.highlight(code, lx, "html"))
    rescue RuntimeError => e
      # Rouge raises a RuntimeError when an unknown lexer is attempted
      # used
      CodeBlock.new(nil, @entities.encode(code))
    end

    def lexer(path, code = nil)
      self.class.lexer(path.split(".").pop, code)
    end

    def self.lexer(suffix, code = nil)
      return @@lexer_aliases[suffix] if @@lexer_aliases[suffix]
      lexer = Rouge::Lexer.find_fancy(suffix)
      return lexer.class.tag if lexer
      lexer = Rouge::Lexer.find_fancy("guess", code)
      return lexer.class.tag if lexer
      shebang_language(shebang(code)) || suffix
    end

    def self.shebang(code)
      first_line = (code || "").split("\n")[0]
      first_line =~ /^#!/ ? first_line : nil
    end

    def self.shebang_language(shebang)
      shebang = @@lexer_shebangs.find { |s| (shebang || "") =~ s[:pattern] }
      shebang && shebang[:lexer]
    end

    def self.add_lexer_alias(extension, lexer)
      @@lexer_aliases ||= {}
      @@lexer_aliases[extension] = lexer
    end

    def self.add_lexer_shebang(pattern, lexer)
      @@lexer_shebangs ||= []
      @@lexer_shebangs << { :pattern => pattern, :lexer => lexer }
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

Makeup::SyntaxHighlighter.add_lexer_alias("txt", "text")
Makeup::SyntaxHighlighter.add_lexer_alias("ru", "ruby")
Makeup::SyntaxHighlighter.add_lexer_alias("Rakefile", "rb")
Makeup::SyntaxHighlighter.add_lexer_alias("Gemfile", "rb")
Makeup::SyntaxHighlighter.add_lexer_alias("Gemfile.lock", "yaml")
Makeup::SyntaxHighlighter.add_lexer_alias("htm", "html")
Makeup::SyntaxHighlighter.add_lexer_shebang(/\bruby\b/, "rb")
