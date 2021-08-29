function Var = ImprovePair(Var,Pr,vv,ss) 
%Var = Particle(1) ;

poso = find(Var.Routs(vv,:)==ss) ;
posd = find(Var.Routs(vv,:)==ss+Pr.Np) ;
RL = sum(Var.Routs(vv,:)>0) ;
Options = inf(1,2*Pr.Np+1) ;
OptionsVar = repmat(Var,1,2*Pr.Np+1) ; 
Rout = Var.Routs(vv,1:RL) ; % [Pr.e(Rout)' Var.A(Rout)' Var.D(Rout)' Pr.l(Rout)']
if Pr.CrtclPnt(ss)==1
    jj = ss+Pr.Np ;
    Options(posd) = sum(Var.RoutObj(vv,:)) ;
    OptionsVar(posd) = Var ;
    Rout(Rout==ss+Pr.Np) = [] ;
    for nn = [poso+1:posd-1  posd+1:RL]
        OptionsVar(nn).Routs(vv,:) = [Rout(1:nn-1) ss+Pr.Np Rout(nn:end) zeros(1,2*Pr.Np+1-numel(Rout)-1)] ;
        OptionsVar(nn) = ObjCal(OptionsVar(nn),Pr,vv) ;
        Options(nn) = sum(OptionsVar(nn).RoutObj(vv,:)) ;
        if OptionsVar(nn).B(Pr.Dst(ss)) - OptionsVar(nn).D(ss) - Pr.UP(ss) > 0
            break
        end
    end

else
    Options(poso) = sum(Var.RoutObj(vv,:)) ;
    OptionsVar(poso) = Var ;
    Rout(Rout==ss) = [] ;
    for nn = [posd-1:-1:poso+1 poso-1:-1:1] 
        OptionsVar(nn).Routs(vv,:) = [Rout(1:nn-1) ss Rout(nn:end) zeros(1,2*Pr.Np+1-numel(Rout)-1)] ;
        OptionsVar(nn) = ObjCal(OptionsVar(nn),Pr,vv) ;
        Options(nn) = sum(OptionsVar(nn).RoutObj(vv,:)) ;
        if OptionsVar(nn).B(Pr.Dst(ss)) - OptionsVar(nn).D(ss) - Pr.UP(ss) > 0
            break
        end
    end 
    jj = ss ;
end
[~, Bst] = min(Options) ;
Var = OptionsVar(Bst) ;
Rout = Var.Routs(vv,1:RL) ;

ModifRout  = min(Rout,2*Pr.Np+1) ;
if Bst == RL
    prvs = ModifRout(RL-1) ;
    Var.Priority(vv,jj) = Var.Priority(vv,prvs) + 0.005;
elseif Bst == 1 
    nxt = ModifRout(2) ;
    Var.Priority(vv,jj) = Var.Priority(vv,nxt) - 0.005;
else
    prvs = ModifRout(Bst-1) ;
    nxt = ModifRout(Bst+1) ;
    Var.Priority(vv,jj) = sum(Var.Priority(vv,[prvs nxt]))/2 ;
end


