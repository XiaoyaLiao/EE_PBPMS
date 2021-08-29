function Var = Scheduler(Pr,Var,mm,FirstBatch)
% Aslivar = Var BestFeasible.mObj Var ;

% Var = Aslivar ; 
% FirstBatch=1;
% mm=1;

JobsOnMach = [Var.Seq{mm}] ;  

if isempty(JobsOnMach)
    Var.mObj(mm,:) = 0 ;
    Var.Seq{mm} = [] ;
    Var.Sb{mm} = [] ;
    Var.Cb{mm} = [] ;
    Var.Pb{mm} = [] ;
    Var.pFam{mm} = [] ;
    Var.pCap{mm} = [] ;

    return
end



for bch = FirstBatch:max(Var.Btch(JobsOnMach))
    JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==bch);
    if isempty(JobOnBch)
        continue
    end
    if bch == 1
        MachAvailality = 0 ;
    else
        MachAvailality = Var.Cb{mm}(bch-1) ;
    end
    
    Var.Sb{mm}(bch) = max([MachAvailality Pr.R(JobOnBch)]);    
    Var.Pb{mm}(bch) = max(Pr.P(JobOnBch))/Pr.V(mm) ;
    Var.Cb{mm}(bch) = Var.Sb{mm}(bch) + Var.Pb{mm}(bch) ;
    Var.S(JobOnBch) = Var.Sb{mm}(bch) ;
    Var.C(JobOnBch) = Var.Cb{mm}(bch) ; 
    
    b = 1-Pr.b(JobOnBch,JobOnBch) ;
    Var.pFam{mm}(bch) = (sum(b(:)) - numel(JobOnBch))/2 ; 
    
    Var.pCap{mm}(bch) = max(0,sum(Pr.w(JobOnBch))-Pr.B(mm)) ;

end

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

% Forward movements 

% if Var.mObj(mm,2) + Var.mObj(mm,3) == 0 && Pr.ForwardMove == 1 
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


    
  