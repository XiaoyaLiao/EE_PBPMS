function [Pr, Var] = InitialSol(AlgParams, Pr) 

Var = [] ;
Var.S = zeros(1,Pr.Nj) ;
Var.C = zeros(1,Pr.Nj) ;
Var.W = zeros(1,Pr.Nj) ;

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

% The first solution is made by EDD with a seperate batch for each job
[~, Jobs] = sort(Pr.d);
btch = ones(1,Pr.Nj) ;
MachAvailablity = zeros(1,Pr.Nm);
for ii = Jobs
    [~, mm] = min(MachAvailablity);
    
    Var = InsertJob(AlgParams, Var, Pr, mm, ii) ;
   
    MachAvailablity(mm) = max(MachAvailablity(mm),Pr.R(ii)) + Pr.P(ii)/Pr.V(mm) ;
end

% Basic Scheduler
for mm = 1:Pr.Nm
    Var = Scheduler(Pr,Var,mm,1) ;
end

[TWT, TEC] = VariableShow(Var,Pr);
% Pr.MaxTEC = TEC;
% Pr.MaxTWT = max(TWT,10);
