function SelectedVar = InsertJob(AlgParams,NewVar, Pr, nMachine, rr) 
%  NewVar2 = InsertJob(NewVar, Pr, nMachine, rr) ;
%  NewVar = Var ;

JobsOnMach = [NewVar.Seq{nMachine}] ;  % get the jobs on machine nMachine

SelectedVar = NewVar ;  % initialize SelectedVar as NewVar to be returned
Buff2 = inf ;  % record the best mObj of each possible position
for inBatch = 1:2*numel(NewVar.Cb{nMachine})+1 % try each possible  Odds are separated batches 0 1 2 3 => 1 3 5 7...
    
    PsbleVar = NewVar ;  % initilize PsbleVar when insert this job at position inBatch
    PsbleVar.Seq{nMachine} = [PsbleVar.Seq{nMachine} rr] ; % put job rr at the end of PsbleVar.Seq{nMachine}
    
    % try a position based on the existed batch like 1 2 3, there are 7
    % positions to be 
    if rem(inBatch,2)==1  % if inBatch is odd number
        Pos = ceil(inBatch/2) ;  % get its original number 1 3 5 7=> 1 2 3 4
        PsbleVar.Pb{nMachine} =  [PsbleVar.Pb{nMachine}(1:Pos-1) 0 PsbleVar.Pb{nMachine}(Pos:end)] ;  % insert 0 at position Pos
        PsbleVar.Sb{nMachine} =  [PsbleVar.Sb{nMachine}(1:Pos-1) 0 PsbleVar.Sb{nMachine}(Pos:end)] ;  % insert 0 at position Pos
        PsbleVar.Cb{nMachine} =  [PsbleVar.Cb{nMachine}(1:Pos-1) 0 PsbleVar.Cb{nMachine}(Pos:end)] ;  % insert 0 at position Pos

        PsbleVar.pFam{nMachine} =  [PsbleVar.pFam{nMachine}(1:Pos-1) 0 PsbleVar.pFam{nMachine}(Pos:end)] ;  % insert 0 at position Pos
        PsbleVar.pCap{nMachine} =  [PsbleVar.pCap{nMachine}(1:Pos-1) 0 PsbleVar.pCap{nMachine}(Pos:end)] ;  % insert 0 at position Pos
        
        AfterBatches = JobsOnMach(PsbleVar.Btch(JobsOnMach)>=ceil(inBatch/2)) ;  % the position of jobs after this pos need to be add 1 because one job inserted before them 
        PsbleVar.Btch(AfterBatches) = PsbleVar.Btch(AfterBatches) + 1 ;  
        
        PsbleVar.Btch(rr) = Pos ;  % put rr at Posth Batch, this Pos is new
        PsbleVar.Ass(rr) = nMachine ;  %  job rr to nMachine
    else  % if inBatch is even number, combination
        Pos = (inBatch/2); % 2 4 6 => 1 2 3
        PsbleVar.Btch(rr) = Pos ;  % Pos is one of the existing batch's position
        PsbleVar.Ass(rr) = nMachine ;  % machine
    end


% % JobsOnMach = [PsbleVar.Seq{nMachine}] ;
% % H1 = unique(PsbleVar.Btch(JobsOnMach)) ;
% % H2 = 1:numel(H1) ;
% % if ~isempty(setdiff(H2,H1))
% %     disp(H1)
% %     pause
% % end
    
    PsbleVar = Scheduler(Pr,PsbleVar,nMachine,Pos) ;  % insert current job at position Pos on machine nMachine

% % JobsOnMach = [PsbleVar.Seq{nMachine}] ;
% % H1 = unique(PsbleVar.Btch(JobsOnMach)) ;
% % H2 = 1:numel(H1) ;
% % if ~isempty(setdiff(H2,H1))
% %     disp(H1)
% %     pause
% % end
    
    % get the smallest mObj
    if sum(PsbleVar.mObj(nMachine,:) .* AlgParams.Penalty) < Buff2  % choose the PsbleVar with the smallest mObj
        SelectedVar = PsbleVar ;
        Buff2 = sum(SelectedVar.mObj(nMachine,:).*AlgParams.Penalty) ;
    end
end



