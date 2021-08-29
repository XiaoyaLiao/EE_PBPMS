function Var = zzzzEnergyHeuristic(Var,Pr,mm)





% if Var.mObj(mm,2) + Var.mObj(mm,3) == 0
% 
%     while true
%     
%         NewVar = Var ;
%         CurrentComs = Var.Cb{mm}(1:end-1) ;
%         nMovableBtchs = numel(Var.Cb{mm})-1 ; 
%         ImpCheck = zeros(1,nMovableBtchs);
%         NewComs = zeros(1,nMovableBtchs);
% 
%         for  ChkBch = 1:nMovableBtchs
%             [NewComs(ChkBch),ImpCheck(ChkBch)] = MoveCheck(NewVar,Pr,mm,ChkBch, 1) ;   
%         end
%         DiffComs = NewComs - CurrentComs ;
%         if sum(ImpCheck) > 0 
%             Inds = find(ImpCheck==max(ImpCheck)); Ind =Inds(end) ;
%             Var = UpdateVar(Pr,NewVar,mm,Ind,NewComs(Ind)) ;
%         elseif sum(ImpCheck) == 0 && sum(DiffComs)>0
%             Inds = find(DiffComs==max(DiffComs)); Ind =Inds(end) ;
%             Var = UpdateVar(Pr,NewVar,mm,Ind,NewComs(Ind)) ;
%         else
%             break
%         end
%     end
%     
% end
