module Pascual
  class Parser
    def parse(input)
      @data_offsets = [0]
      @sym_tables = [{}]
      @code = []
      @lexer = Lexer.new(input)

      program

      self
    end

    def dump
      puts "sym_table"
      puts @sym_tables.map(&:inspect)
      puts
      puts "code"
      @code.each_with_index do |code, i|
        puts "#{i.to_s.rjust(3, " ")} #{code}"
      end
    end

    def simulate
      ip = 0
      stack = []
      calls = []
      offset = [0]

      memory = Array.new(640_000, 0)

      while ip < @code.length
        instruction = @code[ip]

        case instruction.first
        when "allocate"
          offset.push instruction.last
        when "free"
          offset.pop
        when "offset"
          stack.push offset[-2]
        when "push"
          stack.push instruction.last
        when "load"
          a = stack.pop
          raise "EOM" if a >= 640_000
          stack.push memory[a]
        when "store"
          b = stack.pop
          a = stack.pop
          raise "EOM" if a >= 640_000
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
        when "jsr"
          calls.push(ip)
          ip = instruction.last
          next
        when "ret"
          ip = calls.pop
        when "jmp"
          ip = instruction.last
          next
        when "swap"
          stack[-2], stack[-1] = stack[-1], stack[-2]
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
      raise "#{name} already exists" if @sym_tables.last[name]

      @sym_tables.last[name] = opts.merge(offset: @data_offsets.last, type: type)

      case type
      when "Integer", "Boolean"
        @data_offsets[-1] += 1
      when "Array"
        # TODO this is assuming the array elements have size 1
        @data_offsets[-1] += 1 * (opts[:end_index] - opts[:start_index] + 1)
      when "Function"
        # no-op
      else
        raise "invalid type #{type}"
      end
    end

    def var_specs(name)
      @sym_tables.reverse_each do |sym_table|
        return sym_table[name] if sym_table.key?(name)
      end

      raise "Unknown variable or function #{name}"
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
      next_token = @lexer.next!

      unless next_token.first == token
        raise "expected #{token}, got #{next_token.first}, at line #{@lexer.line}, col #{@lexer.col}"
      end

      next_token
    end

    def program
      generate! ["jmp", -1] # reverse jump to main function address

      expect_token!("program")

      expect_token!("ID")

      expect_token!(";")

      loop do
        token = @lexer.peek

        case token.first
        when "var"
          @lexer.next!
          vars_declarations
        when "function"
          function_declaration
        else
          break
        end
      end

      expect_token!("begin")

      back_patch!(0, ["jmp", current_instruction])
      generate! ["allocate", @data_offsets[-1]]

      instructions

      generate! ["free", @data_offsets[-1]]

      expect_token!("end")
      expect_token!(".")
      expect_token!("EOF")
    end

    def vars_declarations
      loop do
        token = @lexer.peek

        case token.first
        when "begin", ")"
          break
        when ";"
          @lexer.next!
          next
        else
          var_declaration
        end
      end
    end

    def var_declaration
      ids = []
      ids << expect_token!("ID")

      loop do
        token = @lexer.peek

        case token.first
        when ","
          @lexer.next!
          ids << expect_token!("ID")
        when ":"
          expect_token!(":")
          break
        end
      end

      type = @lexer.next!
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

    def function_declaration
      expect_token!("function")

      @sym_tables.push({})
      @data_offsets.push(0)

      function_name = expect_token!("ID")
      expect_token!("(")
      vars_declarations
      expect_token!(")")

      expect_token!(":")
      expect_token!("Integer")
      expect_token!(";")

      declare_var!(function_name.last, "Integer")

      address = current_instruction
      generate! ["allocate", @data_offsets[-1]]

      @sym_tables.last.reverse_each do |arg_name, arg_specs|
        next if arg_name == function_name.last

        generate! ["push", arg_specs[:offset]]
        generate! ["offset"]
        generate! ["+"]
        generate! ["swap"]
        generate! ["store"]
      end

      if @lexer.peek.first == "var"
        @lexer.next!
        vars_declarations;
      end

      expect_token!("begin")

      instructions

      expect_token!("end")
      expect_token!(";")

      fun = var_specs(function_name.last)
      generate! ["push", fun[:offset]]
      generate! ["offset"]
      generate! ["+"]
      generate! ["load"]

      generate! ["free", @data_offsets[-1]]

      generate! ["ret"]

      @sym_tables.pop
      @data_offsets.pop

      declare_var!(function_name.last, "Function", address: address)
    end

    def instructions
      loop do
        token = @lexer.peek

        case token.first
        when "end"
          break
        when ";"
          @lexer.next!
        else
          instruction
        end
      end
    end

    def instruction
      token = @lexer.next!

      case token.first
      when "ID"
        var = var_specs(token.last)

        # TODO probably look for a LHS until the next token is := and check types and stuff

        generate! ["push", var[:offset]]
        generate! ["offset"]
        generate! ["+"]

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
        raise "unexpected token #{token.first} at line #{@lexer.line}, col #{@lexer.col}"
      end
    end

    def expressions
      expression

      loop do
        token = @lexer.peek

        case token.first
        when ","
          @lexer.next!
          expression
        else
          break
        end
      end
    end

    def expression
      factor

      loop do
        token = @lexer.peek

        case token.first
        when "+"
          @lexer.next!
          factor
          generate! ["+"]
        when "-"
          @lexer.next!
          factor
          generate! ["-"]
        else break
        end
      end
    end

    def factor
      term

      loop do
        token = @lexer.peek

        case token.first
        when "*"
          @lexer.next!
          term
          generate! ["*"]
        when "/"
          @lexer.next!
          term
          generate! ["/"]
        when "div"
          @lexer.next!
          term
          generate! ["div"]
        when "mod"
          @lexer.next!
          term
          generate! ["mod"]
        else break
        end
      end
    end

    def term
      token = @lexer.next!

      case token.first
      when "("
        expression
        expect_token!(")")
      when "+"
        term
      when "-"
        term
        generate! ["push", -1]
        generate! ["*"]
      when "INT"
        generate! ["push", token.last.to_i]
      when "ID"
        var = var_specs(token.last)

        # TODO probably look for a RHS until the next token is := and check types and stuff

        unless var[:type] == "Function"
          generate! ["push", var[:offset]]
          generate! ["offset"]
          generate! ["+"]
        end

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
        when "Function"
          expect_token!("(")
          expressions
          expect_token!(")")

          # TODO this is assuming all functions accept arguments of type Integer
          generate! ["jsr", var[:address]]
        else
          raise "unknown type #{var[:type]}"
        end
      else
        raise "expecting INT, got #{token.first}"
      end
    end

    def cond
      first_token = @lexer.peek

      case first_token.first
      when "("
        @lexer.next!
        cond
        expect_token!(")")
      when "not"
        @lexer.next!
        cond
        generate! ["not"]
      when "true"
        @lexer.next!
        generate! ["push", 1]
      when "false"
        @lexer.next!
        generate! ["push", 0]
      else
        var = var_specs(first_token.last) if first_token.first == "ID"

        if var && var[:type] == "Boolean"
          @lexer.next!
          # TODO what about an Array of Boolean?
          generate! ["push", var[:offset]]
          generate! ["offset"]
          generate! ["+"]
          generate! ["load"]
        else
          expression

          comp_token = @lexer.next!

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

      next_token = @lexer.peek

      case next_token.first
      when "and"
        @lexer.next!
        cond
        generate! ["and"]
      when "or"
        @lexer.next!
        cond
        generate! ["or"]
      else
      end
    end
  end

  class Lexer
    def initialize(input)
      @input = input
      @offset = 0
      @line = 1
      @col = 1
      @it = Enumerator.new do |y|
        loop do
          token = extract_next_token!
          y << token
          break if token.first == "EOF"
        end
      end
    end

    attr_reader :line, :col

    def peek
      @it.peek
    end

    def next!
      @it.next
    end

    private

    def extract_next_token!
      while ["\n", "\t", " "].include?(@input[@offset])
        if @input[@offset] == "\n"
          @col = 1
          @line += 1
        else
          @col += 1
        end

        @offset += 1
      end

      if @offset >= @input.length
        ["EOF"]
      elsif ("A".."Z").include?(@input[@offset])
        token = ""
        while [("A".."Z"), ("a".."z"), ("0".."9"), ["_"]].any? { |range| range.include?(@input[@offset]) }
          token << @input[@offset]
          @offset += 1
        end

        @col += token.length

        case token
        when "Integer"
          ["Integer"]
        when "Boolean"
          ["Boolean"]
        when "Array"
          ["Array"]
        else
          raise "unexpected token #{token} at line #{@line} col #{@col - token.length}"
        end
      elsif ("a".."z").include?(@input[@offset])
        token = ""
        while [("a".."z"), ("0".."9"), ["_"]].any? { |range| range.include?(@input[@offset]) }
          token << @input[@offset]
          @offset += 1
        end

        @col += token.length

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
        when "function"
          ["function"]
        else
          ["ID", token]
        end
      elsif ("0".."9").include?(@input[@offset])
        token = ""
        while ("0".."9").include?(@input[@offset])
          token << @input[@offset]
          @offset += 1
        end
        @col += token.length
        ["INT", token]
      elsif @input[@offset, 2] == "<="
        @offset += 2
        @col += 2
        ["<="]
      elsif @input[@offset, 2] == "<>"
        @offset += 2
        @col += 2
        ["<>"]
      elsif @input[@offset, 2] == ">="
        @offset += 2
        @col += 2
        [">="]
      elsif @input[@offset, 2] == ":="
        @offset += 2
        @col += 2
        [":="]
      elsif @input[@offset, 2] == ".."
        @offset += 2
        @col += 2
        [".."]
      elsif %w{. , : ; + - * / < = > ( ) [ ]}.include?(@input[@offset])
        token = @input[@offset]
        @offset += 1
        @col += 1
        [token]
      else
        raise "unexpected token #{@input[@offset]} at line #{@line} col #{@col}"
      end
    end
  end
end

parser = Pascual::Parser.new.parse(File.read(ARGV.first || "program.pas"))
# parser.dump
parser.simulate
