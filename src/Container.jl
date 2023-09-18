mutable struct Container{T} where {T<:AbsractStructure}
    k::Real
    Structures::Vector{T}
    Dipoles::Vector{Dipole}

    function Container(k::Real)
        new(k, AbsractStructure[], Dipole[])
    end
end

function Base.getproperty(C::Container, sym::Symbol)
    if sym in [:x, :y, :z, 
               :r, :θ, :ϕ, 
               :Px, :Py, :Pz, 
               :Eincx, :Eincy, :Eincz, 
               :αx, :αy, :αz,
               :P, :Einc, :α, :pos]
        return getproperty.(C.Dipoles, sym)
    else
        return getfield(C, sym)
    end
end

function Base.push!(C::Container, S::T) where T <: AbstractStructure
    push!(C.Structures, S)
    for dipole in S.Dipoles
        if ~(dipole in C.Dipoles)
            push!(C.Dipoles, dipole)
        else
            error("Dipole already exists, Can't push it to the container.")
        end
    end
end

function remove(C::Container, S::T) where {T<:AbstractStructure}
    deleteat!(C.Structures, findall(x->x==S, C.Structures))
    deleteat!(C.Dipoles,findall(x->x in S.Dipoles, C.Dipoles))
end

function reset_dipole(C::Container)
    for dip in C.Dipoles
        dip.Einc = SA[0. + 0im, 0. + 0im, 0. + 0im]
        dip.P = nothing
    end
end

get_Einc(C::T) where {T<:Union{Container,AbstractStructure}} = reduce(vcat, C.Einc)
get_P(C::T) where {T<:Union{Container,AbstractStructure}} = reduce(vcat, C.P)
get_α(C::T) where {T<:Union{Container,AbstractStructure}} = reduce(vcat, C.α)
