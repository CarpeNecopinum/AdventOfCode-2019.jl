using OffsetArrays
using BenchmarkTools

function run_instruction!(memory, iptr)
    opcode = memory[iptr]
    digs = digits(opcode; pad = 4)

    if digs[1] == 1 # addition
        op1 = memory[memory[iptr+1]]
        op2 = memory[memory[iptr+2]]
        memory[memory[iptr+3]] = op1 + op2
        return iptr + 4
    elseif digs[1] == 2 # multiply
        op1 = memory[memory[iptr+1]]
        op2 = memory[memory[iptr+2]]
        memory[memory[iptr+3]] = op1 * op2
        return iptr + 4
    elseif digs[1] == 3 # input
        memory[memory[iptr+1]] = 1
        return iptr + 2
    elseif digs[1] == 9 && digs[2] == 9 # halt
        return length(memory) + 1
    end
    println("Unknown instruction")
    return length(memory) + 1
end

function run_program!(program)
    iptr = 0
    while iptr in eachindex(program)
        iptr = run_instruction!(program, iptr)
    end
    program
end

function set_alarmstate!(program, noun = 12, verb = 2)
    program[1] = noun
    program[2] = verb
    program
end

function find_input(program, target_output)
    for noun in 0:99
        for verb in 0:99
            run_copy = copy(program)
            set_alarmstate!(run_copy, noun, verb)
            if (run_program!(run_copy)[0] == target_output)
                return 100 * noun + verb
            end
        end
    end
end

input = OffsetArray([1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,6,19,1,19,5,23,2,13,23,27,1,10,27,31,2,6,31,35,1,9,35,39,2,10,39,43,1,43,9,47,1,47,9,51,2,10,51,55,1,55,9,59,1,59,5,63,1,63,6,67,2,6,67,71,2,10,71,75,1,75,5,79,1,9,79,83,2,83,10,87,1,87,6,91,1,13,91,95,2,10,95,99,1,99,6,103,2,13,103,107,1,107,2,111,1,111,9,0,99,2,14,0,0], -1)

@btime run_program!(set_alarmstate!(copy(input)))[0] # part 1
@btime find_input(input, 19690720) # part 2
