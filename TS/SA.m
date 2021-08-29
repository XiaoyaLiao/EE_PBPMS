%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%% SA for Invenrtory Problem  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% start of the program
clc;
clear;
close all;


%% Parameters

AlgParams.Timelimit = 600 ;
AlgParams.Penalty = [1 5 5] ;

r=0; Tr=1; N=10; 
R=10000; alpha=0.01;
BreakCondition = 300 ;


%% Inputs

load('L30')
Pr.ForwardMove = 1 ;

[Pr, InitialVar] = InitialSol(AlgParams, Pr) ;
% load('BestFeasible')
% InitialVar = BestFeasible ;

%% Loop
CPU_Time = tic;
Var = InitialVar;
BestVar = Var;

Bests = zeros(1,R) ;
Bests(1) = sum(sum(BestVar.mObj).*AlgParams.Penalty) ;
%pause
ImprvCuntr = 0;
NeighVar = Var ; 
while r<R && Tr>0 
    n = 0;
%     Var = BestVar ;
%     disp(['Iteration: ',num2str(r)])
    
   
    
    while n < N %|| toc(TimeID)<3
        NeighVar.mObj(:,1) = inf ;
        
        cMachine = randi([1,Pr.Nm],1,1);
        
        if numel(Var.Pb{cMachine}) == 0
            continue
        end
        
        JobsOnMach = [Var.Seq{cMachine}] ;
        AlterMachines = 1:Pr.Nm ; 
        AlterMachines = AlterMachines(AlterMachines~=cMachine) ;
        
        btch = randi([1,numel(Var.Pb{cMachine})],1,1);
        
%     for  cMachine = 1:Pr.Nm
% 
%         if numel(Var.Pb{cMachine}) == 0
%             continue
%         end
% 
%         JobsOnMach = [Var.Seq{cMachine}] ;
%         AlterMachines = 1:Pr.Nm ; 
%         AlterMachines = AlterMachines(AlterMachines~=cMachine) ;
%         for btch = 1:numel(Var.Pb{cMachine})
    %     disp([cMachine btch])
             
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % 1.Penalty 2.Tardiness 3.ReleaseDate 4.ProcessingTime
        SelectedJobs = {};
        
        JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);

        % 1. Move tardy jobs
        TardyJobs = JobOnBch(Var.C(JobOnBch)-Pr.d(JobOnBch)>0) ;
        if ~isempty(TardyJobs)
            [~, ind] = max((Var.C(TardyJobs)-Pr.d(TardyJobs)).*Pr.alpha(TardyJobs)) ;
            Jobs = TardyJobs(ind) ;             
            
            if SelectionRepeation(SelectedJobs,Jobs) == 0
                NeighVar = FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,0) ;
            end
        end
         % the last input is GroupMove which determines if the jobs must be checked as a group move or sinlge move 


        % 2. Move job with unconsistant family
        if numel(JobOnBch)>1 && (max(sum(Pr.b(JobOnBch,JobOnBch),2)) ==0 ||  max(sum(Pr.b(JobOnBch,JobOnBch),2)) ~= min(sum(Pr.b(JobOnBch,JobOnBch),2)) ) 
            bb = Pr.b(JobOnBch,JobOnBch) ;
            [~, Pos] = min(sum(bb,2)) ;
            Jobs = [JobOnBch(Pos) JobOnBch(bb(:,Pos) == 1)];
            
            if SelectionRepeation(SelectedJobs,Jobs) == 0
                NeighVar = FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,1) ;
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
                NeighVar = FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,1) ;
            end
        end
        
        
        % 4. Change the batch's Start Time
        if btch > 1 && numel(JobOnBch)>1
            LateReleaseJobs = JobOnBch(Pr.R(JobOnBch)>Var.Cb{cMachine}(btch-1)) ;

            if ~isempty(LateReleaseJobs)
                [~, ind] = max(Pr.R(LateReleaseJobs)) ;
                Jobs = LateReleaseJobs(ind) ;
                if SelectionRepeation(SelectedJobs,Jobs) == 0
                    NeighVar = FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,0) ;
                end
            end
        end

        % 5. Change the batch's processing time
        Jobs = JobOnBch(Pr.P(JobOnBch)==max(Pr.P(JobOnBch))) ; 
        if SelectionRepeation(SelectedJobs,Jobs) == 0
            NeighVar =  FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,1) ;
        end

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
        Delta = sum(sum(NeighVar.mObj).*AlgParams.Penalty) - sum(sum(Var.mObj).*AlgParams.Penalty)  ;  
%         sum(sum(NeighVar.mObj).*AlgParams.Penalty)
%         sum(sum(Var.mObj).*AlgParams.Penalty) 
        
        
        if Delta < 0
            n=n+1;
            Var=NeighVar;
            ImprvCuntr = 0 ;
            if sum(sum(NeighVar.mObj).*AlgParams.Penalty) < sum(sum(BestVar.mObj).*AlgParams.Penalty)
                BestVar=NeighVar ;
            end
        else
            y = rand;
            Z = exp(-Delta./Tr);
            if y < Z
                n=n+1;
                Var=NeighVar;
            end
            ImprvCuntr = ImprvCuntr + 1 ;
        end
        
        
        if  toc(CPU_Time) > AlgParams.Timelimit
            break
        end
       
    end
    
     % Local Search
     if rem(r,50)==0
         Var = LocalSearch(Pr,Var,AlgParams) ;
     end
        
    r=r+1;
    Tr=Tr - (alpha*Tr);
    
    Bests(r) = sum(sum(BestVar.mObj).*AlgParams.Penalty) ;
%Bests(r)

%     [TWT, TEC] = VariableShow(BestVar,Pr);
    disp(['It:',num2str(r),', Obj=', num2str(sum(Var.mObj))  ', BestObj=', num2str(sum(BestVar.mObj)) ]) ; pause(0.001) ;

    if r > BreakCondition && Bests(r) == Bests(r-BreakCondition) || toc(CPU_Time) > AlgParams.Timelimit
        break
    end

end

%toc

CPUTime = toc(CPU_Time) ;
disp(['Time : ' ,num2str(CPUTime)])



newVar = BestVar;
for mm = 1:Pr.Nm
    newVar = Scheduler(Pr,newVar,mm,1);
end

