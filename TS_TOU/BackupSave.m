%% Preparation
clc;
clear;
close all;
tic ;
%% Input

load('Pr') ;

%% Algorithm Parameters

AlgParams.Iterations =  150000 ;
AlgParams.Penalty = [ 100 100 100] ;

AlgParams.Teure = 10 ; 
AlgParams.InIt = 3 ; 
AlgParams.Ro = 0.005 ; 
AlgParams.Epsilon = 0.2 ;
AlgParams.Sigma = 0.001 ; 
AlgParams.LSPeriod = 10 ; 
AlgParams.NonImprIt = 200 ;
AlgParams.CPU = 600 ;

AlgParams.Ferquency = zeros(Pr.Nm, Pr.Nj) ;
AlgParams.MaxTen = ceil(1.7*AlgParams.Teure) ;
AlgParams.MinTen = ceil(.7*AlgParams.Teure) ;
TabuList = zeros(1, AlgParams.Teure) ;

%% Initial Solution

Var = InitialSol(AlgParams, Pr) ;

% Best Solution 
Best = Var ;

%% Main Loop
CPU_time = tic;
ImprvCuntr = 0 ;
Counter = 0 ;
BestFeasible = [] ;
for Iteration = 1:AlgParams.Iterations
    disp(["Iteration: ",num2str(Iteration),', Best Obj = ', num2str(Best.Obj), ', Var Obj = ', num2str(Var.Obj)])
pause(0.01)
    CF = Var.Obj ;
    NeighVar = Var ;
    NeighVar.Obj = inf ;
    SlctdR = 0 ;
    SlctdV = 0 ;
    
    
            
            
    for rr = 1:Pr.Nj             
        
        cMachine = Var.Ass(rr) ;
        
        btch = Var.Btch(rr) ;
        
        if  Pr.P(rr)/Pr.V(cMachine) < Var.Pb{cMachine}(btch) && Pr.d(rr) > Var.Cb{cMachine}(btch) && Pr.R(rr) < Var.Sb{cMachine}(btch)
            continue
        end
        
        AlterMachines = 1:Pr.Nm ; 
        AlterMachines = AlterMachines(AlterMachines~=cMachine) ;
        
        for nMachine = AlterMachines
            
            if sum(any(TabuList == (nMachine-1)*Pr.Nj + rr, 1))>0  
                continue
            end
            
            NewVar = Var ;  
            
            % Remove
%             disp([cMachine btch rr ])
            NewVar = RomoveJob(NewVar, Pr, cMachine, btch, rr) ;
                  
            % Insert
            NewVar = InsertJob(NewVar, Pr, nMachine, rr) ;
            
% nnVar = NewVar ;
% for mm = 1:Pr.Nm
%     nnVar = Scheduler(Pr,nnVar,mm,1) ;
% end

            NewVar.Pen = (NewVar.Obj >= CF) * AlgParams.Ro * AlgParams.Ferquency(nMachine,rr) * sqrt(Pr.Nj*Pr.Nm) * sum(NewVar.mObj) ;
% if NewVar.Pen > 0
%     pause
% end
            if NewVar.Obj + NewVar.Pen <= NeighVar.Obj + NeighVar.Pen
                NeighVar = NewVar ; 
                SlctdJob = rr ;
                SlctdMch = nMachine ;
                           
            end
        
        end
    end

    
    
    Var = NeighVar ;
    TabuList = [(SlctdMch-1)*Pr.Nj + SlctdJob TabuList(1:end-1)] ;  
    AlgParams.Ferquency(SlctdMch,SlctdJob) = AlgParams.Ferquency(SlctdMch,SlctdJob) + 1 ;

    % Local Search
%     if rem(Iteration,AlgParams.LSPeriod)==0
%        % Var = LocalSearch(Pr,Var,AlgParams) ;
%     end
    
    if Var.Obj < Best.Obj
        Best = Var ;         
        ImprvCuntr = 0 ;
        TabuList = TabuList(1:max(AlgParams.MinTen,ceil(numel(TabuList)*(1-AlgParams.Epsilon)))) ;
    else
        ImprvCuntr = ImprvCuntr + 1 ;
        if ImprvCuntr > 3 
            TabuList = [TabuList zeros(1,ceil(numel(TabuList)*AlgParams.Epsilon))] ;
            if numel(TabuList)>AlgParams.MaxTen
                TabuList = TabuList(1:max(AlgParams.MaxTen)) ;
            end
        end
    end

if ImprvCuntr>AlgParams.NonImprIt  || toc(CPU_time)>AlgParams.CPU
    break
end
   
if rem(ImprvCuntr,10)==0 
    Var = Best ;
end


end




disp(["CPU time: ",num2str(toc(CPU_time))])







nnVar = Best ;
for mm = 1:Pr.Nm
    nnVar = Scheduler(Pr,nnVar,mm,1) ;
end





















