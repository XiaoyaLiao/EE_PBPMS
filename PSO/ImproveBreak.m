function Var = ImproveBreak(Var,Pr,vv) 
%Var = Particle(1) ;

posb = find(Var.Routs(vv,:)==Pr.Brk(vv)) ;
RL = sum(Var.Routs(vv,:)>0) ;
Options = inf(1,2*Pr.Np+1) ;
OptionsVar = repmat(Var,1,2*Pr.Np+1) ; 
Rout = Var.Routs(vv,1:RL) ; 


Options(posb) = sum(Var.RoutObj(vv,:)) ;
OptionsVar(posb) = Var ;
Rout(Rout==Pr.Brk(vv)) = [] ;
A1 = Rout(Pr.l(Rout) >= Pr.e(Pr.Brk(vv))) ;
A2 = Rout(Pr.e(A1) <= Pr.l(Pr.Brk(vv))) ;

if isempty(A2)
    return
end

p1 = find(Rout==A2(1)) ;
p2 = find(Rout==A2(end)) ;


for nn =[p1:posb-1  posb+1:p2+1] % [p1:p2+1]%
    OptionsVar(nn).Routs(vv,:) = [Rout(1:nn-1) Pr.Brk(vv) Rout(nn:end) zeros(1,2*Pr.Np+1-numel(Rout)-1)] ;
    OptionsVar(nn) = ObjCal(OptionsVar(nn),Pr,vv) ;
    Options(nn) = sum(OptionsVar(nn).RoutObj(vv,:)) ;
end
    
[~, Bst] = min(Options) ;
Var = OptionsVar(Bst) ;

Rout = Var.Routs(vv,1:RL) ;
ModifRout  = min(Rout,2*Pr.Np+1) ;
if Bst == RL
    prvs = ModifRout(RL-1) ;
    Var.Priority(vv,end) = Var.Priority(vv,prvs) + 0.005;
elseif Bst == 1 
    nxt = ModifRout(2) ;
    Var.Priority(vv,end) = Var.Priority(vv,nxt) - 0.005;
else
    prvs = ModifRout(Bst-1) ;
    nxt = ModifRout(Bst+1) ;
    Var.Priority(vv,end) = sum(Var.Priority(vv,[prvs nxt]))/2 ;
end


