function NeighVar = FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,~) 

% disp(['Jobs: ',num2str(Jobs)])


cMachine = Var.Ass(Jobs(1)) ;

if numel(Jobs) == 1
    % Remove
    rr =Jobs ;
                 
    Var = RomoveJob(AlgParams, Var, Pr, cMachine, btch, rr) ;
    Var = EnergyHeuristic(Var,Pr,cMachine) ;
    
    for nMachine = AlterMachines
         
       
        
        % Insert  NewVar.mObj
        NewVar = InsertJob(AlgParams, Var, Pr, nMachine, rr) ;
        NewVar = EnergyHeuristic(NewVar,Pr,nMachine) ;
        

        if sum(sum(NewVar.mObj).*AlgParams.Penalty)  < sum(sum(NeighVar.mObj).*AlgParams.Penalty) 

            NeighVar = NewVar ; 
           
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
    if  sum(sum(NewVar.mObj).*AlgParams.Penalty) < sum(sum(NeighVar.mObj).*AlgParams.Penalty)
        NeighVar = NewVar ; 
    
    end
    
    
end

% if NeighVar.Pen>0
%     pause
% end