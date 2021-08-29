function  NewVar = LocalSearch(Pr,Var,AlgParams)
% AslVar = Var;
% Var = AslVar ;

NewVar = Var ;

for cMachine = 1:Pr.Nm
    JobsOnMach = find(Var.Ass == cMachine) ; 
    
    
    while numel(Var.Sb{cMachine}) > 0
        btch = 1 ;
        rr = JobsOnMach(Var.Btch(JobsOnMach)==btch);
        Var = RomoveJob(AlgParams, Var, Pr, cMachine, btch, rr) ;
       
    end
   
    [~, order] = sort(Pr.P(JobsOnMach), 'descend') ;
        
    for rr = JobsOnMach(order)

        Var = InsertJob(AlgParams, Var, Pr, cMachine, rr) ;

    end 
      
end

if sum(sum(Var.mObj).*AlgParams.Penalty) < sum(sum(NewVar.mObj).*AlgParams.Penalty) 
    NewVar = Var ;
end

 
               