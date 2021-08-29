function Var = RemoveRout(Var,Pr)  
%  while 1
%  Var = Particle(i)  ;

nServed = sum(Var.Routs(1:Pr.Nv,:)'>0) ;
ActiveVs = find(nServed>0) ;
LowServs = nServed(ActiveVs) <= 2*(Pr.Nv-1)+1 ;
LowServs = ActiveVs(LowServs) ;


if isempty(LowServs)
    return
end

curntV = randi([1 numel(LowServs)],1,1) ;
curntV = LowServs(curntV) ;

Req = Var.Routs(curntV,1:sum(Var.Routs(curntV,:)>0)) ;
Req(Req>Pr.Np) = [] ; 

for pp = Req

    Removedpp = Var ;
    Routs = Removedpp.Routs(curntV,1:sum(Removedpp.Routs(curntV,:)>0)) ;
    Routs(Routs==pp) = [] ;
    Routs(Routs==pp+Pr.Np) = [] ;
    Removedpp.Routs(curntV,:) = 0 ;
    Removedpp.Routs(curntV,1:numel(Routs)) = Routs ; 
    Removedpp = ObjCal(Removedpp,Pr,curntV) ;
    
    PsblVcls = find(Pr.PsblVclforPss(pp,:)==1) ;
    PsblVcls(PsblVcls==curntV) = [] ;
    NoActives = find(sum(Var.Routs(1:Pr.Nv,:)'>0)==0) ;
    PsblVcls = setdiff(PsblVcls,NoActives) ;
    PsblVcls = PsblVcls(randperm(numel(PsblVcls))) ;

    for vv = PsblVcls
        NewVar = Insrt(Removedpp,Pr,vv,pp) ; 
        if sum(sum(NewVar.RoutObj(:,2:end))) == 0  
            Var = NewVar ;
            break
        end
    end
end

if sum(Var.Routs(curntV,:)>0)<2 
    Var.Routs(curntV,:) = 0 ;
end
 


