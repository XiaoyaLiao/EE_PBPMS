function Var = InitialSol(AlgParams, Pr) 

Var = [] ;
Var.S = zeros(1,Pr.Nj) ;  % starting time of each job
Var.C = zeros(1,Pr.Nj) ;  % completion time of each job
Var.W = zeros(1,Pr.Nj) ;  % ??

Var.Sb = cell(Pr.Nm,1) ;  % starting time of each machine
Var.Cb = cell(Pr.Nm,1) ;  % completion time of each machine
Var.Pb = cell(Pr.Nm,1) ;  % processing time of each batch
Var.pFam = cell(Pr.Nm,1) ;  % job family panelty
Var.pCap = cell(Pr.Nm,1) ;  % capacity


Var.Seq = cell(Pr.Nm,1) ;  % job sequence on each machine
Var.Btch = zeros(1,Pr.Nj) ;  % which batch a job belongs to
Var.Ass = zeros(1,Pr.Nj) ;  % which machine a job assigned


Var.mObj = inf(Pr.Nm,3) ; % 1.Objective, 2.Family, 3.Capacity
Var.Pen = 0 ;

% so, Var =
%        S: [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
%        C: [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
%        W: [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
%       Sb: 2×1 cell array
%           {0×0 double}
%           {0×0 double}
%       Cb: 2×1 cell array
%           {0×0 double}
%           {0×0 double}
%       Pb: 2×1 cell array
%           {0×0 double}
%           {0×0 double}
%     pFam: 2×1 cell array
%           {0×0 double}
%           {0×0 double}
%     pCap: 2×1 cell array
%           {0×0 double}
%           {0×0 double}
%      Seq: 2×1 cell array
%           {0×0 double}
%           {0×0 double}
%     Btch: [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]  % Pos
%      Ass: [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]  % machine number
%     mObj: [2×3 double]
%           Inf   Inf   Inf
%           Inf   Inf   Inf
%      Pen: 0

%% the first phase
% 1. jobs are sorted in an ascending order of their due times
[~, Jobs] = sort(Pr.d);
%    i = 1     2     3     4     5     6     7     8      9     10   11    12    13     14    15
% Pr.d = 159   173   109   181   261   221   168   205    77    75   117   107   119    93    41

% after sort by Pr.d

% original i = 15    10     9    14   12    3     11    13    1     7     2     4     8     6     5
% sort(Pr.d) = 41    75    77    93   107   109   117   119   159   168   173   181   205   221   261

% then get the original index as Jobs
% Jobs = 15    10     9    14    12     3    11    13     1     7     2     4     8     6     5

% 2. then, full batches are formed such that their load size does not exceed
% the maximum load capcacity, , and each pair of jobs in the same batch belongs to the same job family
btch = ones(1,Pr.Nj) ;  % batch
MachAvailablity = zeros(1,Pr.Nm);  % machine available time
% so that MachAvailablity = 0 0

for ii = Jobs  % for each element in Jobs represented as ii
     [~, mm] = min(MachAvailablity);  % get the index of the minimum element in MachAvailablity as mm
    % if there are more than one available mamchine by the time a batch is ready, the machine with highest speed is allocated to it  
%     [~, mm] = max(Pr.V == max(Pr.V(MachAvailablity==min(MachAvailablity))));
    Var = InsertJob(AlgParams, Var, Pr, mm, ii) ;  % insert job ii on machine mm
          % InsertJob(AlgParams,NewVar, Pr, nMachine, rr)
    MachAvailablity(mm) = max(MachAvailablity(mm),Pr.R(ii)) + Pr.P(ii)/Pr.V(mm) ;
end



% ?? why?
% Basic Scheduler
for mm = 1:Pr.Nm
    Var = Scheduler(Pr,Var,mm,1) ;
end


