module Pascual
  class Parser
    def parse(input)
      @data_offset = 0
      @sym_table = {}
      @code = []
      @lexer = Lexer.new(input)

      program

      self
    end

    def dump
      puts "sym_table"
      puts @sym_table.map(&:inspect)
      puts
      puts "code"
      @code.each_with_index do |code, i|
        puts "#{i.to_s.rjust(3, " ")} #{code}"
      end
    end

    private

    def declare_var!(name, type)
      raise "#{name} already exists" if @sym_table[name]

      @sym_table[name] = { offset: @data_offset, type: type }
      @data_offset += 1
    end

    def var_declaration(name)
      @sym_table.fetch(name)
    end

    def generate!(code)
      @code << code
    end

    def current_instruction
      @code.length
    end

    def backpatch!(offset, code)
      @code[offset] = code
    end

    def program
      program = @lexer.next_token!
      program.first == "program" || raise("expected program, got #{program.first}")

      id = @lexer.next_token!
      id.first == "ID" || raise("expected ID, got #{id.first}")

      semicolon = @lexer.next_token!
      semicolon.first == ";" || raise("expected ;, got #{semicolon.first}")

      vars = @lexer.next_token!
      vars.first == "var" ? vars_declarations : @lexer.undo!

      begin_token = @lexer.next_token!
      begin_token.first == "begin" || raise("expected begin, got #{begin_token.first}")

      instructions

      end_token = @lexer.next_token!
      end_token.first == "end" || raise("expected end, got #{end_token.first}")

      dot_token = @lexer.next_token!
      dot_token.first == "." || raise("expected ., got #{dot_token.first}")

      eof_token = @lexer.next_token!
      eof_token.first == "EOF" || raise("expected EOF, got #{eof_token.first}")
    end

    def vars_declarations
      loop do
        token = @lexer.next_token!

        case token.first
        when "begin"
          break
        when ";"
          next
        else
          @lexer.undo!
          var
        end
      end

      @lexer.undo!
    end

    def var
      id = @lexer.next_token!
      id.first == "ID" || raise("expected ID, got #{id.first}")

      colon = @lexer.next_token!
      colon.first == ":" || raise("expected :, got #{id.first}")

      integer = @lexer.next_token!
      integer.first == "Integer" || raise("expected Integer, got #{integer.first}")

      declare_var! id.last, "Integer"
    end

    def instructions
      loop do
        token = @lexer.next_token!

        case token.first
        when "end"
          break
        when ";"
          next
        else
          @lexer.undo!
          instruction
        end
      end

      @lexer.undo!
    end

    def instruction
      token = @lexer.next_token!

      case token.first
      when "ID"
        assign = @lexer.next_token!
        assign.first == ":=" || raise("expected :=, got #{assign.first}")

        expression

        generate! "store #{var_declaration(token.last)[:offset]}"
      when "begin"
        instructions

        end_token = @lexer.next_token!
        end_token.first == "end" || raise("expected end, got #{end_token.first}")
      when "if"
        cond

        then_token = @lexer.next_token!
        then_token.first == "then" || raise("expected then, got #{then_token.first}")

        if_offset = current_instruction
        generate! "jz ???"

        instruction

        else_token = @lexer.next_token!
        else_token.first == "else" || raise("expected else, got #{else_token.first}")

        else_offset = current_instruction
        generate! "jmp ???"

        backpatch!(if_offset, "jz #{current_instruction}")

        instruction

        backpatch!(else_offset, "jmp #{current_instruction}")
      else
        raise "unexpected token #{token.first}"
      end
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
      when "("
        expression
        @lexer.next_token!.first == ")" || raise("expected )")
      when "+"
        number
      when "-"
        number
        generate! "-1"
        generate! "*"
      when "INT"
        generate! token.last
      when "ID"
        generate! "load #{var_declaration(token.last)[:offset]}"
      else
        raise "expecting INT, got #{token.first}"
      end
    end

    def cond
      expression

      token = @lexer.next_token!
      token.first == "<" || raise("expected <, got #{token.first}")

      expression

      generate!("lt")
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
      elsif ("A".."Z").include?(@input[@offset])
        token = ""
        while [("A".."Z"), ("a".."z"), ("0".."9"), ["_"]].any? { |range| range.include?(@input[@offset]) }
          token << @input[@offset]
          @offset += 1
        end

        case token
        when "Integer"
          ["Integer"]
        else
          raise "unexpected token #{@input[@offset, 10]}..."
        end
      elsif ("a".."z").include?(@input[@offset])
        token = ""
        while [("a".."z"), ("0".."9"), ["_"]].any? { |range| range.include?(@input[@offset]) }
          token << @input[@offset]
          @offset += 1
        end

        case token
        when "program"
          ["program"]
        when "var"
          ["var"]
        when "begin"
          ["begin"]
        when "end"
          ["end"]
        when "if"
          ["if"]
        when "then"
          ["then"]
        when "else"
          ["else"]
        else
          ["ID", token]
        end
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
      elsif %w[. : ; + - * / < = >].include?(@input[@offset])
        token = @input[@offset]
        @offset += 1
        [token]
      else
        raise "unexpected token #{@input[@offset, 10]}..."
      end
    end
  end
end

Pascual::Parser.new.parse(File.read("program.pas")).dump
