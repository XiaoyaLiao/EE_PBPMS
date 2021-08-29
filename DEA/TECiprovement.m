function Pop = TECiprovement(AlgParams, Pr, Pop) 

for ii = 1:AlgParams.PopSize
    
    for mm = 1:Pr.Nm
       Var = Pop(ii).Var ;
       ChkBch = numel(Var.Cb{mm})-1 ;

        while ChkBch > 0
            NewVar = Var ;
            [NewCompletion,Improve] = MoveCheck(NewVar,Pr,mm,ChkBch, 1) ;
            
            if Improve > 0
                Var = UpdateVar(Pr,NewVar,mm,ChkBch,NewCompletion) ;       
            end   
            ChkBch = ChkBch - 1 ;
        end
        
    end
    
end




