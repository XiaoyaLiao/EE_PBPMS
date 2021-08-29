function [Machine, Batch] = SelctBatch(Var,Pr,AlgParams)


nBatchOnMach = zeros(1,Pr.Nm);

for mm =1:Pr.Nm
    nBatchOnMach(mm) = numel(Var.Sb{mm});  % get the number of batch on each meachine
end

BatchCosts = zeros(1,sum(nBatchOnMach));  % calculate cost function value for all the batches
for mm =1:Pr.Nm  % for each machine
    JobsOnMach = [Var.Seq{mm}] ;  % for jobs on this machine

    for bb = 1:nBatchOnMach(mm)  % for each batch on this machine
        JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==bb);  % jobs in this batch
        
        Tardiness = sum(max(0,Pr.alpha(JobOnBch).*(Var.C(JobOnBch)-Pr.d(JobOnBch)))) ;  % get the total tardiness of this batch
        
        eOpration = sum(Pr.beta1(mm).*(Var.Cb{mm}(bb) - Var.Sb{mm}(bb))) ; % get Var.Seq{mm}Operating energy
        
        eStabdby = 0 ;
        
        eSwitch = 0 ;
        if bb>1
            Wating = Var.Sb{mm}(bb) - Var.Cb{mm}(bb-1) ;
            eStabdby = eStabdby + (Wating<=Pr.to(mm)) .* Wating.*Pr.beta2(mm) ;
            eSwitch = eSwitch + (Wating>Pr.to(mm)).*Pr.beta3(mm) ;
        else
            eSwitch = 10*Pr.beta3(mm)/numel(Var.Sb{mm}) ;
        end
       
        Obj =  Pr.lambda * (Tardiness/Pr.MaxTWT) + (1-Pr.lambda) * ((eOpration + eStabdby + eSwitch)/Pr.MaxTEC);
        
        BatchCosts(sum(nBatchOnMach(1:mm-1)) + bb) = sum( [Obj Var.pFam{mm}(bb) Var.pCap{mm}(bb)] .* AlgParams.Penalty ) ;
        
    end
end

% Roulette strategy to select a batch ii; The larger the cost is, the
% larger the probability it will be selected.
NormBatchCosts = BatchCosts/sum(BatchCosts) ;
FNormBatchCosts = cumsum(NormBatchCosts);

RND = rand;
ii = 1 ; 
while RND > FNormBatchCosts(ii)
    ii = ii +1;
end

% find batch ii's machine
cumBatchOnMach = cumsum(nBatchOnMach);
Machine =1 ;
while ii > cumBatchOnMach(Machine)
    Machine = Machine+1;
end

% get the position of batch ii on its machine
Batch = ii - sum(nBatchOnMach(1:Machine-1));


