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

    def simulate
      ip = 0
      stack = []
      memory = Array.new(@sym_table.length, 0)

      while ip < @code.length
        instruction = @code[ip]

        case instruction.first
        when "push"
          stack.push instruction.last
        when "load"
          stack.push memory[instruction.last]
        when "store"
          memory[instruction.last] = stack.pop
        when "+"
          b = stack.pop
          a = stack.pop
          stack.push(a + b)
        when "-"
          b = stack.pop
          a = stack.pop
          stack.push(a - b)
        when "*"
          b = stack.pop
          a = stack.pop
          stack.push(a * b)
        when "/"
          b = stack.pop
          a = stack.pop
          stack.push(a / b)
        when "lt"
          b = stack.pop
          a = stack.pop
          stack.push(a < b ? 1 : 0)
        when "jz"
          a = stack.pop
          ip = instruction.last if a == 0
          break
        when "jmp"
          a = stack.pop
          ip = instruction.last
          break
        else
          raise "unexpected instruction #{instruction.first}"
        end

        ip += 1
      end

      p memory
    end

    private

    def declare_var!(name, type)
      raise "#{name} already exists" if @sym_table[name]

      @sym_table[name] = { offset: @data_offset, type: type }
      @data_offset += 1
    end

    def var_specs(name)
      @sym_table.fetch(name)
    end

    def generate!(code)
      @code << code
    end

    def current_instruction
      @code.length
    end

    def back_patch!(offset, code)
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
          var_declaration
        end
      end

      @lexer.undo!
    end

    def var_declaration
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

        generate! ["store", var_specs(token.last)[:offset]]
      when "begin"
        instructions

        end_token = @lexer.next_token!
        end_token.first == "end" || raise("expected end, got #{end_token.first}")
      when "if"
        cond

        then_token = @lexer.next_token!
        then_token.first == "then" || raise("expected then, got #{then_token.first}")

        if_offset = current_instruction
        generate! ["jz", -1]

        instruction

        else_token = @lexer.next_token!
        else_token.first == "else" || raise("expected else, got #{else_token.first}")

        else_offset = current_instruction
        generate! ["jz", -1]

        back_patch!(if_offset, ["jz", current_instruction])

        instruction

        back_patch!(else_offset, ["jmp", current_instruction])
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
          generate! ["+"]
        when "-"
          factor
          generate! ["-"]
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
          generate! ["*"]
        when "/"
          number
          generate! ["/"]
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
        generate! ["push", -1]
        generate! ["*"]
      when "INT"
        generate! ["push", token.last.to_i]
      when "ID"
        generate! ["load", var_specs(token.last)[:offset]]
      else
        raise "expecting INT, got #{token.first}"
      end
    end

    def cond
      expression

      token = @lexer.next_token!
      token.first == "<" || raise("expected <, got #{token.first}")

      expression

      generate! ["lt"]
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

parser = Pascual::Parser.new.parse(File.read("program.pas"))
parser.dump
parser.simulate
