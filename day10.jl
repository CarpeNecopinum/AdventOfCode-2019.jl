input = """
.#..#..##.#...###.#............#.
.....#..........##..#..#####.#..#
#....#...#..#.......#...........#
.#....#....#....#.#...#.#.#.#....
..#..#.....#.......###.#.#.##....
...#.##.###..#....#........#..#.#
..#.##..#.#.#...##..........#...#
..#..#.......................#..#
...#..#.#...##.#...#.#..#.#......
......#......#.....#.............
.###..#.#..#...#..#.#.......##..#
.#...#.................###......#
#.#.......#..####.#..##.###.....#
.#.#..#.#...##.#.#..#..##.#.#.#..
##...#....#...#....##....#.#....#
......#..#......#.#.....##..#.#..
##.###.....#.#.###.#..#..#..###..
#...........#.#..#..#..#....#....
..........#.#.#..#.###...#.....#.
...#.###........##..#..##........
.###.....#.#.###...##.........#..
#.#...##.....#.#.........#..#.###
..##..##........#........#......#
..####......#...#..........#.#...
......##...##.#........#...##.##.
.#..###...#.......#........#....#
...##...#..#...#..#..#.#.#...#...
....#......#.#............##.....
#......####...#.....#...#......#.
...#............#...#..#.#.#..#.#
.#...#....###.####....#.#........
#.#...##...#.##...#....#.#..##.#.
.#....#.###..#..##.#.##...#.#..##
"""

astmap = first.(reduce(hcat, split.(split(input), "")))
asteroids = [Tuple(i) .- 1 for i in CartesianIndices(astmap) if astmap[i] == '#']

#--- Part 1

function inclination(from, to)
    d = to .- from
    atan(d[2], d[1])
end

function best_base(asteroids)
    num_visible(ast) = length(unique(inclination(ast, other) for other in asteroids)) -1
    maximum((num_visible(ast), ast) for ast in asteroids)
end

using BenchmarkTools
@btime best_base(asteroids)

#--- Part 2

using LinearAlgebra: norm

"""
    Return a Dict of angle => (distance, asteroid_index) that contains all
    asteroids currently visible from `base`
"""
function visible_asteroids(asteroids, base)
    dict = Dict{Float64,Tuple{Float64,Int}}()
    for (i,ast) in enumerate(asteroids)
        relative = ast .- base
        angle = atan(relative[1], -relative[2])
        angle >= 0.0 || (angle += 2π)
        #angle = atan(relative[2], relative[1])
        distance = norm(relative)
        old = get(dict, angle, (Inf64, 0))
        if distance < old[1]
            dict[angle] = (distance, i)
        end
    end
    dict
end


function vaporization_order(asteroids, laser)
    temp_asts = filter(x->x!=laser, asteroids)
    result = Tuple{Int,Int}[]

    while !isempty(temp_asts)
        targets = visible_asteroids(temp_asts, laser) |> sort
        target_indices = map(x->x[2], values(targets))
        append!(result, temp_asts[target_indices])
        deleteat!(temp_asts, sort!(target_indices))
    end
    result
end


base_position = (23, 29)
order = vaporization_order(asteroids, base_position)
order[200] |> (x->100*x[1] + x[2])
