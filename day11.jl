using OffsetArrays
using BenchmarkTools

struct ExtendedMemory{T}
    base::OffsetArray{T, 1, Array{T,1}}
    rest::Dict{T,T}
end
ExtendedMemory(base::AbstractArray{T}) where {T} = ExtendedMemory{T}(base, Dict{T,T}())

Base.getindex(mem::ExtendedMemory, idx) = (idx in eachindex(mem.base)) ?
    mem.base[idx] :
    get(mem.rest, idx, 0)

Base.setindex!(mem::ExtendedMemory, val, idx) = (idx in eachindex(mem.base)) ?
    setindex!(mem.base, val, idx) :
    setindex!(mem.rest, val, idx)

function run_instruction!(memory, iptr, relbase, inputs, output)
    opcode = memory[iptr]
    digs = digits(opcode; pad = 5)
    input_index = 1

    get_op(mode, address) = if mode == 0
        memory[memory[address]]
    elseif mode == 1
        memory[address]
    elseif mode == 2
        memory[relbase[] + memory[address]]
    end

    set_op(mode, address, value) = if mode == 0
        memory[memory[address]] = value
    elseif mode == 2
        memory[relbase[] + memory[address]] = value
    end

    if digs[1] == 1 # addition
        result = get_op(digs[3], iptr+1) + get_op(digs[4], iptr+2)
        set_op(digs[5], iptr + 3, result)
        return iptr + 4
    elseif digs[1] == 2 # multiply
        result = get_op(digs[3], iptr+1) * get_op(digs[4], iptr+2)
        set_op(digs[5], iptr + 3, result)
        return iptr + 4
    elseif digs[1] == 3 # input
        read = popfirst!(inputs)
        set_op(digs[3], iptr + 1, read)
        return iptr + 2
    elseif digs[1] == 4 # output
        push!(output, get_op(digs[3], iptr + 1))
        return iptr + 2
    elseif digs[1] == 5 # jump if true
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        return (op1 != 0) ? op2 : (iptr + 3)
    elseif digs[1] == 6 # jump if false
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        return (op1 == 0) ? op2 : (iptr + 3)
    elseif digs[1] == 7 # less than
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        set_op(digs[5], iptr+3, (op1 < op2))
        return iptr + 4
    elseif digs[1] == 8 # equals
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        set_op(digs[5], iptr+3, (op1 == op2))
        return iptr + 4
    elseif digs[1] == 9
        if digs[2] == 9 # halt
            return -1
        elseif digs[2] == 0 # set relbase
            op1 = get_op(digs[3], iptr+1)
            relbase[] += op1
            return iptr + 2
        end
    end
    println("Unknown instruction $(digs)")
    return -1
end

function run_program!(program, inputs, outputs)
    iptr = 0
    relbase = Ref(0)
    while iptr >= 0
        iptr = run_instruction!(program, iptr, relbase, inputs, outputs)
    end
end

mutable struct Turtle
    panels::Dict{Tuple{Int,Int},Int8}
    direction::Tuple{Int,Int}
    position::Tuple{Int,Int}
    next::Symbol
end

Turtle() = Turtle(Dict(), (0,-1), (0,0), :paint)

function Base.push!(turt::Turtle, input)
    if turt.next === :paint
        turt.panels[turt.position] = input
        turt.next = :turn
    elseif turt.next === :turn
        if input == 0 # turn left
            turt.direction = (turt.direction[2], -turt.direction[1])
        elseif input == 1 # turn right
            turt.direction = (-turt.direction[2], turt.direction[1])
        else
            println("Turtle can't understand input $input")
        end
        turt.position = turt.position .+ turt.direction
        turt.next = :paint
    end
end

Base.popfirst!(turt::Turtle) = get(turt.panels, turt.position, 0)


#--- Input parsing

input = open(f->read(f,String), joinpath(@__DIR__, "day_11_input.txt")) |>
    (x->split(x, ",")) .|>
    (x->parse(Int,x))

#--- Part 1

turtle = Turtle()
mem = ExtendedMemory(OffsetArray(copy(input),-1))
run_program!(mem, turtle, turtle)
length(turtle.panels)

#--- Part 2

turtle = Turtle()
turtle.panels[(0,0)] = 1
mem = ExtendedMemory(OffsetArray(copy(input),-1))
run_program!(mem, turtle, turtle)


# determine bounding box of the painted panels
second(x) = x[2]
by, bx = extrema(first.(keys(turtle.panels))), extrema(second.(keys(turtle.panels)))


canvas = fill(' ', by[1]:by[2], bx[1]:bx[2])
for (coord, val) in pairs(turtle.panels)
    canvas[coord...] = (' ', '█')[val + 1]
end
println(join(reduce(*, canvas; dims = 1), '\n'))
