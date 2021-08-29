function Var = BackMove(Var,Pr,nRouts) 

Var.RoutObj(nRouts,:) = zeros(numel(nRouts),6) ;
% 1:RoutCost, 2:Capacity, 3:Ride time, 4:rout duration, 5:Time window, 6:Unserved 

for vv = nRouts
    TempX = zeros(Pr.N,Pr.N) ;
    TempY = zeros(Pr.N,Pr.Nf) ;
    if vv == Pr.Nv+1 
        continue
    elseif sum(Var.Routs(vv,:))==0
        Rout = [Pr.DpS(vv) Var.Routs(vv,1:sum(Var.Routs(vv,:)>0)) Pr.DpE(vv)] ;
        Var.A(1,Rout) = 0 ;
        Var.B(1,Rout) = 0 ;
        Var.D(1,Rout) = 0 ;
        Var.W(1,Rout) = 0 ;
        continue
    end
    
    Rout = [Pr.DpS(vv) Var.Routs(vv,1:sum(Var.Routs(vv,:)>0)) Pr.DpE(vv)] ;
    Var.A(1,Rout) = 0 ;
    Var.B(1,Rout) = 0 ;
    Var.D(1,Rout) = 0 ;
    Var.W(1,Rout) = 0 ;


    for hh = 2:numel(Rout)
        ii = Rout(hh) ;
        jj = Rout(hh-1) ;
        
        if jj > 2*Pr.Np+2*Pr.Nv
            ja = Rout(hh-2) ;
        else
            ja = jj ;
        end
        
        TempX(ja,ii) = 1 ;
        Var.X(ja,ii,vv) = 1 ;
        Var.A(ii) = Var.D(jj) + Pr.T(ja,ii)/Pr.SF(vv) ;

        Var.B(ii) = max(Var.A(ii), Pr.e(ii)) ;
        Var.D(ii) = max(Var.A(ii),Pr.e(ii)) + Pr.S(ii) ;
        Var.W(ii) = max(0, Pr.e(ii) - Var.A(ii)) ;
        Var.Y(ii,:,vv) = Var.Y(jj,:,vv) + Pr.q(ii,:) ;
        TempY(ii,:) = TempY(jj,:) + Pr.q(ii,:) ;
    end
    
    Var.RoutObj(vv,1) = sum(sum(TempX.*Pr.C)) ; % Routing cost
    Var.RoutObj(vv,2) = sum(sum((-1).*min(Pr.MaxFonNodes(:,:,vv) - TempY,0))) ; % Capacity
  
    HRout = Rout(2:end-1) ;
    Orgs = HRout(HRout<=Pr.Np) ;
    Dsts = HRout(HRout> Pr.Np) ; 
    if numel(Orgs) < numel(Dsts)
        Dsts = Orgs + Pr.Np ;
    else
        Orgs = Dsts - Pr.Np ; 
    end


    Var.RoutObj(vv,3) = sum(max(0, Var.B(Dsts) - Var.D(Orgs) - Pr.UP(Orgs))) ; % Excess ride time
    Var.RoutObj(vv,4) = sum(max(0, Var.A(Pr.DpE(vv)) - Var.D(Pr.DpS(vv)) - Pr.UV(vv))) ; % Excess rout duration
    Var.RoutObj(vv,5) = sum(max(0, Var.A(Rout) - Pr.l(Rout))) ; % Time window violation

end
Var.RoutObj(Pr.Nv+1,end) = sum(Var.Routs(Pr.Nv+1,:)>0)/2 ; % Unserved requests
Var.RoutObj = repmat(Pr.Penaltiy,Pr.Nv+1,1).*Var.RoutObj ;     







