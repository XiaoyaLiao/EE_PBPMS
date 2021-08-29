function Var = ObjCal(Var,Pr,nRouts)
%   nRouts=1:Pr.Nv+1;
%   Var = Gbest ;

Var.RoutObj(nRouts,:) = zeros(numel(nRouts),6) ;

% 1:RoutCost, 2:Capacity, 3:Ride time, 4:rout duration, 5:Time window, 6:Unserved 
for vv = nRouts

    TempX = zeros(Pr.N,Pr.N) ;
    TempY = zeros(Pr.N,Pr.Nf) ;
    if vv == Pr.Nv+1 
        continue
    elseif sum(Var.Routs(vv,:))==0
            Rout = [Pr.DpS(vv) Pr.DpE(vv)] ;
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
    
    Var.D(Pr.DpS(vv)) = Pr.e(Pr.DpS(vv)) ;
    
    for hh = 2:numel(Rout)
        ii = Rout(hh) ;
        jj = Rout(hh-1) ;
        if jj > 2*Pr.Np+2*Pr.Nv
            ja = Rout(hh-2) ;
        else
            ja = jj ;
        end
        % [Pr.e(Rout)' Var.A(Rout)' Var.D(Rout)' Pr.l(Rout)']
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
    HRout(HRout==Pr.Brk(vv)) = [] ;
    Orgs = HRout(HRout<=Pr.Np) ;
    Dsts = HRout(HRout> Pr.Np) ; 
    GoForward = numel(Orgs) == numel(Dsts) ;
    

    %% Forward time slack
    if GoForward == 1 && all(Var.A(Rout) <= Pr.l(Rout)) && Var.RoutObj(vv,2)== 0
        Var = ForwardMove(Var,Pr,vv,Pr.DpS(vv)) ; 
        if any(Var.B(Dsts) - Var.D(Orgs) > Pr.UP(Orgs))
            for jp = 1:numel(Orgs)
                jj = Orgs(jp) ;
                Var = ForwardMove(Var,Pr,vv,jj) ;  
                RemaindRout = Rout(find(Rout==jj):end-1) ;
                RemaindRout(RemaindRout==Pr.Brk(vv)) = [] ;
                RemaindDsts = RemaindRout(RemaindRout>Pr.Np) ;
                if all(Var.B(RemaindDsts) - Var.D(RemaindDsts-Pr.Np) <= Pr.UP(RemaindDsts-Pr.Np))
                    break
                end
            end
        end
    end
    Var.RoutObj(vv,3) = sum(max(0, Var.B(Dsts) - Var.D(Orgs) - Pr.UP(Orgs))) ; % Excess ride time
    Var.RoutObj(vv,4) = sum(max(0, Var.A(Pr.DpE(vv)) - Var.D(Pr.DpS(vv)) - Pr.UV(vv))) ; % Excess rout duration
    Var.RoutObj(vv,5) = sum(max(0, Var.A(Rout) - Pr.l(Rout))) ; % Time window violation

    Var.Priority(:,HRout) = (Var.B(HRout)./Pr.H).*ones(Pr.Nv,1) ;
    Var.Priority(:,end) = (Var.B(Pr.Brk(vv))./Pr.H).*ones(Pr.Nv,1) ;
end
Var.RoutObj(Pr.Nv+1,end) = sum(Var.Routs(Pr.Nv+1,:)>0)/2 ; % Unserved requests
Var.RoutObj = repmat(Pr.Penaltiy,Pr.Nv+1,1).*Var.RoutObj ;     
Var.RoutObj(:,2:end) = round(Var.RoutObj(:,2:end),3) ;


UsedVehicles = Var.Routs(1:Pr.Nv,1)'>0 ;
Srved = ones(1,Pr.Np) ;
Unserved = Var.Routs(end,1:sum(Var.Routs(end,:)>0)) ;
Unserved(Unserved>Pr.Np) = [] ;
Srved(Unserved) = 0 ;
Obj1 = sum(Pr.Fare.*Srved) -  sum(Var.RoutObj(:,1)) - sum(UsedVehicles.*Pr.F)  - (sum(sum(Var.RoutObj(:,2:end-1)))>0)*10000  ;
Obj1 = -Obj1 ; 

nSrved = find(Srved==1) ;
LeastRT = (Pr.T(nSrved+ (Pr.Dst(nSrved)-1).*size(Pr.T,1)))/max(Pr.SF) ;
EsxtraRT = (Var.A(Pr.Dst(nSrved)) - Var.D(nSrved) - LeastRT)  ; 

Obj2 =  sum(EsxtraRT)  + (sum(sum(Var.RoutObj(:,2:end-1)))>0)*10000 ;
Var.Obj = Obj2;%[Obj1 Obj2] ;

