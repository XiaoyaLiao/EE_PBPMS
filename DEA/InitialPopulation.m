function Pop = InitialPopulation(AlgParams,Pr) 


Sol = []; 
Sol.Seq = [] ;

Var = [] ;
Var.S = zeros(1,Pr.Nj) ;
Var.C = zeros(1,Pr.Nj) ;

Var.Sb = cell(Pr.Nm,1) ;
Var.Cb = cell(Pr.Nm,1) ;
Var.Pb = cell(Pr.Nm,1) ;
Var.pFam = cell(Pr.Nm,1) ;
Var.pCap = cell(Pr.Nm,1) ;

Var.Seq = cell(Pr.Nm,1) ;
Var.Btch = zeros(1,Pr.Nj) ; 
Var.Ass = zeros(1,Pr.Nj) ; 

Var.mObj = inf(Pr.Nm,3) ; % 1.Objective, 2.Family, 3.Capacity
Var.Pen = 0 ;

Sol.Var = Var ;
Sol.Obj = inf ; 

Pop = repmat(Sol,1,AlgParams.PopSize);
for ii = 1:AlgParams.PopSize
    
    Pop(ii).Seq = randperm(Pr.Nj);
    
    Pop(ii) = ObjFunc(Pr,Pop(ii));
    
end


