function Var = LocalSearch(Var,Pr,nRouts)
% nRouts =1:Pr.Nv ;
% Var = Gbest ;


for vv = nRouts
    Rout = Var.Routs(vv,1:sum(Var.Routs(vv,:)>0)) ;
    if ~isempty(Rout)
        Req = Rout(Rout<=Pr.Np) ;

        for pp = Req
            NewVar = Var ;
            
            Rout = NewVar.Routs(vv,1:sum(NewVar.Routs(vv,:)>0)) ;
            Rout(Rout==pp) = [] ;
            Rout(Rout==pp+Pr.Np) = [] ;
            NewVar.Routs(vv,:) = 0 ;
            NewVar.Routs(vv,1:numel(Rout)) = Rout ;
            NewVar = Insrt(NewVar,Pr,vv,pp) ;
            if NewVar.Obj < Var.Obj
            	Var = NewVar ;
            end
        end
    end
end
    
    



