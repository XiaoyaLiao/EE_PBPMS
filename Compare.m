%% %%%%%%%%%%%%%%%%%%%%%%% VRP Compare 3 Algorithms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Operation Scheduling %%%%%%%%%%%%%%%%%%%%%%%%%
%% Start Of Problem

clc;
close all;
clear;

%% Problem Definition

NumberofTest = 144 ;
NumOfRepeat = 4;   
NumOfAlgorithms = 4 ;

%% The Algorithms

for ins = 1:NumberofTest

    load(['L',num2str(ins)])

    for Rep=1:NumOfRepeat

        disp(['Ins: ',num2str(ins),', Rep: ',num2str(Rep)])  

        Algorithm = [] ;
        CPU_time = zeros(1,NumOfAlgorithms) ;

        %%% DEA
        addpath('DEA')
        [Algorithm{1},CPU_time(1)] = DEA_Pro(Pr,1);
        rmpath('DEA')

        %%% PSO
        addpath('PSO')
        [Algorithm{2},CPU_time(2)] = PSO_Pro(Pr,2);
        rmpath('PSO')
        
        %%% SA
        addpath('SA')
        [Algorithm{2},CPU_time(2)] = SA_Pro(Pr,2);
        rmpath('SA')

    end
    
    

        Combination=[Algorithm{1:NumOfAlgorithms}] ;
        save(['Combination_',num2str(ins),'_',num2str(Rep)],'Combination')

    end

end


