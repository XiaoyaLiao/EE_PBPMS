function Var = UpdateVar(Pr,Var,mm,ChkBch,NewCompletion) 
    
Var.Cb{mm}(ChkBch) = NewCompletion ;
Var.Sb{mm}(ChkBch) = NewCompletion - Var.Pb{mm}(ChkBch) ;

JobsOnMach = [Var.Seq{mm}] ;
JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==ChkBch);

Var.S(JobOnBch) = Var.Sb{mm}(ChkBch) ;
Var.C(JobOnBch) = Var.Cb{mm}(ChkBch) ;

%     Var.mObj(mm) = Var.mObj(mm) - Improve ;
%     Var.Obj = Var.Obj - Improve ; 


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