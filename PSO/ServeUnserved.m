function Var = ServeUnserved(Var,Pr) 

if sum(Var.Routs(Pr.Nv+1,1)>0) 
    Req = Var.Routs(Pr.Nv+1,1:sum(Var.Routs(Pr.Nv+1,:)>0)) ;
    Req(Req>Pr.Np) = [] ; 
    
    for pp = Req

        Removedpp = Var ;
        Routs = Removedpp.Routs(Pr.Nv+1,1:sum(Removedpp.Routs(Pr.Nv+1,:)>0)) ;
        Routs(Routs==pp) = [] ;
        Routs(Routs==pp+Pr.Np) = [] ;
        Removedpp.Routs(Pr.Nv+1,:) = 0 ;
        Removedpp.Routs(Pr.Nv+1,1:numel(Routs)) = Routs ; 
        
        PsblVcls = find(Pr.PsblVclforPss(pp,:)==1) ;
        PsblVcls(PsblVcls==Pr.Nv+1) = [] ;
        PsblVcls = PsblVcls(randperm(numel(PsblVcls))) ;
        
        for vv = PsblVcls
            NewVar = Insrt(Removedpp,Pr,vv,pp) ; 
            if NewVar.Obj < Var.Obj 
                Var = NewVar ;
                break
            end
        end
    end
end

