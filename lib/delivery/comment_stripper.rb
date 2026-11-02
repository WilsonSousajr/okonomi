require "prism"
require "set"

module Delivery
  # Removes code comments from the copy delivered to the teacher (#35, AGENTS.md
  # "Final delivery"). Lines that change behaviour stay: shebangs, Ruby magic
  # comments and Dockerfile parser directives. Plain Ruby so bin/package-delivery
  # can use it without booting Rails.
  module CommentStripper
    MARK = "\u0001".freeze
    RUBY_FILES = %w[Gemfile Rakefile Brewfile].freeze
    LINE_ONLY_FILES = %w[.gitignore .dockerignore .gitattributes .env.example Procfile Procfile.dev robots.txt].freeze
    RUBY_MAGIC = /\A#\s*(-\*-.*)?(frozen_string_literal|encoding|coding|warn_indent|shareable_constant_value)\s*:/i
    DOCKER_DIRECTIVE = /\A#\s*(syntax|check|escape)=/

    module_function

    def strip(path, source)
      case language(path, source)
      when :ruby then strip_ruby(source)
      when :erb then strip_markup(source, /<%#.*?%>|<!--(?!\[if).*?-->/m)
      when :html then strip_markup(source, /<!--(?!\[if).*?-->/m)
      when :hash then strip_hash(source)
      when :line_only then strip_full_lines(source)
      when :dockerfile then strip_full_lines(source, keep: DOCKER_DIRECTIVE)
      when :javascript then strip_c_style(source, line_comments: true, regex: true)
      when :css then strip_c_style(source, line_comments: false, regex: false)
      else source
      end
    end

    def language(path, source)
      base = File.basename(path)
      return :erb if base.end_with?(".erb")

      case File.extname(base)
      when ".rb", ".rake", ".ru", ".gemspec" then :ruby
      when ".yml", ".yaml", ".toml", ".sh", ".sample" then :hash
      when ".js", ".mjs" then :javascript
      when ".css" then :css
      when ".html" then :html
      else
        first_line = source.each_line.first.to_s
        if RUBY_FILES.include?(base) || first_line.match?(/\A#!.*\bruby\b/) then :ruby
        elsif base == "Dockerfile" then :dockerfile
        elsif LINE_ONLY_FILES.include?(base) then :line_only
        elsif first_line.start_with?("#!") || path.end_with?(".kamal/secrets") then :hash
        end
      end
    end

    def strip_ruby(source)
      lines = source.lines
      removed = Set.new
      edits = {}

      Prism.parse(source).comments.each do |comment|
        location = comment.location
        text = location.slice
        index = location.start_line - 1

        if comment.is_a?(Prism::EmbDocComment)
          last = location.end_line - 1
          last -= 1 if location.end_column.zero?
          (index..last).each { |line| removed << line }
          next
        end
        next if index.zero? && text.start_with?("#!")
        next if text.match?(RUBY_MAGIC)

        line = lines[index]
        before = line.byteslice(0, location.start_column)
        if before.strip.empty?
          removed << index
        else
          edits[index] = before.rstrip + (line.end_with?("\n") ? "\n" : "")
        end
      end

      assemble(lines, removed, edits)
    end

    # ERB and HTML: comments are delimited spans, possibly over several lines. CSS
    # comments count too, but only inside <style>, where they are CSS.
    def strip_markup(source, pattern)
      marked = source.gsub(pattern, MARK).gsub(%r{(<style[^>]*>)(.*?)(</style>)}m) do
        open_tag, css, close_tag = Regexp.last_match.captures
        open_tag + mark_c_style(css, line_comments: false, regex: false) + close_tag
      end
      finish_marked(marked)
    end

    # YAML, TOML, shell: "#" starts a comment at the start of a word, outside quotes.
    # Shell heredoc bodies are data and stay as they are.
    def strip_hash(source)
      lines = source.lines
      removed = Set.new
      edits = {}
      heredoc_end = nil

      lines.each_with_index do |line, index|
        if heredoc_end
          heredoc_end = nil if line.strip == heredoc_end
          next
        end
        next if index.zero? && line.start_with?("#!")

        start = hash_comment_start(line)
        if start
          before = line[0...start]
          if before.strip.empty?
            removed << index
          else
            edits[index] = before.rstrip + (line.end_with?("\n") ? "\n" : "")
          end
        end

        code = start ? line[0...start] : line
        heredoc_end = Regexp.last_match(1) if code =~ /<<-?\s*["']?(\w+)["']?/
      end

      assemble(lines, removed, edits)
    end

    def hash_comment_start(line)
      quote = nil
      escaped = false

      line.each_char.with_index do |char, index|
        if quote
          if escaped then escaped = false
          elsif char == "\\" && quote == '"' then escaped = true
          elsif char == quote then quote = nil
          end
        elsif char == '"' || char == "'"
          quote = char
        elsif char == "#" && (index.zero? || line[index - 1].match?(/\s/))
          return index
        end
      end
      nil
    end

    # Dockerfile, ignore files, env files: only whole-line comments exist.
    def strip_full_lines(source, keep: nil)
      lines = source.lines
      removed = Set.new
      lines.each_with_index do |line, index|
        comment = line.lstrip
        next unless comment.start_with?("#")
        next if keep && comment.match?(keep)

        removed << index
      end
      assemble(lines, removed, {})
    end

    # JavaScript and CSS: skips strings, template literals and (for JS) regex literals.
    def strip_c_style(source, line_comments:, regex:)
      finish_marked(mark_c_style(source, line_comments:, regex:))
    end

    def mark_c_style(source, line_comments:, regex:)
      output = +""
      index = 0
      last_significant = nil

      while index < source.length
        char = source[index]
        following = source[index + 1]

        if char == "/" && following == "*"
          finish = source.index("*/", index + 2) || source.length - 2
          output << MARK
          index = finish + 2
        elsif char == "/" && following == "/" && line_comments
          finish = source.index("\n", index) || source.length
          output << MARK
          index = finish
        elsif char == '"' || char == "'" || (char == "`" && regex)
          finish = closing_quote(source, index)
          output << source[index..finish]
          last_significant = char
          index = finish + 1
        elsif char == "/" && regex && regex_allowed?(last_significant)
          finish = closing_regex(source, index)
          output << source[index..finish]
          last_significant = "/"
          index = finish + 1
        else
          output << char
          last_significant = char unless char.match?(/\s/)
          index += 1
        end
      end

      output
    end

    def closing_quote(source, start)
      quote = source[start]
      index = start + 1
      while index < source.length
        return index if source[index] == quote
        index += source[index] == "\\" ? 2 : 1
      end
      source.length - 1
    end

    def closing_regex(source, start)
      index = start + 1
      in_class = false
      while index < source.length
        char = source[index]
        if char == "\\" then index += 2
          next
        end
        in_class = true if char == "["
        in_class = false if char == "]"
        return index + source[index + 1..].to_s[/\A[a-z]*/].length if char == "/" && !in_class
        return index - 1 if char == "\n"
        index += 1
      end
      source.length - 1
    end

    def regex_allowed?(last_significant)
      last_significant.nil? || "(,=:[!&|?{};+-*%<>~^".include?(last_significant)
    end

    # A line that held only comments disappears; a trailing comment leaves the code.
    def finish_marked(text)
      lines = text.lines
      removed = Set.new
      edits = {}
      lines.each_with_index do |line, index|
        next unless line.include?(MARK)

        cleaned = line.delete(MARK)
        if cleaned.strip.empty?
          removed << index
        else
          edits[index] = cleaned.rstrip + (line.end_with?("\n") ? "\n" : "")
        end
      end
      assemble(lines, removed, edits)
    end

    # Drops removed lines; where a removed block sat between two blank lines (or at
    # the top of the file before a blank line), one blank line goes too.
    def assemble(lines, removed, edits)
      output = []
      index = 0
      while index < lines.size
        unless removed.include?(index)
          output << (edits[index] || lines[index])
          index += 1
          next
        end

        index += 1 while removed.include?(index)
        previous_blank = output.empty? || output.last.strip.empty?
        index += 1 if previous_blank && index < lines.size && lines[index].strip.empty? && !edits.key?(index)
      end
      output.join
    end
  end
end
