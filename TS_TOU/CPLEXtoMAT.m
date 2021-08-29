a = [5	1	1	1
4	2	1	1
3	2	1	1
2	1	2	1
1	1	2	1
] ;


Var = [] ;
Var.S = zeros(1,Pr.Nj) ;
Var.C = zeros(1,Pr.Nj) ;
Var.W = zeros(1,Pr.Nj) ;

Var.Sb = cell(Pr.Nm,1) ;
Var.Cb = cell(Pr.Nm,1) ;
Var.Pb = cell(Pr.Nm,1) ;
Var.pFam = cell(Pr.Nm,1) ;
Var.pCap = cell(Pr.Nm,1) ;

Var.Seq = cell(Pr.Nm,1) ;
Var.Btch = zeros(1,Pr.Nj) ; 
Var.Ass = zeros(1,Pr.Nj) ; 

Var.mObj = inf(Pr.Nm,3) ; % 1.Objective, 2.Family, 3.Capacity
Var.Pen = 0 ;

for ii =1:Pr.Nj
    r = find(a(:,1)==ii);
    m = a(r,2);
    b = a(r,3);
    Var.Seq{m} = [Var.Seq{m} ii] ;
    Var.Btch(ii) = b ;
    Var.Ass(ii) = m ;
end


Var = BestFeasible ;

for mm = 1:Pr.Nm
    Var = Scheduler(Pr,Var,mm,1) ;
end
disp(num2str(sum(Var.mObj)))


clc
for jj = 1:Pr.Nm
    disp(['Var.Seq{',num2str(jj),'} = [',num2str(Var.Seq{jj}),'];'])
        
    disp(['Var.Sb{',num2str(jj),'} = [',num2str(Var.Sb{jj}),'];'])
    disp(['Var.Cb{',num2str(jj),'} = [',num2str(Var.Cb{jj}),'];'])
end
disp(['Var.Btch = [',num2str(Var.Btch),'];'])
disp(['Var.Ass = [',num2str(Var.Ass),'];'])

disp(['Objective = ', num2str(sum(Var.mObj(:)))])

