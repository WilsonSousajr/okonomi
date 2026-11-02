require "test_helper"
require Rails.root.join("lib/delivery/comment_stripper")

# The copy delivered to the teacher has no code comments (#35). Each test pins one
# rule: what goes, and the lines that change behaviour and therefore stay.
class Delivery::CommentStripperTest < ActiveSupport::TestCase
  def strip(path, source) = Delivery::CommentStripper.strip(path, source)

  test "ruby: removes full-line and trailing comments" do
    source = <<~RUBY
      # Explains the class.
      class Foo
        # Explains the method.
        def bar = 1 # trailing note
      end
    RUBY
    assert_equal "class Foo\n  def bar = 1\nend\n", strip("app/models/foo.rb", source)
  end

  test "ruby: keeps shebang, magic comments and hashes inside strings" do
    source = <<~'RUBY'
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: utf-8
      puts "#not a comment" # but this is
      puts '#{x}'
    RUBY
    expected = <<~'RUBY'
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: utf-8
      puts "#not a comment"
      puts '#{x}'
    RUBY
    assert_equal expected, strip("bin/tool", source)
  end

  test "ruby: leaves heredoc bodies untouched" do
    source = <<~'RUBY'
      SQL = <<~TEXT
        # this is data, not a comment

        keep me
      TEXT
    RUBY
    assert_equal source, strip("lib/x.rb", source)
  end

  test "ruby: does not leave a double blank line where a comment block was" do
    source = "a = 1\n\n# one\n# two\n\nb = 2\n"
    assert_equal "a = 1\n\nb = 2\n", strip("x.rb", source)
  end

  test "ruby: drops =begin/=end blocks" do
    source = "a = 1\n=begin\nold notes\n=end\nb = 2\n"
    assert_equal "a = 1\nb = 2\n", strip("x.rb", source)
  end

  test "erb: removes comment tags and html comments, keeps output tags" do
    source = <<~ERB
      <%# Explains the form (#9). %>
      <div><%= title %></div>
      <%#= tag.link rel: "manifest" %>
      <!-- markup note -->
      <p>ok</p> <%# trailing %>
    ERB
    assert_equal "<div><%= title %></div>\n<p>ok</p>\n", strip("app/views/x.html.erb", source)
  end

  test "yaml: removes comments but not hashes in quotes or values" do
    source = <<~YAML
      # Header
      default: &default
        adapter: postgresql # inline
        color: "#fff"
        url: http://example.com/#anchor
    YAML
    expected = <<~YAML
      default: &default
        adapter: postgresql
        color: "#fff"
        url: http://example.com/#anchor
    YAML
    assert_equal expected, strip("config/database.yml", source)
  end

  test "shell: keeps shebang and $# while removing comments" do
    source = <<~SH
      #!/usr/bin/env bash
      # Explains.
      set -e # strict
      echo "$#" "${#name}" '# quoted'
    SH
    expected = <<~SH
      #!/usr/bin/env bash
      set -e
      echo "$#" "${#name}" '# quoted'
    SH
    assert_equal expected, strip("bin/setup-sh", source)
  end

  test "dockerfile: keeps parser directives, removes full-line comments only" do
    source = <<~DOCKER
      # syntax=docker/dockerfile:1
      # check=error=true
      # Explains the image.
      FROM ruby:3.4 AS base
      RUN echo a#b
    DOCKER
    expected = <<~DOCKER
      # syntax=docker/dockerfile:1
      # check=error=true
      FROM ruby:3.4 AS base
      RUN echo a#b
    DOCKER
    assert_equal expected, strip("Dockerfile", source)
  end

  test "javascript: removes line and block comments, keeps strings and urls" do
    source = <<~JS
      // Configure the map.
      import "@hotwired/turbo-rails" // trailing
      /* block
         comment */
      const url = "http://example.com/a" + '//b' + `/*c*/`
      const re = /a\\/\\/b/g
    JS
    expected = <<~JS
      import "@hotwired/turbo-rails"
      const url = "http://example.com/a" + '//b' + `/*c*/`
      const re = /a\\/\\/b/g
    JS
    assert_equal expected, strip("app/javascript/application.js", source)
  end

  test "css: removes block comments and keeps @import" do
    source = "/* Tailwind entry */\n@import \"tailwindcss\";\na { content: \"/* x */\"; } /* t */\n"
    assert_equal "@import \"tailwindcss\";\na { content: \"/* x */\"; }\n", strip("app/assets/tailwind/application.css", source)
  end

  test "html: removes comments" do
    assert_equal "<p>a</p>\n", strip("public/404.html", "<!-- note -->\n<p>a</p>\n")
  end

  test "html and erb: removes css comments inside style blocks, keeps css ids" do
    source = "<style>\n  /* Email styles */\n  #error-id { color: red; }\n</style>\n<p>/* text, not css */</p>\n"
    expected = "<style>\n  #error-id { color: red; }\n</style>\n<p>/* text, not css */</p>\n"
    assert_equal expected, strip("app/views/layouts/mailer.html.erb", source)
    assert_equal expected, strip("public/500.html", source)
  end

  test "robots.txt: removes hash comments" do
    assert_equal "User-agent: *\n", strip("public/robots.txt", "# See docs\nUser-agent: *\n")
  end

  test "unknown types are returned unchanged" do
    assert_equal "# keep\n", strip("docs/README.md", "# keep\n")
  end

  test "detects ruby and shell scripts without extension by shebang" do
    assert_equal :ruby, Delivery::CommentStripper.language("bin/rails", "#!/usr/bin/env ruby\n")
    assert_equal :hash, Delivery::CommentStripper.language("bin/docs-pdf", "#!/usr/bin/env bash\n")
    assert_equal :ruby, Delivery::CommentStripper.language("Gemfile", "source 'x'\n")
  end
end
