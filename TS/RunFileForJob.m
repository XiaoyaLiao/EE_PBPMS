%% Preparation

clc;
clear;
close all;
tic ;
%% Notes:

% I have to explain how a batch is selected at each iteration
% Where the EAH is applied 
nTest = 1 ;
nRep = 1;


ObjTable = zeros(nTest,nRep);
TWTTable = zeros(nTest,nRep);
TECTable = zeros(nTest,nRep);

%% Input
for test = 1:1
% load('Pr')

load(['Pr',num2str(test)]) ;
% 
Pr.lambda = 0.5;
Pr.MaxTEC = 1;
Pr.MaxTWT = 1;

% Pr.to = 4.*Pr.to ;
% Pr.d = Pr.d + randi([0,2],1,Pr.Nj).*Pr.P ;

%% Algorithm Parameters

AlgParams.Iterations =  100000 ;
AlgParams.Penalty = [1 100 100] ;

AlgParams.Teure = 30 ; 
AlgParams.InIt = 3 ; 
AlgParams.Ro = 1 ; 
AlgParams.Epsilon = 0.05 ;
AlgParams.Sigma = 0.05 ; 
AlgParams.LSPeriod = 50 ; 
AlgParams.NonImprIt = 500 ;
AlgParams.CPU = 60 ;

AlgParams.Ferquency = zeros(Pr.Nm, Pr.Nj) ;
AlgParams.MaxTen = ceil(3*AlgParams.Teure) ;
AlgParams.MinTen = ceil(0.7*AlgParams.Teure) ;
TabuList = zeros(1, AlgParams.Teure) ;

%% Initial Solution
Collection = [];

InitialVar = InitialSol(AlgParams, Pr) ;
for rep = 1:nRep
% Best Solution 
Var = InitialVar ;
Best = Var ;

%% Main Loop
CPU_time = tic;
AchievedTime = inf;
ImprvCuntr = 0 ;
BestFeasible = Var ; BestFeasible.mObj(:,1) = inf;
SlctdJob = 1 ;
SlctdMch = 1 ;
for Iteration = 1:AlgParams.Iterations
    
    disp(['It:',num2str(Iteration),', Obj=', num2str(round(sum(Var.mObj)))]) ; pause(0.001) ;
%     disp(AlgParams.Penalty)
    NeighVar = Var ; 
    NeighVar.mObj(:,1) = inf ;
    
    for Jobs = 1:Pr.Nj
    % 1.Penalty 2.Tardiness 3.ReleaseDate 4.ProcessingTime
    
        cMachine = Var.Ass(Jobs);
        btch = Var.Btch(Jobs);
        JobsOnMach = [Var.Seq{cMachine}] ;

        AlterMachines = 1:Pr.Nm ; 
        AlterMachines = AlterMachines(AlterMachines~=cMachine) ;

        JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);

        [NeighVar,SlctdJob,SlctdMch] = FindNeigh(AlgParams,Var,NeighVar,Pr,TabuList,btch,Jobs,SlctdJob,SlctdMch,AlterMachines,0) ;

    end

    
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
[TWT, TEC] = VariableShow(BestFeasible,Pr)

Result = [];
Result.Time = toc(CPU_time);
Result.Sol = BestFeasible;
Result.Obj = round(sum(BestFeasible.mObj(:)));
Result.TWT = TWT;
Result.TEC = TEC;

Collection = [Collection Result]; 

ObjTable(test,rep) = round(sum(BestFeasible.mObj(:)));
TWTTable(test,rep) = round(TWT) ;
TECTable(test,rep) = round(TEC) ;

end

% disp("Objective:")
% disp(num2str([Collection.Obj]))
% 
% disp("TWT:")
% disp(num2str([Collection.TWT]))
% 
% disp("TEC:")
% disp(num2str([Collection.TEC]))

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

end

disp("Objectives:")
disp(num2str(ObjTable))

disp("TWTs:")
disp(num2str(TWTTable))

disp("TECs:")
disp(num2str(TECTable))