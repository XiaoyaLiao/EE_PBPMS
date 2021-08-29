function Var = ForwardMove(Var,Pr,vv,jj) 
% jj= Pr.DpS(vv) ;
% Var = OldVar ;

OldVar = Var ;
CompleteRout = [Pr.DpS(vv) Var.Routs(vv,1:sum(Var.Routs(vv,:)>0)) Pr.DpE(vv)] ;
Ind = find(CompleteRout==jj) ;
Nodes = CompleteRout(Ind:end) ;
Waits = Var.W(Nodes) ;
CumWait = [0 cumsum(Waits(2:end))] ;

HRout = Nodes(2:end-1) ;
HRout(HRout==Pr.Brk(vv)) = [] ;
Dsts = HRout(HRout> Pr.Np) ; 

Pj = zeros(1,Pr.N) ;
Pj(Dsts) = Var.B(Dsts)-Var.D(Dsts-Pr.Np) ;
UP = inf(1,Pr.N) ;
UP(Dsts) = Pr.UP(Dsts-Pr.Np) ;

Fj = min(CumWait + max(0,min(Pr.l(Nodes)-Var.B(Nodes),max(0,UP(Nodes)-Pj(Nodes)))) ) ;% max(0,UP(Nodes)-Pj(Nodes))

if jj > 2*Pr.Np
    Var.D(jj) = Pr.e(jj) + min(sum(CumWait), Fj) ;
else
    Var.B(jj) = Var.B(jj) + min(sum(CumWait), Fj) ;
    Var.D(jj) = Var.B(jj) + Pr.S(jj) ;
end
    
q = numel(Nodes) ;

for ip = 2:q
ii = Nodes(ip) ;
jj = Nodes(ip-1) ;

Var.A(ii) = Var.D(jj) + Pr.T(jj,ii)/Pr.SF(vv) ;
Var.B(ii) = max(Var.A(ii), Pr.e(ii)) ;
Var.D(ii) = max(Var.A(ii),Pr.e(ii)) + Pr.S(ii) ;
Var.W(ii) = max(0, Pr.e(ii) - Var.A(ii)) ;
if Var.D(ii) == OldVar.D(ii)
    break
end
end   


    
% aa =  [Var.A(Nodes)' Var.B(Nodes)' Var.D(Nodes)' Var.W(Nodes)'] 
% bb =  [OldVar.A(Nodes)' OldVar.B(Nodes)' OldVar.D(Nodes)' OldVar.W(Nodes)'] 

    

