function VariableShow(Var,Pr)
% Var = BestFeasible ;
TWT = 0;
TEC = 0;
close all

for mm = 1:Pr.Nm

JobsOnMach = [Var.Seq{mm}] ;  

Tardiness = sum(max(0,Pr.alpha(JobsOnMach).*(Var.C(JobsOnMach)-Pr.d(JobsOnMach)))) ;

%[eOpration,eStabdby] = TECcal(Var,Pr,mm) ;
eOpration = sum(Pr.beta1(mm).*(Var.Cb{mm} - Var.Sb{mm})) ; % Operating energy
eStabdby = 0 ;
eSwitch = Pr.beta3(mm)*~isempty(JobsOnMach) ;
if numel(Var.Cb{mm})>1
    Wating = Var.Sb{mm}(2:end) - Var.Cb{mm}(1:end-1) ;
    eStabdby = eStabdby + sum((Wating<=Pr.to(mm)).*Wating.*Pr.beta2(mm)) ;
    eSwitch = eSwitch + sum((Wating>Pr.to(mm)).*Pr.beta3(mm)) ;
end
Var.mObj(mm,1) = Pr.lambda * (Tardiness/Pr.MaxTWT) + (1-Pr.lambda) * ((eOpration + eStabdby + eSwitch)/Pr.MaxTEC) ;
Var.mObj(mm,2) = sum(Var.pFam{mm}) ;
Var.mObj(mm,3) = sum(Var.pCap{mm}) ;
TWT = Tardiness + TWT ;
TEC = TEC + (eOpration + eStabdby + eSwitch);

for bb =1:numel(Var.Sb{mm})
    y = mm.*[1 1];
    x = [Var.Sb{mm}(bb) Var.Cb{mm}(bb)];
    hold on
    plot(x,y,'-','LineWidth',40)  
    if bb >1
        if Var.Sb{mm}(bb) - Var.Cb{mm}(bb-1) > Pr.to(mm)
            
            plot(Var.Sb{mm}(bb),mm,'*b')
            hold on
        end
    end
    
end
end

disp(['TWT =',num2str(TWT), ', TEC = ',num2str(TEC)])