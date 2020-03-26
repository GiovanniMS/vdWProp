using EngThermBase

include("dome.jl")

# creating a structure to van der Waals gases

struct vdWGas
    
    nome::String
    
    Pc::sysP{Float64,EX}
    
    Tc::sysT{Float64,EX}
    
    α::_Amt{Float64,EX}
    
    b::vAmt{Float64,EX,MA}
    
    M::mAmt{Float64,EX,MO}
    
    Rvdw::RAmt{Float64,EX,MA}
    
end

nome(gas::vdWGas) = gas.nome

Pc(gas::vdWGas) = gas.Pc

Tc(gas::vdWGas) = gas.Tc

α(gas::vdWGas) = gas.α

b(gas::vdWGas) = gas.b

M(gas::vdWGas) = gas.M

Rvdw(gas::vdWGas) = gas.R

vc(gas::vdWGas) = 3*gas.b

# Gas example

He = vdWGas("Helio", P(228.9945), T(5.21), P(1)*(v(1)^2)*0.21562534694033178, v(1)*0.005945540844366726, (N(1)^-1)*4.003,R(2.0769))

# Now the functions are implemented using the vdWGas as an argument

Tr(Tc::sysT{Float64,EX}, T::sysT{Float64,EX}) = T/Tc

Pr(Pc::sysP{Float64,EX}, P::sysP{Float64,EX}) = P/Pc

vr(vc::vAmt{Float64,EX,MA}, v::vAmt{Float64,EX,MA}) = v/vc

ur(u::uAmt{Float64,EX,MA}, Pc::sysP{Float64,EX}, vc::vAmt{Float64,EX,MA}) = u/(Pc*vc)

hr(h::hAmt{Float64,EX,MA}, Pc::sysP{Float64,EX}, vc::vAmt{Float64,EX,MA}) = h/(Pc*vc)

sr(s::sAmt{Float64,EX,MA}, Pc::sysP{Float64,EX}, vc::vAmt{Float64,EX,MA}, Tc::sysT{Float64,EX}) = (Tc*s)/(Pc*vc)

function P_vdw(gas::vdWGas, T::sysT{Float64,EX}, v::vAmt{Float64,EX,MA}) 
    
    if vr1list[findclosest(Tr_sat_list, Tr(Tc(gas), T), (10^-3))] <= vr(vc(gas), v) <= vr2list[findclosest(Tr_sat_list, Tr(Tc(gas), T), (10^-3))]
        
        return Pc(gas)*(Pr_sat_list[findclosest(Tr_sat_list, Tr(Tc(gas), T), (10^-3))])
    
    else 
        
        return Pc(gas)*(8*Tr(Tc(gas),T)/(3*vr(vc(gas),v) - 1) - 3/(vr(vc(gas),v)^2))
    
    end
    
end

function T_vdw(gas::vdWGas, P::sysT{Float64,EX}, v::vAmt{Float64,EX,MA})
    
    if vr1list[findclosest(Pr_sat_list, Pr(Pc(gas), P), (10^-3))] <= vr(vc(gas), v) <= vr2list[findclosest(Pr_sat_list, Pr(Pc(gas), P), (10^-3))]
        
        return Tc(gas)*(Tr_sat_list[findclosest(Pr_sat_list, Pr(Pc(gas), P), (10^-3))])
        
    else
        
        return Tc(gas)*(((Pr(Pc(gas), P)*(3*vr(vc(gas), v) - 1))/8) + (3/(8*(vr(vc(gas), v)^2))))
        
    end
    
end

function vr_vdw(gas::vdWGas, P::sysT{Float64,EX}, T::sysT{Float64,EX})
    
    vrvdw = roots(Poly([(-3/8),(9/8),(-Tr(Tc(gas), T) - (Pr(Pc(gas), P)/8)),(3*Pr(Pc(gas), P)/8)]))
    
    if vr1list[findclosest(Pr_sat_list, Pr(Pc(gas), P), (10^-3))] <= vrvdw <= vr2list[findclosest(Pr_sat_list, Pr(Pc(gas), P), (10^-3))]
        
        print("Error, T and P can only define a State outside the dome")
        
    else
        
        return vc(gas)*vrvdw
        
    end
    
end