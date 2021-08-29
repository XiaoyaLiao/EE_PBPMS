function [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,~) 

% disp(['Jobs: ',num2str(Jobs)])


cMachine = Var.Ass(Jobs(1)) ;

if numel(Jobs) == 1
    % Remove
    rr =Jobs ;
                 
    Var = RomoveJob(AlgParams, Var, Pr, cMachine, btch, rr) ;
    Var = EnergyHeuristic(Var,Pr,cMachine) ;
    
    for nMachine = AlterMachines
         
        if any(TabuList == (nMachine-1)*Pr.Nj + rr)
            continue
        end
        
        % Insert  NewVar.mObj
        NewVar = InsertJob(AlgParams, Var, Pr, nMachine, rr) ;
        NewVar = EnergyHeuristic(NewVar,Pr,nMachine) ;
        
        NewVar.Pen = (sum(sum(NewVar.mObj).*AlgParams.Penalty) >= sum(sum(NeighVar.mObj).*AlgParams.Penalty)) * AlgParams.Ro * mean(AlgParams.Ferquency((NewVar.Ass(Jobs)-1)*Pr.Nj + Jobs)) * sqrt(Pr.Nj*Pr.Nm) * sum(NewVar.mObj(nMachine,1)) ;

        if sum(sum(NewVar.mObj).*AlgParams.Penalty) + NewVar.Pen < sum(sum(NeighVar.mObj).*AlgParams.Penalty) + NeighVar.Pen
%             if NewVar.Pen > 0
%                 pause
%             end
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