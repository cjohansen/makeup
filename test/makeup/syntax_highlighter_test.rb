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
require "test_helper"
require "makeup/syntax_highlighter"

describe Makeup::SyntaxHighlighter do
  include Makeup::Html
  before { @highlighter = Makeup::SyntaxHighlighter.new }

  def highlight(path, code)
    @highlighter.highlight(path, code).code
  end

  describe "#highlight" do
    it "returns code and lexer name" do
      block = @highlighter.highlight("file.rb", "class File;")

      assert_match "<span class=\"k\">class</span>", block.code
      assert_equal "rb", block.lexer
    end

    it "highlights a Ruby file" do
      html = highlight("file.rb", "class File\n  attr_reader :path\nend")

      assert_match "<span class=\"k\">class</span>", html
      assert_match "<span class=\"nc\">File</span>", html
    end

    it "highlights a YAML file" do
      html = highlight("file.yml", "something:\n  is: true")

      assert_match "<span class=\"l-Scalar-Plain\">something</span>", html
      assert_match "<span class=\"p-Indicator\">:", html
    end

    it "highlights an .htm file" do
      html = highlight("file.htm", "<h1>Hey</h1>")

      assert_match "<span class=\"nt\">&lt;h1&gt;</span>", html
      assert_match "Hey<span class=\"nt\">&lt;/h1&gt;</span>", html
    end

    it "highlights file with custom suffix" do
      Makeup::SyntaxHighlighter.add_lexer_alias("derp", "rb")
      html = highlight("file.derp", "class File")

      assert_match "<span class=\"k\">class</span>", html
      assert_match "<span class=\"nc\">File</span>", html
    end

    it "skips highlighting if lexer is missing" do
      html = highlight("file.trololol", "Yeah yeah yeah")

      assert_equal "Yeah yeah yeah", html
    end
  end

  describe "#lexer" do
    it "uses known suffix" do
      assert_equal "rb", @highlighter.lexer("file.rb")
    end

    it "uses registered suffix" do
      Makeup::SyntaxHighlighter.add_lexer_alias("blarg", "blarg")
      assert_equal "blarg", @highlighter.lexer("file.blarg")
    end

    it "uses registered lexer" do
      Makeup::SyntaxHighlighter.add_lexer_alias("bg", "blarg")
      assert_equal "blarg", @highlighter.lexer("file.bg")
    end

    it "uses known shebang" do
      assert_equal "rb", @highlighter.lexer("some-binary", "#!/usr/bin/env ruby\n")
    end

    it "uses registered shebang" do
      Makeup::SyntaxHighlighter.add_lexer_shebang(/\bnode\b/, "js")
      assert_equal "js", @highlighter.lexer("some-binary", "#!/usr/bin/env node\n")
    end

    it "uses filename for unknown lexer" do
      assert_equal "some-binary", @highlighter.lexer("some-binary", "class Person\nend")
    end
  end
end
