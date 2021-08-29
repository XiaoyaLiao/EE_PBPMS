% function NewVar = LSRmoveAdd(AlgParams,Var,NewVar,Pr,btch,Jobs,cMachine) 

%  Jobs = job ;

% Remove
% % Var = RomoveJob(AlgParams,Var, Pr, cMachine, btch, Jobs) ;
% % 
% % for rr = Jobs
% % 
% %     % Insert
% %     Var = InsertJob(AlgParams,Var, Pr, cMachine, rr) ;
% % 
% % end 
% % 
% %  sum(sum(Var.mObj).*AlgParams.Penalty) < sum(sum(NewVar.mObj).*AlgParams.Penalty) 
% % if Var.Obj <= NewVar.Obj
% %     NewVar = Var; 
% % end