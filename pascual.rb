module Pascual
  class Parser
    def parse(input)
      @code = []
      @lexer = Lexer.new(input)

      instructions

      self
    end

    def dump
      puts @code
    end

    private

    def generate!(code)
      @code << code
    end

    def instructions
      loop do
        token = @lexer.next_token!

        case token.first
        when "EOF"
          break
        when ";"
          next
        else
          @lexer.undo!
          instruction
        end
      end
    end

    def instruction
      id = @lexer.next_token!
      id.first == "ID" || raise("expected ID, got #{id.first}")

      assign = @lexer.next_token!
      assign.first == ":=" || raise("expected :=, got #{assign.first}")

      expression

      generate! "store #{id.last}"
    end

    def expression
      factor

      loop do
        token = @lexer.next_token!

        case token.first
        when "+"
          factor
          generate! "+"
        when "-"
          factor
          generate! "-"
        else break
        end
      end

      @lexer.undo!
    end

    def factor
      number

      loop do
        token = @lexer.next_token!

        case token.first
        when "*"
          number
          generate! "*"
        when "/"
          number
          generate! "/"
        else break
        end
      end

      @lexer.undo!
    end

    def number
      token = @lexer.next_token!

      case token.first
      when "+"
        number
      when "-"
        number
        generate! "-1"
        generate! "*"
      when "INT"
        generate! token.last
      else
        raise "expecting INT, got #{token.first}"
      end
    end
  end

  class Lexer
    def initialize(input)
      @input, @undo = input, false
      @offset = 0
    end

    def next_token!
      if @undo
        @undo = false
        return @prev_token
      end

      @prev_token = extract_next_token!
    end

    def undo!
      @undo = true
    end

    private

    def extract_next_token!
      @offset += 1 while ["\n", "\t", " "].include?(@input[@offset])

      if @offset >= @input.length
        ["EOF"]
      elsif %w[; + - * /].include?(@input[@offset])
        token = @input[@offset]
        @offset += 1
        [token]
      elsif ("a".."z").include?(@input[@offset])
        token = ""
        while [("a".."z"), ("0".."9"), ["_"]].any? { |range| range.include?(@input[@offset]) }
          token << @input[@offset]
          @offset += 1
        end
        ["ID", token]
      elsif ("0".."9").include?(@input[@offset])
        token = ""
        while ("0".."9").include?(@input[@offset])
          token << @input[@offset]
          @offset += 1
        end
        ["INT", token]
      elsif @input[@offset, 2] == ":="
        @offset += 2
        [":="]
      else
        raise "unexpected token #{@input[@offset, 10]}..."
      end
    end
  end
end

Pascual::Parser.new.parse(File.read("program.rb")).dump
