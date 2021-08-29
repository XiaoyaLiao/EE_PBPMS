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

%% Tests

test = 1;


load('L15')



%% Initial Population

Pop = InitialPopulation(AlgParams,Pr) ;

tic;

%%%Ranking
[~, Ind] = min([Pop.Obj]) ;
TheBestSolution = Pop(Ind) ;

%% Main Loop
NonImpovedIt = 0 ;
BestObjs = zeros(1,AlgParams.Iteration) ; BestObjs(1) = TheBestSolution.Obj ;
MeanObjs = zeros(1,AlgParams.Iteration) ; MeanObjs(1) = mean([Pop.Obj]) ;

for Iteration=2:AlgParams.Iteration

disp(['It :   ' num2str(Iteration), ', Best: ',num2str(TheBestSolution.Obj) ])

Vpop = Mutation(Pr, AlgParams, Pop) ;

Upop = Crossover(Pr, AlgParams, Pop, Vpop) ;

Pop = Selection(AlgParams, Pop, Upop) ;

Pop = TECiprovement(AlgParams, Pr, Pop) ;

[~, Ind] = min([Pop.Obj]) ;
TheBestSolution = Pop(Ind) ;

BestObjs(Iteration) = TheBestSolution.Obj ;
MeanObjs(Iteration) = mean([Pop.Obj]) ;

if BestObjs(Iteration-1)<= TheBestSolution.Obj
    NonImpovedIt = NonImpovedIt + 1;
else
    NonImpovedIt = 0 ;
end

% Break condition
if NonImpovedIt > AlgParams.BreakCondition 
    break
end

end

CPUTime = toc;

%clc
Y = BestObjs(1:Iteration) ;
Y2= MeanObjs(1:Iteration) ;
X=1:Iteration;
pause(0.01)
plot(X,Y,'r*',X,Y2,'b*') ;
legend("Best","Average")


%% Results

load('BestFeasible')
VV = BestFeasible; 
VV = TheBestSolution ;
[TWT, TEC] = VariableShow(VV,Pr);



disp(['Objective Values : ',num2str(TheBestSolution.Obj)])
disp(['CPU Times : ',num2str(CPUTime)])


disp(TheBestSolution.Obj) ;








