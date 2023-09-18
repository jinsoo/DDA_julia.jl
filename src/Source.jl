abstract type AbstractSource
end

function CalEinc(D::Dipole, S::T) where {T<:AbstractSource}
    D.Einc += S.Green(D.pos)
end

function CalEinc(R::Recorder, S::T) where {T<:AbstractSource}
    R.E += S.Green(R.pos)
end

function CalEinc(Rec::Array{Recorder}, S::T) where {T<:AbstractSource}
    for R in Rec
        R.E += S.Green(R.pos)
    end
end

function CalEinc(str::Union{Structure,Container}, S::T) where {T<:AbstractSource}
    for D in str.Dipoles
        CalEinc(D, S)
    end
end

struct PlaneWave <: AbstractSource
    Green :: Function
end 

function PlaneWave(k::SVector{3}, 𝔼inc::SVector{3}; r0=SA[0., 0., 0.])
    function Green(r::SVector{3})
        disp = displacement(r, r0)
        return 𝔼inc .* exp(1im .* (k ⋅ disp))
    end
    return PlaneWave(Green)
end

struct DipoleSource <: AbstractSource
    Green :: Function
end

function DipoleSource(k, r0::SVector{3}, 𝔼inc::SVector{3})
    function Green(r::SVector{3})
        D = Dipole(r0, α=SA[1,1,1])
        R = Recorder(r)
        G = GreenTensor(k, D, R)
        return G * 𝔼inc
    end
    return DipoleSource(Green)
end
