clc
clear



%% Problem Parameters


Pr.Nj = 15;
Pr.Nm = 2;

nF = 1; % the number of families

Pr.P = randi([1,20],1,Pr.Nj); %ones(1,Pr.Nj); %
Speeds = [1 1.5 2 2.5 3] ;
Pr.V = Speeds(1:Pr.Nm);

Cmax = sum(Pr.P(:))/Pr.Nm; 
Pr.R = randi([0, ceil(2*Cmax)],1,Pr.Nj); % zeros(1,Pr.Nj); %
Pr.d = Pr.R + randi([1,10],1,Pr.Nj).*Pr.P; % zeros(1,Pr.Nj); %

Pr.alpha = randi([1,4],1,Pr.Nj); %ones(1,Pr.Nj); %
Pr.w = randi([1,6],1,Pr.Nj); %ones(1,Pr.Nj); %
Pr.B = 5.*randi([2,4],1,Pr.Nm);

CapRation = Pr.B/10;

Pr.beta1 = 2.*(Pr.V.^2) .* CapRation;             % Operation
Pr.beta2 = 1 .* CapRation;    % Standby
Pr.beta3 = 20.*CapRation;  % Stitch OFF/ON
Pr.to = Pr.beta3./Pr.beta2;

JobsFamily = randi([1 nF],1,Pr.Nj);
Pr.b = zeros(Pr.Nj) ;
for ii = 1:Pr.Nj
    for jj = ii+1:Pr.Nj
        Pr.b(ii,jj) =  (JobsFamily(ii)==JobsFamily(jj));
        Pr.b(jj,ii) = Pr.b(ii,jj) ;
    end
end
  
%% Display for CPLEX
clc
disp(['Nj=',num2str(Pr.Nj),';']);
disp(['Nm=',num2str(Pr.Nm),';']);
% disp(['Nt=',num2str(Pr.Nt),';']);

% disp(['I=[',num2str(Pr.I),'];']);
% disp(['gama=[',num2str(Pr.gama),'];']);

disp(['P=[',num2str(Pr.P),'];']);
disp(['R=[',num2str(Pr.R),'];']);
disp(['d=[',num2str(Pr.d),'];']);
disp(['w=[',num2str(Pr.w),'];']);
disp(['alpha=[',num2str(Pr.alpha),'];']);
disp('b=[');
for ii=1:size(Pr.b,1)
    if ii<size(Pr.b,1)
        disp(['[',num2str(Pr.b(ii,:)),'],']);
    else
        disp(['[',num2str(Pr.b(ii,:)),']']);
    end
end
disp('];')

disp(['B=[',num2str(Pr.B),'];']);
disp(['V=[',num2str(Pr.V),'];']);
disp(['tau=[',num2str(Pr.to),'];']);
disp(['beta1=[',num2str(Pr.beta1),'];']);
disp(['beta2=[',num2str(Pr.beta2),'];']);
disp(['beta3=[',num2str(Pr.beta3),'];']);

disp('L=1000;')


disp("lambda = 0.5 ;")


save('Pr','Pr');







 