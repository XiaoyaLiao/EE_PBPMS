%%%%%%%%%%%%%%%% Differential Algorithm (DA) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% start of the program
clc;
clear ;

%% Inputs


% ObjectiveValues = zeros(1,NumberOfRepeat) ;
% CPUTimes = zeros(1,NumberOfRepeat) ;


%% Algorithm Parameters
AlgParams.PopSize=200;
AlgParams.Iteration=3000;
AlgParams.F=0.5;
AlgParams.W=0.05;
AlgParams.BreakCondition=200;
AlgParams.Timelimit = 600;


%% Notes:

% I have to explain how a batch is selected at each iteration
% Where the EAH is applied 
nTest = 144 ;
nRep = 4;

Table_of_Results = zeros(nTest,nRep,4); % 1.Objective, 2.TWT, 3.TEC, 4.CPUTime
SolCollection = [];


%% Input
Run = 1 ;
for test = 21:40 %nTest

load(['L',num2str(test)]) ;

InitialPop = InitialPopulation(AlgParams,Pr) ;

  
for rep = 1:nRep
  
    
    
%% Initial Population

Pop = InitialPop;

CPU_Time = tic;

%%%Ranking
[~, Ind] = min([Pop.Obj]) ;
BestSolution = Pop(Ind) ;

%% Main Loop
NonImpovedIt = 0 ;
BestObjs = zeros(1,AlgParams.Iteration) ; BestObjs(1) = BestSolution.Obj ;
MeanObjs = zeros(1,AlgParams.Iteration) ; MeanObjs(1) = mean([Pop.Obj]) ;

for Iteration=2:AlgParams.Iteration

disp(['It :   ' num2str(Iteration), ', Best: ',num2str(BestSolution.Obj) ])

Vpop = Mutation(Pr, AlgParams, Pop) ;

Upop = Crossover(Pr, AlgParams, Pop, Vpop) ;

Pop = Selection(AlgParams, Pop, Upop) ;

Pop = TECiprovement(AlgParams, Pr, Pop) ;

[~, Ind] = min([Pop.Obj]) ;
BestSolution = Pop(Ind) ;

BestObjs(Iteration) = BestSolution.Obj ;
MeanObjs(Iteration) = mean([Pop.Obj]) ;

if BestObjs(Iteration-1)<= BestSolution.Obj
    NonImpovedIt = NonImpovedIt + 1;
else
    NonImpovedIt = 0 ;
end

CPUTime = toc(CPU_Time);

% Break condition
if NonImpovedIt > AlgParams.BreakCondition  || CPUTime > AlgParams.Timelimit
    break
end

end


%% Results
CPUTime = toc(CPU_Time);
[TWT, TEC] = VariableShow(BestSolution.Var,Pr);
BestSolution.Obj
fName = ['Sol_L',num2str(test),'_r',num2str(rep)];
save(fName,'BestSolution');

Table_of_Results(test,rep,1) = BestSolution.Obj;
Table_of_Results(test,rep,2) = TWT;
Table_of_Results(test,rep,3) = TEC;
Table_of_Results(test,rep,4) = CPUTime;

end
fName = ['Table_of_Results',num2str(Run)];
save(fName,'Table_of_Results')

end












