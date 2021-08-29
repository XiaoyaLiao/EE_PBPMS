function Var = RomoveJob(~,Var, Pr, cMachine, btch, rr) 
   %      NewVar = RomoveJob(AlgParams, Var, Pr, cMachine, btch, rr) ;
% Var = NewVar;
% cMachine= Var.Ass(Jobs(1)) ;
% rr =Jobs ;

JobsOnMach = [Var.Seq{cMachine}] ;
JobOnBch = JobsOnMach(Var.Btch(JobsOnMach)==btch);

% % disp(["rr = ",num2str(rr)])
% % disp(["batches: ", num2str(unique(Var.Btch(JobsOnMach)))])
% % disp(["JobOnBch = ", num2str(JobOnBch)])

Var.S(rr) = 0 ;
Var.C(rr) = 0 ;
Var.W(rr) = 0 ;
Var.Ass(rr) = 0 ;
Var.Btch(rr) = 0 ;

Var.Seq{cMachine} = setdiff(Var.Seq{cMachine}, rr) ;

if numel(JobOnBch) == numel(rr)
    
    LaterBch = JobsOnMach(Var.Btch(JobsOnMach)> btch) ;
    Var.Btch(LaterBch) = Var.Btch(LaterBch) - 1 ;
   
    
    Var.Pb{cMachine}(btch) = [] ;
    Var.Sb{cMachine}(btch) = [] ;
    Var.Cb{cMachine}(btch) = [] ;
    Var.pFam{cMachine}(btch) = [] ;
    Var.pCap{cMachine}(btch) = [] ; 
    
end

% % if numel(setdiff(JobOnBch,rr)) == numel(JobOnBch)
% %     disp(["JobOnBch = ", num2str(JobOnBch)])
% %     disp(["rr = ",num2str(rr)])
% % end
% % 
% JobsOnMach = setdiff(JobsOnMach,rr) ;
% H1 = unique(Var.Btch(JobsOnMach)) ;
% H2 = 1:numel(H1) ;
% if ~isempty(setdiff(H2,H1))
%     disp(H1)
%     disp(H2)
%     pause
% end

Var = Scheduler(Pr,Var,cMachine,btch) ;
           



