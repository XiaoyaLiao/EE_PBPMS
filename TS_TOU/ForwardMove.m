function [VarA,VarB,VarD,VarW] = ForwardMove(VarA,VarB,VarD,VarW,Pr,vv,jj,Nodes) 
% jj= Pr.DpS(vv) ;
% Var = OldVar ;


OldD = VarD ;

Waits = VarW(Nodes) ;
CumWait = [0 cumsum(Waits(2:end))] ;

HRout = Nodes(2:end-1) ;
HRout(HRout==Pr.Brk(vv)) = [] ;
Dsts = HRout(HRout> Pr.Np) ; 

Pj = zeros(1,Pr.N) ;
Pj(Dsts) = VarB(Dsts)-VarD(Dsts-Pr.Np) ;
UP = inf(1,Pr.N) ;
UP(Dsts) = Pr.UP(Dsts-Pr.Np) ;

Fj = min(CumWait + max(0,min(Pr.l(Nodes)-VarB(Nodes),max(0,UP(Nodes)-Pj(Nodes)))) ) ;% max(0,UP(Nodes)-Pj(Nodes))

if jj > 2*Pr.Np
    VarD(jj) = Pr.e(jj) + min(sum(CumWait), Fj) ;
else
    VarB(jj) = VarB(jj) + min(sum(CumWait), Fj) ;
    VarD(jj) = VarB(jj) + Pr.S(jj) ;
end
    
q = numel(Nodes) ;

for ip = 2:q
ii = Nodes(ip) ;
jj = Nodes(ip-1) ;

VarA(ii) = VarD(jj) + Pr.T(jj,ii)/Pr.SF(vv) ;
VarB(ii) = max(VarA(ii), Pr.e(ii)) ;
VarD(ii) = max(VarA(ii),Pr.e(ii)) + Pr.S(ii) ;
VarW(ii) = max(0, Pr.e(ii) - VarA(ii)) ;
if VarD(ii) == OldD(ii)
    break
end
end   


    
% aa =  [VarA(Nodes)' VarB(Nodes)' VarD(Nodes)' VarW(Nodes)'] 
% bb =  [OldVarA(Nodes)' OldVarB(Nodes)' OldVarD(Nodes)' OldVarW(Nodes)'] 

    

