function SelectedVar = InsertJob(AlgParams,NewVar, Pr, nMachine, rr) 
%  NewVar2 = InsertJob(NewVar, Pr, nMachine, rr) ;
%  NewVar = Var ;

JobsOnMach = [NewVar.Seq{nMachine}] ;

SelectedVar = NewVar ; 
Buff2 = inf ;
for inBatch = 1:2*numel(NewVar.Cb{nMachine})+1 % Odds are separated batches
    PsbleVar = NewVar ;
    PsbleVar.Seq{nMachine} = [PsbleVar.Seq{nMachine} rr] ;
    if rem(inBatch,2)==1
        Pos = ceil(inBatch/2) ;
        PsbleVar.Pb{nMachine} =  [PsbleVar.Pb{nMachine}(1:Pos-1) 0 PsbleVar.Pb{nMachine}(Pos:end)] ;
        PsbleVar.Sb{nMachine} =  [PsbleVar.Sb{nMachine}(1:Pos-1) 0 PsbleVar.Sb{nMachine}(Pos:end)] ;
        PsbleVar.Cb{nMachine} =  [PsbleVar.Cb{nMachine}(1:Pos-1) 0 PsbleVar.Cb{nMachine}(Pos:end)] ;

        PsbleVar.pFam{nMachine} =  [PsbleVar.pFam{nMachine}(1:Pos-1) 0 PsbleVar.pFam{nMachine}(Pos:end)] ;
        PsbleVar.pCap{nMachine} =  [PsbleVar.pCap{nMachine}(1:Pos-1) 0 PsbleVar.pCap{nMachine}(Pos:end)] ;
        
        AfterBatches = JobsOnMach(PsbleVar.Btch(JobsOnMach)>=ceil(inBatch/2)) ;
        PsbleVar.Btch(AfterBatches) = PsbleVar.Btch(AfterBatches) + 1 ; 
        
        PsbleVar.Btch(rr) = Pos ;
        PsbleVar.Ass(rr) = nMachine ;
    else
        Pos = (inBatch/2);
        PsbleVar.Btch(rr) = Pos ;
        PsbleVar.Ass(rr) = nMachine ;
    end


% % JobsOnMach = [PsbleVar.Seq{nMachine}] ;
% % H1 = unique(PsbleVar.Btch(JobsOnMach)) ;
% % H2 = 1:numel(H1) ;
% % if ~isempty(setdiff(H2,H1))
% %     disp(H1)
% %     pause
% % end
    
    PsbleVar = Scheduler(Pr,PsbleVar,nMachine,Pos) ;

% % JobsOnMach = [PsbleVar.Seq{nMachine}] ;
% % H1 = unique(PsbleVar.Btch(JobsOnMach)) ;
% % H2 = 1:numel(H1) ;
% % if ~isempty(setdiff(H2,H1))
% %     disp(H1)
% %     pause
% % end

    if sum(PsbleVar.mObj(nMachine,:) .* AlgParams.Penalty) < Buff2
        SelectedVar = PsbleVar ;
        Buff2 = sum(SelectedVar.mObj(nMachine,:).*AlgParams.Penalty) ;
    end
end





