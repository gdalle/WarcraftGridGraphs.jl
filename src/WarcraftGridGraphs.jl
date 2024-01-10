module WarcraftGridGraphs

using LinearAlgebra
using SimpleWeightedGraphs
using SparseArrays

export warcraft_grid_graph, index_to_coord, coord_to_index

function warcraft_grid_graph(costs::AbstractMatrix{R}; acyclic::Bool=false) where {R}
    h, w = size(costs)
    V = h * w
    E = count_edges(h, w; acyclic)

    colptr = Int[]
    rowval = Int[]
    nzval = R[]
    sizehint!(colptr, V + 1)
    sizehint!(rowval, E)
    sizehint!(nzval, E)

    k = 1
    for v1 in 1:V
        push!(colptr, k)
        i1, j1 = index_to_coord(v1, h, w)
        for Δi in (-1, 0, 1), Δj in (-1, 0, 1)
            valid_step = Δi != 0 || Δj != 0
            if acyclic
                valid_step = valid_step && Δi >= 0 && Δj >= 0
            end
            if valid_step
                i2 = i1 + Δi
                j2 = j1 + Δj
                valid_destination = 1 <= i2 <= h && 1 <= j2 <= w
                if valid_destination
                    v2 = coord_to_index(i2, j2, h, w)
                    push!(rowval, v2)
                    push!(nzval, costs[v2])
                    k += 1
                end
            end
        end
    end
    push!(colptr, k)

    weights = transpose(SparseMatrixCSC(V, V, colptr, rowval, nzval))
    return SimpleWeightedDiGraph(weights)
end

function count_edges(h::Integer, w::Integer; acyclic::Bool)
    @assert h >= 2 && w >= 2
    if acyclic
        return (h - 1) * (w - 1) * 3 + ((h - 1) + (w - 1)) * 1 + 0
    else
        return (h - 2) * (w - 2) * 8 + (2(h - 2) + 2(w - 2)) * 5 + 4 * 3
    end
end

function possible_neighbors(i::Integer, j::Integer)
    return (
        # col - 1
        (i - 1, j - 1),
        (i + 0, j - 1),
        (i + 1, j - 1),
        # col 0
        (i - 1, j + 0),
        (i + 1, j + 0),
        # col + 1
        (i - 1, j + 1),
        (i + 0, j + 1),
        (i + 1, j + 1),
    )
end

function coord_to_index(i::Integer, j::Integer, h::Integer, w::Integer)
    if (1 <= i <= h) && (1 <= j <= w)
        v = (j - 1) * h + (i - 1) + 1  # enumerate column by column
        return v
    else
        return 0
    end
end

function index_to_coord(v::Integer, h::Integer, w::Integer)
    if 1 <= v <= h * w
        j = (v - 1) ÷ h + 1
        i = (v - 1) - h * (j - 1) + 1
        return (i, j)
    else
        return (0, 0)
    end
end

function get_path(parents::AbstractVector{<:Integer}, s::Integer, d::Integer)
    path = [d]
    v = d
    while v != s
        v = parents[v]
        pushfirst!(path, v)
    end
    return path
end

end
