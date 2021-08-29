function  NewVar = LocalSearch(Pr,Var,AlgParams)
% Var = AslVar ;

NewVar = Var ;

for cMachine = 1:Pr.Nm
    JobsOnMach = [Var.Seq{cMachine}] ; 
    for btch = 1:numel(Var.Sb{cMachine})
        JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);
        
        [~, order] = sort(Pr.P(JobOnBch), 'descend') ;
        
        for rr = JobOnBch(order)
           
            Var = RomoveJob(AlgParams, Var, Pr, cMachine, btch, rr) ;
            Var = InsertJob(AlgParams, Var, Pr, cMachine, rr) ;
            
        end 
    end  
end

if sum(sum(Var.mObj).*AlgParams.Penalty) < sum(sum(NewVar.mObj).*AlgParams.Penalty) 
    NewVar = Var ;
end

 
               