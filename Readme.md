# Makeup

<a href="http://travis-ci.org/cjohansen/makeup" class="travis">
  <img src="https://secure.travis-ci.org/cjohansen/makeup.png">
</a>

Makeup provides markup rendering and syntax highlighting in one glorious
package. It can also syntax highlight "fenced code blocks" in markdown files.

`Makeup` does all its heavylifting through `GitHub::Markup` and `Pygments.rb`,
and combines the two for killer code blocks in markup files.

## Markup

Rendering markup is done through `Makeup::Markup`. For information about markup
formats, what gems to install for various format support etc see the
[`GitHub::Markup` docs](https://github.com/github/markup/).

```ruby
require "makeup"

Makeup::Markup.new.render("file.md", "# Some markdown")
```

`GitHub::Markup` uses the file name to decide what markup format to render the
contents with.

To extract and syntax highlight "fenced code blocks" with Pygments, give the
markup renderer a highlighter:

```ruby
require "makeup"

highlighter = Makeup::SyntaxHighlighter.new
renderer = Makeup::Markup.new(:highlighter => highlighter)
renderer.render("file.md", <<MD)
# Documentation and examples

## s-trim `(s)`

Remove whitespace at the beginning and end of `s`.

\`\`\`cl
(s-trim "trim ") ;; => "trim"
(s-trim " this") ;; => "this"
(s-trim " only  trims beg and end  ") ;; => "only  trims beg and end"
\`\`\`
MD
```

The fenced code block will be syntax highlighted with the common lisp lexer.

## Syntax highlighting

`Makeup` provides a very thin abstraction around `Pygments.rb` for syntax
highlighting:

```ruby
require "makeup"

highlighter = Makeup::SyntaxHighlighter.new
res = highlighter.highlight(person.rb", <<RUBY)
class Person
  def speak
    "Hello"
  end
end
RUBY

res.lexer # "ruby"
res.code # HTML-formatted syntax highlighted code
```
