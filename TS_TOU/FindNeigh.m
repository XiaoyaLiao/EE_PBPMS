function [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,GroupMove) 
%        [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,LongestJobs,SlctdJob,SlctdMch,AlterMachines,1) ;
%        [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,0)

% AsliVar = Var ;

% Var = AsliVar ;
%  Jobs = LongestJobs ;
%  GroupMove = 1 ;

cMachine = Var.Ass(Jobs(1)) ;

if GroupMove == 0
    % Remove
    rr =Jobs ;
                 
    Var = RomoveJob(AlgParams, Var, Pr, cMachine, btch, rr) ;  % remove rr from btch on cMachine directly
    Var = EnergyHeuristic(Var,Pr,cMachine) ;  % EH used here!!
    
    for nMachine = AlterMachines  % try each possible machines
        
        % Insert  NewVar.mObj
        NewVar = InsertJob(AlgParams, Var, Pr, nMachine, rr) ;
        NewVar = EnergyHeuristic(NewVar,Pr,nMachine) ;  % EH used here!!
        
        % ?? why function mean() is used here?
        NewVar.Pen = (sum(sum(NewVar.mObj).*AlgParams.Penalty) >= sum(sum(NeighVar.mObj).*AlgParams.Penalty)) * AlgParams.Ro * mean(AlgParams.Ferquency((NewVar.Ass(Jobs)-1)*Pr.Nj + Jobs)) * sqrt(Pr.Nj*Pr.Nm) * sum(NewVar.mObj(nMachine,1)) ;

        if sum(sum(NewVar.mObj).*AlgParams.Penalty) + NewVar.Pen < sum(sum(NeighVar.mObj).*AlgParams.Penalty) + NeighVar.Pen
            if NewVar.Pen > 0
                pause
            end
            NeighVar = NewVar ; 
            SlctdJob = rr ;
            SlctdMch = nMachine ;
        end
    end
    
else
    
    
    % Remove
    
    Var = RomoveJob(AlgParams,Var, Pr, cMachine, btch, Jobs) ;
    Var = EnergyHeuristic(Var,Pr,cMachine) ;
    
    % sum(sum(Var.mObj).*AlgParams.Penalty)    
    for rr = Jobs       % NewVar.mObj
        
        NewVarSelected = Var ;
        Buff = inf ; 
        for nMachine = AlterMachines
            
            % Insert
            NewVar = InsertJob(AlgParams,Var, Pr, nMachine, rr) ;
            NewVar = EnergyHeuristic(NewVar,Pr,nMachine) ;
            
            if  sum(sum(NewVar.mObj).*AlgParams.Penalty) < Buff
                NewVarSelected = NewVar;
                Buff = sum(sum(NewVarSelected.mObj).*AlgParams.Penalty) ;
            end
        end
       Var =  NewVarSelected ;
    end 
    
    NewVar = Var ;
    NewVar.Pen = (sum(sum(NewVar.mObj).*AlgParams.Penalty) >= sum(sum(NeighVar.mObj).*AlgParams.Penalty)) * AlgParams.Ro * mean(AlgParams.Ferquency((NewVar.Ass(Jobs)-1)*Pr.Nj + Jobs)) * sqrt(Pr.Nj*Pr.Nm) * sum(NewVar.mObj()) ;
    if  sum(sum(NewVar.mObj).*AlgParams.Penalty) + NewVar.Pen < sum(sum(NeighVar.mObj).*AlgParams.Penalty) + NeighVar.Pen
        NeighVar = NewVar ; 
        SlctdJob = Jobs ;
        SlctdMch = Var.Ass(Jobs) ;
    end
    
    
end

% if NeighVar.Pen>0
%     pause
% end