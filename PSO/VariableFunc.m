function   Var = VariableFunc(Sol,Pr) 

Btch = ceil(Sol.Bch) ;

Var.C = zeros(Pr.I,Pr.M) ;
Var.D = zeros(1,Pr.I) ;
Var.T = zeros(1,Pr.I) ;
Var.E = zeros(1,Pr.I) ;

MachWrk = zeros(1,Pr.M);
Seq = Sol.Seq ;
for ii = 1:Pr.I
    [~, Job] = max(Seq) ;
    Seq(Job) = 0 ;
    Var.C(Job,1:end-1) = MachWrk(1:end-1) + Pr.p(Job,1:end-1) ;
    MachWrk(1:end-1) = Var.C(Job,1:end-1) ;
    Var.C(Job,end) = max(MachWrk(end),max(Var.C(Job,1:end-1))) + Pr.p(Job,end) ;
    MachWrk(end) = Var.C(Job,end) ;
end
Z = 0 ;
for bb = 1:Pr.I
    Batch = find(Btch==bb) ;
    if numel(Batch)>0
        Z = Z+1;
    end
    Var.D(Batch) = max(Var.C(Batch,end)) ;
end

Var.T = max(0, Var.D-Pr.d);
Var.E = max(0, Pr.d-Var.D);

Obj = sum(Var.E.*Pr.alpha) + Z*Pr.gama ;


    
disp('Completion Time : ')
disp(num2str(Var.C))

AA = [Var.D Var.E Var.T] ;
disp('D  E  T')
disp(num2str(AA))


disp(['Objective = ',num2str(Obj)]);

disp('  ')
disp('---------------------------------------------------')


 
 
