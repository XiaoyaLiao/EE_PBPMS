function Sol = ObjFunc(Pr,Sol)

% Sol = Pop(1) ;

Var = [] ;
Var.S = zeros(1,Pr.Nj) ;
Var.C = zeros(1,Pr.Nj) ;

Var.Sb = cell(Pr.Nm,1) ;
Var.Cb = cell(Pr.Nm,1) ;
Var.Pb = cell(Pr.Nm,1) ;
Var.pFam = cell(Pr.Nm,1) ;
Var.pCap = cell(Pr.Nm,1) ;

Var.Seq = cell(Pr.Nm,1) ;
Var.Btch = zeros(1,Pr.Nj) ; 
Var.Ass = zeros(1,Pr.Nj) ; 

Var.mObj = inf(Pr.Nm,3) ; % 1.Objective, 2.Family, 3.Capacity
Var.Pen = 0 ;




MachAvailability = zeros(1,Pr.Nm) ;
NonSequenced = Sol.Seq ;
BatchNo = ones(1,Pr.Nm) ;
while ~isempty(NonSequenced)
    
    % Find out the earliest available machine
    [~, m1] = find(MachAvailability==min(MachAvailability)) ;
    
    % If there are more than one such machines, select the machine with the fastest processing speed.
    if numel(m1)>1
        mm = m1(Pr.V(m1)==min(Pr.V(m1))) ; 
        mm = mm(1) ;
    else
        mm = m1 ;
    end
    
    %%% Fill the batch
    % add jobs to a batch as many as its does not violate the machine's capacity
    inBatchJobs = zeros(1,Pr.Nj) ;
    Cap = Pr.B(mm) ; 
    inBatchJobs(1) = NonSequenced(1) ;
    Cap = Cap - Pr.w(NonSequenced(1)) ;
     
    ind = 2 ;
    selected = 1 ;
    for cc = 2:numel(NonSequenced)
        
        if Pr.b(NonSequenced(1),NonSequenced(cc)) == 1 &&  Pr.w(NonSequenced(cc)) <= Cap
            inBatchJobs(ind) = NonSequenced(cc);
            Cap = Cap - Pr.w(NonSequenced(cc)) ;
            ind = ind+1 ;
            selected = [selected cc] ;
        elseif Pr.b(NonSequenced(1),NonSequenced(cc)) == 1 &&  Pr.w(NonSequenced(cc)) > Cap
            break
        end
    end
    NonSequenced(selected) = [] ;
    
    inBatchJobs = inBatchJobs(1:ind-1) ;
    
    %%%
       
    Var.Seq{mm} = [Var.Seq{mm} inBatchJobs] ;
    Var.Ass(inBatchJobs) = mm ;
    Var.Btch(inBatchJobs) = BatchNo(mm) ; 
    MachAvailability(mm) = max(MachAvailability(mm), max(Pr.R(inBatchJobs))) + max(Pr.P(inBatchJobs)/Pr.V(mm)) ;
    BatchNo(mm) = BatchNo(mm) + 1 ;
   
    
end


for mm = 1:Pr.Nm
    Var = Scheduler(Pr,Var,mm,1) ;
end

Sol.Var = Var ;
Sol.Obj = sum(sum(Var.mObj).*[1 5 5]) ;








