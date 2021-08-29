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
        
        Jobs = randi([1,Pr.Nj],1,1);
        
        
        cMachine = Var.Ass(Jobs);
        btch = Var.Btch(Jobs);
        JobsOnMach = [Var.Seq{cMachine}] ;

        AlterMachines = 1:Pr.Nm ; 
        AlterMachines = AlterMachines(AlterMachines~=cMachine) ;

        JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);

        NeighVar = FindNeighSA(AlgParams,Var,NeighVar,Pr,btch,Jobs,AlterMachines,0) ;
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

    if r > BreakCondition && Bests(r) == Bests(r-BreakCondition)  ||  toc(CPU_Time) > AlgParams.Timelimit
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

