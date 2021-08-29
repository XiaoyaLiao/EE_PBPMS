function Var = PreAssign(Pr,Var)

% for unserved requests
Assigned =  find(Var.Ass==Pr.Nv+1) ;
Rout = [Assigned Assigned+Pr.Np] ;
Var.Routs(Pr.Nv+1,:) = [Rout zeros(1,2*Pr.Np+1-numel(Rout))] ;
Var = ObjCal(Var,Pr,Pr.Nv+1) ;

% for served requests
for vv = 1:Pr.Nv
    Assigned =  find(Var.Ass==vv) ;
    H1 = Pr.CrtclPnt(Assigned) ;
    H2 = find(H1==0) ;
    H3 = Assigned(H2) ;
    Var.Priority(vv,H3) = min(Var.Priority(vv,H3),Var.Priority(vv,H3+Pr.Np)-0.005) ;
    
    H0 = Assigned+Pr.Np ;
    H1 = Pr.CrtclPnt(H0) ;
    H2 = find(H1==0) ;
    H3 = H0(H2);
    Var.Priority(vv,H3) = max(Var.Priority(vv,H3),Var.Priority(vv,H3-Pr.Np)+0.0005) ;

% a1 = Var.Priority(vv,Assigned) ; a2 = Var.Priority(vv,Assigned+Pr.Np) ;
% Var.Priority(vv,Assigned) = min(a1,a2) ;
% Var.Priority(vv,Assigned+Pr.Np) = max(a1,a2) ;

    Assigned = [Assigned Assigned+Pr.Np 2*Pr.Np+1] ;
    if numel(Assigned)==1
        continue
    end
    [~, Order] = sort(Var.Priority(vv,Assigned)) ;
    Assigned(end) = Pr.Brk(vv) ; 
    
    Rout = Assigned(Order) ;
    Var.Routs(vv,:) = [Rout zeros(1,2*Pr.Np+1-numel(Rout))] ;
    Var = ObjCal(Var,Pr,vv) ;
    
    Reqs = (Rout(Rout<=Pr.Np)) ;

    for ss = Reqs
        Var = ImprovePair(Var,Pr,vv,ss) ;
    end
    
    Var = ImproveBreak(Var,Pr,vv) ;
            
end