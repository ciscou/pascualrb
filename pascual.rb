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
          a = stack.pop
          stack.push memory[a]
        when "store"
          b = stack.pop
          a = stack.pop
          memory[a] = b
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
          stack.push(a.fdiv(b))
        when "div"
          b = stack.pop
          a = stack.pop
          stack.push(a / b)
        when "mod"
          b = stack.pop
          a = stack.pop
          stack.push(a % b)
        when "lt"
          b = stack.pop
          a = stack.pop
          stack.push(a < b ? 1 : 0)
        when "eq"
          b = stack.pop
          a = stack.pop
          stack.push(a == b ? 1 : 0)
        when "gt"
          b = stack.pop
          a = stack.pop
          stack.push(a > b ? 1 : 0)
        when "lte"
          b = stack.pop
          a = stack.pop
          stack.push(a <= b ? 1 : 0)
        when "neq"
          b = stack.pop
          a = stack.pop
          stack.push(a != b ? 1 : 0)
        when "gte"
          b = stack.pop
          a = stack.pop
          stack.push(a >= b ? 1 : 0)
        when "and"
          b = stack.pop
          a = stack.pop
          stack.push(a != 0 && b != 0 ? 1 : 0)
        when "or"
          b = stack.pop
          a = stack.pop
          stack.push(a != 0 || b != 0 ? 1 : 0)
        when "not"
          a = stack.pop
          stack.push(a == 0 ? 1 : 0)
        when "jz"
          a = stack.pop
          ip = a == 0 ? instruction.last : ip + 1
          next
        when "jmp"
          a = stack.pop
          ip = instruction.last
          next
        when "writeln"
          a = stack.pop
          puts a
        else
          raise "unexpected instruction #{instruction.first}"
        end

        ip += 1
      end
    end

    private

    def declare_var!(name, type, opts = {})
      raise "#{name} already exists" if @sym_table[name]

      @sym_table[name] = opts.merge(offset: @data_offset, type: type)

      case type
      when "Integer", "Boolean"
        @data_offset += 1
      when "Array"
        # TODO this is assuming the array elements have size 1
        @data_offset += 1 * (opts[:end_index] - opts[:start_index] + 1)
      else
        raise "invalid type #{type}"
      end
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

    def expect_token!(token)
      next_token = @lexer.next_token!

      unless next_token.first == token
        raise "expected #{token}, got #{next_token.first}"
      end

      next_token
    end

    def program
      expect_token!("program")

      id = expect_token!("ID")

      expect_token!(";")

      vars = @lexer.next_token!
      vars.first == "var" ? vars_declarations : @lexer.undo!

      expect_token!("begin")

      instructions

      expect_token!("end")
      expect_token!(".")
      expect_token!("EOF")
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
      ids = []
      ids << expect_token!("ID")

      loop do
        token = @lexer.next_token!

        case token.first
        when ","
          ids << expect_token!("ID")
        when ":"
          break
        else
          @lexer.undo!
          expect_token!(":")
        end
      end

      type = @lexer.next_token!
      case type.first
      when "Integer"
        ids.each do |id|
          declare_var! id.last, "Integer"
        end
      when "Boolean"
        ids.each do |id|
          declare_var! id.last, "Boolean"
        end
      when "Array"
        expect_token!("[")
        start_index = expect_token!("INT")
        expect_token!("..")
        end_index = expect_token!("INT")
        expect_token!("]")

        expect_token!("of")

        expect_token!("Integer")

        ids.each do |id|
          declare_var! id.last, "Array", of: "Integer", start_index: start_index.last.to_i, end_index: end_index.last.to_i
        end
      else
        raise "invalid type #{type.first}"
      end
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
        var = var_specs(token.last)

        generate! ["push", var[:offset]]

        case var[:type]
        when "Integer"
          expect_token!(":=")

          expression

          generate! ["store"]
        when "Boolean"
          expect_token!(":=")

          cond

          generate! ["store"]
        when "Array"
          expect_token!("[")
          expression
          expect_token!("]")

          # TODO this is assuming the array elements have size 1
          # TODO this is assuming the array start at index 0
          generate! ["+"]

          expect_token!(":=")

          expression

          generate! ["store"]
        else
          raise "unknown type #{var[:type]}"
        end
      when "begin"
        instructions

        expect_token!("end")
      when "if"
        cond

        expect_token!("then")

        if_offset = current_instruction
        generate! ["jz", -1]

        instruction

        expect_token!("else")

        else_offset = current_instruction
        generate! ["jmp", -1]

        back_patch!(if_offset, ["jz", current_instruction])

        instruction

        back_patch!(else_offset, ["jmp", current_instruction])
      when "while"
        cond_offset = current_instruction

        cond

        expect_token!("do")

        do_offset = current_instruction
        generate! ["jz", -1]

        instruction

        generate! ["jmp", cond_offset]

        back_patch!(do_offset, ["jz", current_instruction])
      when "writeln"
        expect_token!("(")
        expression
        expect_token!(")")

        generate! ["writeln"]
      when "noop"
        # no-op!
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
        when "div"
          number
          generate! ["div"]
        when "mod"
          number
          generate! ["mod"]
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
        expect_token!(")")
      when "+"
        number
      when "-"
        number
        generate! ["push", -1]
        generate! ["*"]
      when "INT"
        generate! ["push", token.last.to_i]
      when "ID"
        var = var_specs(token.last)

        generate! ["push", var_specs(token.last)[:offset]]

        case var[:type]
        when "Integer"
          generate! ["load"]
        when "Array"
          expect_token!("[")
          expression
          expect_token!("]")

          # TODO this is assuming the array elements have size 1
          # TODO this is assuming the array start at index 0
          generate! ["+"]
          generate! ["load"]
        else
          raise "unknown type #{var[:type]}"
        end
      else
        raise "expecting INT, got #{token.first}"
      end
    end

    def cond
      first_token = @lexer.next_token!

      case first_token.first
      when "("
        cond
        expect_token!(")")
      when "not"
        cond
        generate! ["not"]
      when "true"
        generate! ["push", 1]
      when "false"
        generate! ["push", 0]
      else
        var = var_specs(first_token.last) if first_token.first == "ID"

        if var && var[:type] == "Boolean"
          # TODO what about an Array of Boolean?
          generate! ["push", var[:offset]]
          generate! ["load"]
        else
          @lexer.undo!
          expression

          comp_token = @lexer.next_token!

          expression

          case comp_token.first
          when "<"
            generate! ["lt"]
          when "="
            generate! ["eq"]
          when ">"
            generate! ["gt"]
          when "<="
            generate! ["lte"]
          when "<>"
            generate! ["neq"]
          when ">="
            generate! ["gte"]
          else
            raise "unexpected token #{comp_token.first}"
          end
        end
      end

      next_token = @lexer.next_token!

      case next_token.first
      when "and"
        cond
        generate! ["and"]
      when "or"
        cond
        generate! ["or"]
      else
        @lexer.undo!
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
      elsif ("A".."Z").include?(@input[@offset])
        token = ""
        while [("A".."Z"), ("a".."z"), ("0".."9"), ["_"]].any? { |range| range.include?(@input[@offset]) }
          token << @input[@offset]
          @offset += 1
        end

        case token
        when "Integer"
          ["Integer"]
        when "Boolean"
          ["Boolean"]
        when "Array"
          ["Array"]
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
        when "of"
          ["of"]
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
        when "while"
          ["while"]
        when "do"
          ["do"]
        when "readln"
          ["readln"]
        when "writeln"
          ["writeln"]
        when "div"
          ["div"]
        when "mod"
          ["mod"]
        when "and"
          ["and"]
        when "or"
          ["or"]
        when "not"
          ["not"]
        when "noop"
          ["noop"]
        when "true"
          ["true"]
        when "false"
          ["false"]
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
      elsif @input[@offset, 2] == "<="
        @offset += 2
        ["<="]
      elsif @input[@offset, 2] == "<>"
        @offset += 2
        ["<>"]
      elsif @input[@offset, 2] == ">="
        @offset += 2
        [">="]
      elsif @input[@offset, 2] == ":="
        @offset += 2
        [":="]
      elsif @input[@offset, 2] == ".."
        @offset += 2
        [".."]
      elsif %w{. , : ; + - * / < = > ( ) [ ]}.include?(@input[@offset])
        token = @input[@offset]
        @offset += 1
        [token]
      else
        raise "unexpected token #{@input[@offset, 10]}..."
      end
    end
  end
end

parser = Pascual::Parser.new.parse(File.read(ARGV.first || "program.pas"))
# parser.dump
parser.simulate
