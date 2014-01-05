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
require "makeup/markup"

describe Makeup::Markup do
  before do
    @highlighter = Makeup::SyntaxHighlighter.new
    @renderer = Makeup::Markup.new(:highlighter => @highlighter)
  end

  describe "#render" do
    it "renders multi-line code blocks with syntax highlighting" do
      html = @renderer.render("file.md", <<-MD)
```cl
(s-trim-left "trim ") ;; => "trim "
(s-trim-left " this") ;; => "this"
```
      MD

      assert_match "<pre class=\"common-lisp prettyprint\">", html
    end

    it "highlights multiple separate multi-line code blocks" do
      html = @renderer.render("file.md", <<-MD)
# This stuff

```cl
(s-trim-left "trim ") ;; => "trim "
(s-trim-left " this") ;; => "this"
```

# And this stuff

```cl
(s-trim-left "trim ") ;; => "trim "
(s-trim-left " this") ;; => "this"
```
      MD

      assert_equal 2, html.scan(/common-lisp/).length
    end

    it "strips unsafe html attributes and elements" do
      md = <<-MD
<script>alert("foo")</script>
<a href="foo" data-destroy="boom" onclick="alert('foo')">link</a>
*bar*
      MD

      html = @renderer.render("file.md", md)

      sanitized = %Q{<p><a href="foo">link</a>\n<em>bar</em></p>}

      if Nokogiri::VersionInfo.new.loaded_parser_version > '2.9.0' \
        and sanitized != html
        # loofah with newer libxml2 leaves blank lines in output.
        # https://github.com/flavorjones/loofah/issues/60
        assert_equal sanitized, html.gsub(/\n+|\r+/, "\n").squeeze("\n").strip
      else
        assert_equal sanitized, html
      end
    end
  end

  describe "#render" do
    it "should detect end of code blocks properly" do
      html = @renderer.render("file.md", <<-MD)
# This stuff

```ruby
class Hello
  def say
    puts "hallo"
  end
end
```hidden-charaters

# And this stuff

```ruby
class Bonjour
  def say
    puts "bonjour"
  end
end
```
      MD

      assert_equal 2, html.scan(/rb/).length
    end
  end

  describe "#highlight_code_blocks" do
    it "does not touch non-markdown files" do
      content = "```cl\n(yup)\n```"
      highlighted = @renderer.highlight_code_blocks("file.rst", content)
      assert_equal content, highlighted
    end

    it "highlights one-line code block" do
      content = "```cl\n(yup)\n```"
      highlighted = @renderer.highlight_code_blocks("file.md", content)
      assert_match "common-lisp", highlighted
    end

    it "highlights multi-line code block" do
      content = "```cl\n(yup)\n(yessir-p t)\n```"
      highlighted = @renderer.highlight_code_blocks("file.md", content)
      assert_match "(</span><span class=\"nv\">yessir-p</span>", highlighted
    end

    it "preserves code block white-space" do
      content = "```cl\n(yup\n  (yessir-p t))\n```"
      highlighted = @renderer.highlight_code_blocks("file.md", content)
      assert_match "\n  <span class=\"p\">(</span>", highlighted
    end
  end

  describe "markups" do
    it "provides a list of supported markups" do
      markups = Makeup::Markup.markups

      assert Array === markups
      assert(markups.find { |m| m.match?("*.md") })
    end
  end
end
