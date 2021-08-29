function Var = Scheduler(Pr,Var,mm,FirstBatch)
% Aslivar = BestFeasible.mObj Var ;

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



for bch = FirstBatch:max(Var.Btch(JobsOnMach))  % calculate this batch and its following batch on the same machine
    JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==bch);  % the jobs in the current batch
    
    if bch == 1
        MachAvailality = 0 ;  % machine availality time
    else
        MachAvailality = Var.Cb{mm}(bch-1) ;
    end
    
    Var.Sb{mm}(bch) = max([MachAvailality Pr.R(JobOnBch)]);  % get the starting time for current batch
    Var.Pb{mm}(bch) = max(Pr.P(JobOnBch))/Pr.V(mm) ;  % get the processing time for current batch on current machine
    Var.Cb{mm}(bch) = Var.Sb{mm}(bch) + Var.Pb{mm}(bch) ;  % get the completion time for current batch on current machine
    Var.S(JobOnBch) = Var.Sb{mm}(bch) ;  % let the jobs in the current batch have the same starting time
    Var.C(JobOnBch) = Var.Cb{mm}(bch) ;  % let the jobs in the current batch have the same completion time
    
    b = 1-Pr.b(JobOnBch,JobOnBch) ;  % b means isBatch
    Var.pFam{mm}(bch) = (sum(b(:)) - numel(JobOnBch))/2 ;  % the number of job pairs which are imcompatible, family penalty
    
    Var.pCap{mm}(bch) = max(0,sum(Pr.w(JobOnBch))-Pr.B(mm)) ;  % then number of load weight which is larger than the machine's load weight capacity penalty
end

Tardiness = sum(max(0,Pr.alpha(JobsOnMach).*(Var.C(JobsOnMach)-Pr.d(JobsOnMach)))) ;  % calculate tardiness of the jobs on the batch

% [eOpration,eStabdby] = TECcal(Var,Pr,mm) ;
eOpration = sum(Pr.beta1(mm).*(Var.Cb{mm} - Var.Sb{mm})) ; % Operating energy
eStabdby = 0 ;
eSwitch = Pr.beta3(mm)*~isempty(JobsOnMach) ;
if numel(Var.Cb{mm})>1
    Wating = Var.Sb{mm}(2:end) - Var.Cb{mm}(1:end-1) ;
    eStabdby = eStabdby + sum( ( Wating<=Pr.to(mm) ).*Wating.*Pr.beta2(mm) ) ;  % when waiting time \times standby <= switch energy consumption
    eSwitch = eSwitch + sum( ( Wating>Pr.to(mm) ) .*Pr.beta3(mm) ) ;  % when waiting time \times standby > switch energy consumption
end
Var.mObj(mm,1) = Pr.lambda * (Tardiness/Pr.MaxTWT) + (1-Pr.lambda) * ((eOpration + eStabdby + eSwitch)/Pr.MaxTEC) ;  % calculate the obj
Var.mObj(mm,2) = sum(Var.pFam{mm}) ;
Var.mObj(mm,3) = sum(Var.pCap{mm}) ;

% Forward movements 

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


    
  