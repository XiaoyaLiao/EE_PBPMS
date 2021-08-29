function [eOpration,eStabdby] = TECcal(Var,Pr,mm) 

FirstIntrval = 1;
while Var.Sb{1} >= Pr.I(FirstIntrval+1)
    FirstIntrval = FirstIntrval + 1 ;
end

eOpration = 0 ;
eStabdby = 0 ;
bb = 1 ; 
nBatches = numel(Var.Sb{mm}) ;
while bb <= nBatches
    eOpration = eOpration + Pr.gama(FirstIntrval)*Pr.beta1(mm)* max(0, min(Pr.I(FirstIntrval+1),Var.Cb{mm}(bb)) - max(Var.Sb{mm}(bb),Pr.I(FirstIntrval))) ;
    
    if bb < nBatches
        eStabdby = eStabdby + Pr.gama(FirstIntrval)*Pr.beta2(mm)* max(0, max(Pr.I(FirstIntrval),Var.Sb{mm}(bb+1)) - min(Var.Cb{mm}(bb),Pr.I(FirstIntrval+1))) ; 
    end
    
    if Var.Cb{mm}(bb) < Pr.I(FirstIntrval+1)
        bb = bb + 1 ;
    else
        FirstIntrval = FirstIntrval + 1 ;
    end
    
end



% eStabdby = 0 ;
% eSwitch = Pr.beta3(mm)*~isempty(JobsOnMach) ;
% if numel(Var.Cb{mm})>1
%     Wating = Var.Sb{mm}(2:end) - Var.Cb{mm}(1:end-1) ;
%     eStabdby = eStabdby + sum((Wating<=Pr.to(mm)).*Wating.*Pr.beta2(mm)) ;
%     eSwitch = eSwitch + sum((Wating>Pr.to(mm)).*Pr.beta3(mm)) ;
% end