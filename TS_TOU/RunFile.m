%% Preparation


clc;
clear;
close all;
tic ;
%% Notes:

% I have to explain how a batch is selected at each iteration
% Where the EAH is applied 


%% Input

load('Pr') ;
Pr.lambda = 0.2;
Pr.MaxTEC = 1;
Pr.MaxTWT = 1;

% The value for Pr struct
% the number of jobs                     Nj: 15    
% the number of machines                 Nm: 2
% processing times                        P: [18 6 6 16 18 20 12 12 2 7 8 2 2 7 2]
% velocity of machines                    V: [1 1.5000]
% release times                           R: [105 119 49 101 99 21 96 85 69 61 53 105 101 37 21]
% due times                               d: [159 173 109 181 261 221 168 205 77 75 117 107 119 93 41]
% tardiness penalty weight            alpha: [1 4 3 2 1 3 3 1 1 2 3 2 2 2 1]
% load weight of jobs                     w: [4 5 2 6 6 5 4 1 1 2 6 3 4 5 3]
% load capacity of machines               B: [10 10]
% energy consumption rate of machine
%     in operation state              beta1: [2 4.5000]
%     in standby state                beta2: [1 1]
% energy consumption to turn on       beta3: [20 20]
%  /tau=etj/esj that is beta3/beta2   to: [20 20]
% binary parameter of compatibility       b: [15×15 double]
% objective weight for making trade off 
% between TWT and TEC                lambda: 0.2000
% the maximum value of TEC           MaxTEC: 1
% the maximum value of TWT           MaxTWT: 1

%% Algorithm Parameters

AlgParams.Iterations =  100000;   % maximum loop of the algorithm
AlgParams.Penalty = [1 100 100];  % penalty for imcompatible jobs in batch, weight load 

% this should be tenure
AlgParams.Teure = 30;  % tenure for tabulist
AlgParams.InIt = 3;  % ?
AlgParams.Ro = 1;  %
AlgParams.Epsilon = 0.05;  % ?
AlgParams.Sigma = 0.05;  % ?    
AlgParams.LSPeriod = 50;  % local search period?
AlgParams.NonImprIt = 2000;  % non-improved iteration?
AlgParams.CPU = 600;  % CPU time 10 minutes.

% this should be frequency
AlgParams.Ferquency = zeros(Pr.Nm, Pr.Nj);  % the number of machines rows, jobs columns 
AlgParams.MaxTen = ceil(3*AlgParams.Teure);  % 
AlgParams.MinTen = ceil(0.7*AlgParams.Teure);
TabuList = zeros(1, AlgParams.Teure);

%% Initial Solution

Var = InitialSol(AlgParams, Pr) ;  % O( n*(logn + m + batch *( 2*batch-1 ) ) ) = O(n^2)

% Best Solution 
Best = Var ;  % initialize the Best solution

%% Main Loop
CPU_time = tic;  % time count
AchievedTime = inf;  % ?
ImprvCuntr = 0 ;  % ?
BestFeasible = Var ; BestFeasible.mObj(:,1) = inf;  % initialize Best feasible solution
SlctdJob = 1 ;  % ?
SlctdMch = 1 ;  % ?
for Iteration = 1:AlgParams.Iterations
    
    disp(['It:',num2str(Iteration),', Obj=', num2str(round(sum(Var.mObj)))]) ; pause(0.001) ;
%     disp(AlgParams.Penalty)
    NeighVar = Var ;  % initialize best neighbor structure
    NeighVar.mObj(:,1) = inf ;
    
    [cMachine, btch] = SelctBatch(Var,Pr,AlgParams) ;  % accroding to cost function. Roulette strategy used
    % 1.Penalty 2.Tardiness 3.ReleaseDate 4.ProcessingTime

    JobsOnMach = [Var.Seq{cMachine}] ;  % get the jobs on the selected machine

    AlterMachines = 1:Pr.Nm ; % get the possible machine to insert
    AlterMachines = AlterMachines(AlterMachines~=cMachine) ;  % exclude itself

    JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);  % get the jobs on this selected batch

    % 1. Move tardy jobs
    TardyJobs = JobOnBch(Var.C(JobOnBch)-Pr.d(JobOnBch)>0) ;  % get all the tardy jobs in this batch
    if ~isempty(TardyJobs)
        [~, ind] = max((Var.C(TardyJobs)-Pr.d(TardyJobs)).*Pr.alpha(TardyJobs)) ;  % choose the job with the largest weighted tardiness
        Jobs = TardyJobs(ind) ;             

        [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,0) ;
    end
     % the last input is GroupMove which determines if the jobs must be checked as a group move or sinlge move 


    % 2. Move job with unconsistant family
    if numel(JobOnBch)>1 && (max(sum(Pr.b(JobOnBch,JobOnBch),2)) ==0 ||  max(sum(Pr.b(JobOnBch,JobOnBch),2)) ~= min(sum(Pr.b(JobOnBch,JobOnBch),2)) ) 
        bb = Pr.b(JobOnBch,JobOnBch) ;
        [~, Pos] = min(sum(bb,2)) ;  % get the minimum number of compability
        Jobs = [JobOnBch(Pos) JobOnBch(bb(:,Pos) == 1)];
        %Jobs = JobOnBch(Pos) ; 

        [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,1) ;
    end

    % 3. Change the capacity of batch
    if sum(Pr.w(JobOnBch)) > Pr.B(cMachine)
        ws = Pr.w(JobOnBch) ;
        [ws, ordr] = sort(ws,'descend') ;
        Jobs = [];
        while sum(ws) > Pr.B(cMachine)
            Jobs = [Jobs JobOnBch(ordr(1))] ;
            ordr(1) = [] ;
            ws(1) = [] ;
        end

        
        [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,1) ;
    end


    % 4. Change the batch's Start Time
    if btch > 1 && numel(JobOnBch)>1
        LateReleaseJobs = JobOnBch(Pr.R(JobOnBch)>Var.Cb{cMachine}(btch-1)) ;

        if ~isempty(LateReleaseJobs)
            [~, ind] = max(Pr.R(LateReleaseJobs)) ;
            Jobs = LateReleaseJobs(ind) ;

            [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,0) ;
        end
    end

    % 5. Change the batch's processing time
    Jobs = JobOnBch(Pr.P(JobOnBch)==max(Pr.P(JobOnBch))) ;   
    [NeighVar,SlctdJob,SlctdMch] =  FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,1) ;

    
%     if sum(NeighVar.mObj(:))==inf
%         continue
%     end
    
%     if sum(sum(NeighVar.mObj))== inf
%         pause
%     end
    
    Var = NeighVar ;
    
    TabuList = [(SlctdMch-1)*Pr.Nj + SlctdJob TabuList(1:end-1)] ;  % update tabulist
    AlgParams.Ferquency((SlctdMch-1)*Pr.Nj + SlctdJob) = AlgParams.Ferquency((SlctdMch-1)*Pr.Nj + SlctdJob) + 1 ;  % update Algorithm frequency i.e. \tho_{ij}

    Vltd = [sum(Var.mObj(:,2))>0  sum(Var.mObj(:,3))>0] ;
    Cof1 = Vltd.*((1+AlgParams.Sigma).*ones(1,2)) ;
    
    
    if sum(Vltd)==0
        Cof2 = (1-Vltd).*(ones(1,2)./(1+AlgParams.Sigma)) ;
    else
        Cof2 = (1-Vltd).*(ones(1,2)) ;
    end
    
    AlgParams.Penalty(2:end) = AlgParams.Penalty(2:end).*(Cof1+Cof2) ;
    
    
    % Local Search
%     if rem(ImprvCuntr+1,AlgParams.LSPeriod)==0 
%         a = sum(Var.mObj(:)) ;
%         disp("apply LS")
%         Var = LocalSearch(Pr,Var,AlgParams) ;
%         
%         b = sum(Var.mObj(:)) ;
%         
%         if b<a
%             disp(["ImprvCuntr = ",num2str(ImprvCuntr)])
% 
%             disp('improved')
%         end
%     end
    
    if sum(sum(Var.mObj).*AlgParams.Penalty) < sum(sum(Best.mObj).*AlgParams.Penalty) 
        Best = Var ;         
        
        TabuList = TabuList(1:max(AlgParams.MinTen,ceil(numel(TabuList)*(1-AlgParams.Epsilon)))) ;
        
        if sum(sum(Var.mObj(:,2:3))) == 0 && sum(Var.mObj(:,1)) <  sum(BestFeasible.mObj(:,1))
            BestFeasible = Var ;
            ImprvCuntr = 0 ;
            AchievedTime =toc(CPU_time);
        end
    else
        ImprvCuntr = ImprvCuntr + 1 ;
        if ImprvCuntr > 3 
            TabuList = TabuList ;%[TabuList zeros(1,ceil(numel(TabuList)*AlgParams.Epsilon))] ;
            if numel(TabuList)>AlgParams.MaxTen
                TabuList = TabuList(1:max(AlgParams.MaxTen)) ;
            end
        end
    end
    
    % disp(num2str(TabuList))
    if ImprvCuntr>AlgParams.NonImprIt  || toc(CPU_time)>AlgParams.CPU
        break
    end

    if rem(ImprvCuntr,AlgParams.MaxTen)==0 
       Var =  Best ; %BestFeasible ;% Var=Best shows better performance
    end

    % Vltd = [sum([Best.pFam{:}])>0   sum([Best.pCap{:}])>0] ;
    % if max(Vltd)==0 && BestFeasible.Obj < Best.Obj
    %     BestFeasible = Best ;
    % end

end


disp(["CPU time: ",num2str(toc(CPU_time))])
num2str(sum(BestFeasible.mObj(:)))
VariableShow(BestFeasible,Pr)

%VariableShow(Var,Pr)


% newVar = BestFeasible;
% for mm = 1:Pr.Nm
%     
%     newVar = EnergyHeuristic(newVar,Pr,mm);
%     
% end
% sum(newVar.mObj)
% 
% 
% 

