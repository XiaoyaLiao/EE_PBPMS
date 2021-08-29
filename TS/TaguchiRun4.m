%% Preparation

clc;
clear;
close all;
tic ;
%% Notes:

% I have to explain how a batch is selected at each iteration
% Where the EAH is applied 
nTest = 24 ;



%% Parameters Levels
Penalty = [0.01 0.005 0.001 0.0005];
Teure = [10 15 20 30 ];
Epsilon = [0.2 0.15 0.1 0.05];
Sigma = [0.1 0.05 0.03 0.01];
LSPeriod = [20 30 50 100];

Lvls = [1	1	1	1	1
        1	2	2	2	2
        1	3	3	3	3
        1	4	4	4	4
        2	1	2	3	4
        2	2	1	4	3
        2	3	4	1	2
        2	4	3	2	1
        3	1	3	4	2
        3	2	4	3	1
        3	3	1	2	4
        3	4	2	1	3
        4	1	4	2	3
        4	2	3	1	4
        4	3	2	4	1
        4	4	1	3	2
        ];



%% Input



ObjectiveTable = zeros(size(Lvls,1),nTest);

for sen = 12:size(Lvls,1)

%% Algorithm Parameters

AlgParams.Iterations =  100000 ;
AlgParams.Penalty = [1 Penalty(Lvls(sen,1)) Penalty(Lvls(sen,1))] ;

AlgParams.Teure = Teure(Lvls(sen,2)) ; 
AlgParams.InIt = 3 ; 
AlgParams.Ro = 1 ; 
AlgParams.Epsilon = Epsilon(Lvls(sen,3)) ;
AlgParams.Sigma = Sigma(Lvls(sen,4)) ;
AlgParams.LSPeriod = LSPeriod(Lvls(sen,5)) ; 

AlgParams.NonImprIt = 200 ;
AlgParams.CPU = 2 ;


AlgParams.MaxTen = ceil(1.3*AlgParams.Teure) ;
AlgParams.MinTen = ceil(0.7*AlgParams.Teure) ;
TabuList = zeros(1, AlgParams.Teure) ;


for test = 1:nTest

load(['T',num2str(test)]) ;
AlgParams.Ferquency = zeros(Pr.Nm, Pr.Nj) ;

%% Initial Solution
Collection = [];

[Pr, InitialVar] = InitialSol(AlgParams, Pr) ;

% Best Solution 

Var = InitialVar ;
Best = Var ;
Best.mObj(:,1) = inf;

%% Main Loop
CPU_time = tic;
AchievedTime = inf;
ImprvCuntr = 0 ;
BestFeasible = Var ; BestFeasible.mObj(:,1) = inf;
SlctdJob = 1 ;
SlctdMch = 1 ;
for Iteration = 1:AlgParams.Iterations
    
    disp(['It:',num2str(Iteration),', Obj=', num2str(sum(Var.mObj))  ', BestObj=', num2str(sum(Best.mObj)) ]) ; pause(0.001) ;
%     disp(num2str(TabuList))
%     disp(Var.mObj)
    
    NeighVar = Var ; 
    NeighVar.mObj(:,1) = inf ;
    
for  cMachine = 1:Pr.Nm
    
    if numel(Var.Pb{cMachine}) == 0
        continue
    end
    
    JobsOnMach = [Var.Seq{cMachine}] ;
    AlterMachines = 1:Pr.Nm ; 
    AlterMachines = AlterMachines(AlterMachines~=cMachine) ;
    
        
    for btch = 1:numel(Var.Pb{cMachine})
%     disp([cMachine btch])
   
     
        % 1.Penalty 2.Tardiness 3.ReleaseDate 4.ProcessingTime
        SelectedJobs = {};
        
        JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);

        % 1. Move tardy jobs
        TardyJobs = JobOnBch(Var.C(JobOnBch)-Pr.d(JobOnBch)>0) ;
        if ~isempty(TardyJobs)
            [~, ind] = max((Var.C(TardyJobs)-Pr.d(TardyJobs)).*Pr.alpha(TardyJobs)) ;
            Jobs = TardyJobs(ind) ;             
            
            if SelectionRepeation(SelectedJobs,Jobs) == 0
                [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,0) ;
                SelectedJobs = [SelectedJobs Jobs];
            end
        end
         % the last input is GroupMove which determines if the jobs must be checked as a group move or sinlge move 


        % 2. Move job with unconsistant family
        if numel(JobOnBch)>1 && (max(sum(Pr.b(JobOnBch,JobOnBch),2)) ==0 ||  max(sum(Pr.b(JobOnBch,JobOnBch),2)) ~= min(sum(Pr.b(JobOnBch,JobOnBch),2)) ) 
            bb = Pr.b(JobOnBch,JobOnBch) ;
            [~, Pos] = min(sum(bb,2)) ;
            Jobs = [JobOnBch(Pos) JobOnBch(bb(:,Pos) == 1)];
            
            if SelectionRepeation(SelectedJobs,Jobs) == 0
                [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,1) ;
                SelectedJobs = [SelectedJobs Jobs];
            end
        end

        % 3. Release an over loaded batch
        if sum(Pr.w(JobOnBch)) > Pr.B(cMachine)
            ws = Pr.w(JobOnBch) ;
            [ws, ordr] = sort(ws,'descend') ;
            Jobs = [];
            while sum(ws) > Pr.B(cMachine)
                Jobs = [Jobs JobOnBch(ordr(1))] ;
                ordr(1) = [] ;
                ws(1) = [] ;
            end
            if SelectionRepeation(SelectedJobs,Jobs) == 0
                [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,1) ;
                SelectedJobs = [SelectedJobs Jobs];
            end
        end


        % 4. Change the batch's Start Time
        if btch > 1 && numel(JobOnBch)>1
            LateReleaseJobs = JobOnBch(Pr.R(JobOnBch)>Var.Cb{cMachine}(btch-1)) ;

            if ~isempty(LateReleaseJobs)
                [~, ind] = max(Pr.R(LateReleaseJobs)) ;
                Jobs = LateReleaseJobs(ind) ;
                if SelectionRepeation(SelectedJobs,Jobs) == 0
                    [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,0) ;
                    SelectedJobs = [SelectedJobs Jobs];
                end
            end
        end

        % 5. Change the batch's processing time
        Jobs = JobOnBch(Pr.P(JobOnBch)==max(Pr.P(JobOnBch))) ; 
        if SelectionRepeation(SelectedJobs,Jobs) == 0
            [NeighVar,SlctdJob,SlctdMch] =  FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,1) ;
            SelectedJobs = [SelectedJobs Jobs];
        end
    end

end

% disp([SlctdMch SlctdJob (SlctdMch-1)*Pr.Nj + SlctdJob])

    Var = NeighVar ;
    TabuList = [(SlctdMch-1)*Pr.Nj + SlctdJob TabuList(1:end-1)] ;  
    AlgParams.Ferquency((SlctdMch-1)*Pr.Nj + SlctdJob) = AlgParams.Ferquency((SlctdMch-1)*Pr.Nj + SlctdJob) + 1 ;

    Vltd = [sum(Var.mObj(:,2))>0  sum(Var.mObj(:,3))>0] ;
    Cof1 = Vltd.*((1+AlgParams.Sigma).*ones(1,2)) ;
    
    
    if sum(Vltd)==0
        Cof2 = (1-Vltd).*(ones(1,2)./(1+AlgParams.Sigma)) ;
    else
        Cof2 = (1-Vltd).*(ones(1,2)) ;
    end
    
    AlgParams.Penalty(2:end) = AlgParams.Penalty(2:end).*(Cof1+Cof2) ;
    
    
    % Local Search
    if rem(ImprvCuntr+1,AlgParams.LSPeriod)==0 
       
       Var = LocalSearch(Pr,Var,AlgParams) ;

    end
    
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
            TabuList = [TabuList zeros(1,ceil(numel(TabuList)*AlgParams.Epsilon))] ;
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


end

ObjectiveTable(sen,test) = sum(sum(BestFeasible.mObj).*AlgParams.Penalty) ;
fName = ['T_sol_',num2str(sen),'_',num2str(test)];
save(fName,'BestFeasible')

end
end
