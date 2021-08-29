function [NewCompletion,Improve] = MoveCheck(mVar, Pr,mm,bch,eBack)
% mVar = NewVar;
% bch = ChkBch;
% eBack = 1;

nBatches = numel(mVar.Sb{mm}) ;
if  bch < nBatches && mVar.Sb{mm}(bch+1) == mVar.Cb{mm}(bch)
    Improve = 0 ;
    NewCompletion = mVar.Cb{mm}(bch) ;
    return
end

JobsOnMach = [mVar.Seq{mm}] ;
JobOnBch = JobsOnMach(mVar.Btch(JobsOnMach)==bch);

%%% for when Switch off is allowed
treshold = max( mVar.Cb{mm}(bch),  mVar.Sb{mm}(bch+1) - Pr.to(mm)) ; 
Ind = (Pr.d(JobOnBch) > treshold) .* (Pr.d(JobOnBch) < mVar.Sb{mm}(bch+1)) ;    
%%%

if  mVar.Sb{mm}(bch+1) == mVar.Cb{mm}(bch)
    H = [] ;
else
    H = mVar.Sb{mm}(bch+1) ;
end

PtntialCbs = [mVar.Cb{mm}(bch),  Pr.d(JobOnBch(Ind==1)), H] ;    
PtntialCbs = sort(PtntialCbs); 
    
nPtntialCbs = numel(PtntialCbs) ;
CbsCots = zeros(1,nPtntialCbs) ;

for pp = 1:nPtntialCbs
    cc = PtntialCbs(pp) ;
    eAfter = min(Pr.to(mm), mVar.Sb{mm}(bch+1)- cc)*Pr.beta2(mm) ;
    eBefore = 0 ;
    if bch > 1 && eBack == 1
        eBefore = min(Pr.to(mm), cc-mVar.Pb{mm}(bch) - mVar.Cb{mm}(bch-1))*Pr.beta2(mm) ;
    end
%   EC = BatchECcal(mVar,Pr,mm,bch) ;
    BchTardiness = sum( max(0, cc-Pr.d(JobOnBch)).*Pr.alpha(JobOnBch) ) ;
    CbsCots(pp) = Pr.lambda * (BchTardiness/Pr.MaxTWT) + (1-Pr.lambda) * ((eAfter +  eBefore)/Pr.MaxTEC );
end

best = find(CbsCots==min(CbsCots)) ;

if eBack == 1
    NewCompletion = PtntialCbs(best(end)) ;
    MinCost = CbsCots(best(end)) ;
else
    NewCompletion = PtntialCbs(best(1)) ;
    MinCost = CbsCots(best(1)) ;
end

% Improve = NewCompletion~=PtntialCbs(1) ;
Improve = CbsCots(1) - MinCost ;

