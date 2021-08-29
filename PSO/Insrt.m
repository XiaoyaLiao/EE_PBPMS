function Var = Insrt(Var,Pr,vv,pp) 
%Var = Removedpp ;


RL = sum(Var.Routs(vv,:)>0) ;
Rout = Var.Routs(vv,1:RL) ; 

if Pr.CrtclPnt(pp) == 1 
    jj = pp ;
else
    jj = pp + Pr.Np ;
end
A1 = Rout(Pr.l(Rout) < Pr.e(jj)) ;% [Pr.e(Rout)' Var.B(Rout)' Pr.l(Rout)'] 
if ~isempty(A1)
    A1=A1(end) ;
    p1 = find(Rout==A1)+1 ;
else
    p1 = 1 ;
end
A2 = Rout(Pr.e(Rout) > Pr.l(jj)) ; 
if ~isempty(A2)
    A2=A2(1) ;
    p2 = find(Rout==A2) ;
else
    p2 = RL + 1 ;
end
PsblPs = [p1 p2] ;
PsblPs = sort(PsblPs);
PsblPs = PsblPs(1):PsblPs(2) ;
nPsbl = numel(PsblPs) ;

OptionsVar = repmat(Var,1,nPsbl+1) ;
Options = zeros(1,nPsbl) ;

for ii = 1:nPsbl
    pos = PsblPs(ii);
    NewRout = [Rout(1:pos-1) pp pp+Pr.Np Rout(pos:end)] ;
    OptionsVar(ii).Routs(vv,:) = [NewRout zeros(1,2*Pr.Np+1-numel(NewRout))] ;
    OptionsVar(ii) = ObjCal(OptionsVar(ii),Pr,vv) ;
    Options(ii) = sum(OptionsVar(ii).RoutObj(vv,:)) ;
end
[~, BestPos] = min(Options) ;
Var = OptionsVar(BestPos) ;
%Var = ImprovePair(Var,Pr,vv,pp) ;

        

 