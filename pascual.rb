module Pascual
  class Emulator
    def load(file)
      @code = File.readlines(file, chomp: true).map do |line|
        instruction, argument = line.split(" ")
        if argument.nil?
          [instruction]
        else
          [instruction, argument.to_i]
        end
      end

      self
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
          offset.push(offset.last + instruction.last)
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
  end
end

parser = Pascual::Emulator.new.load(ARGV.first)
parser.simulate
