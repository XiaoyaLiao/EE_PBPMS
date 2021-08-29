
%% temporary file to get MaxTWT and MaxTEC for the tests


clc;
clear;
close all;
tic ;
%% Notes:

% I have to explain how a batch is selected at each iteration
% Where the EAH is applied 
nTest = 1 ;
nRep = 1;
 
TimeTable =  zeros(nTest,nRep);
ObjTable = zeros(nTest,nRep);
TWTTable = zeros(nTest,nRep);
TECTable = zeros(nTest,nRep);

%% Input
for test = 1:36 %[1 150 200 240]% 1:nTest

load(['S',num2str(test)]) ;

%% Algorithm Parameters

AlgParams.Iterations =  100000 ;
AlgParams.Penalty = [1 0.001 0.001] ;

AlgParams.Teure = 20 ; 
AlgParams.InIt = 3 ; 
AlgParams.Ro = 1 ; 
AlgParams.Epsilon = 0.05 ;
AlgParams.Sigma = 0.05 ; 
AlgParams.LSPeriod = 30 ; 
AlgParams.NonImprIt = 200 ;
AlgParams.CPU = 600 ;

AlgParams.Ferquency = zeros(Pr.Nm, Pr.Nj) ;
AlgParams.MaxTen = ceil(1.3*AlgParams.Teure) ;
AlgParams.MinTen = ceil(0.7*AlgParams.Teure) ;
TabuList = zeros(1, AlgParams.Teure) ;

%% Initial Solution
Collection = [];

addpath('TS')
[Pr, InitialVar] = InitialSol(AlgParams, Pr) ;
rmpath('TS')

fName = ['S',num2str(test)];
save(fName,'Pr')

disp(['Test: ',num2str(test)])
disp(['MaxTWT = ',num2str(Pr.MaxTWT)]) 
disp(['MaxTEC = ',num2str(Pr.MaxTEC)]) 

end