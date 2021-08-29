clc
clear

Small = 1 ;
%% Scale adjusting
if Small == 1
    % Small instances
    nTest = 40;
    nJob = [9 15];
    nMachine = 2;
    alphaRi = [0.5 2]; 
    bethaDi = [3 5];       
    STRation = [5 10];
    Lambda = 0:0.25:1;
else
    % Large instances
    nTest = 160;
    nJob = [50 100 200 300];
    nMachine = [3 5];
    alphaRi = [0.5 2];
    bethaDi = [3 5];  
    STRation = [5 10];
    Lambda = 0:0.25:1;
end

Levels = zeros(6,nTest);

cc = 1 ;
for nJ = nJob
    for nM = nMachine
        for ii = 1:2
            for STR = STRation
                for nLam = Lambda
                    Levels(1,cc) = nJ;
                    Levels(2,cc) = nM;
                    Levels(3,cc) = alphaRi(ii); % alpha for Ri
                    Levels(4,cc) = bethaDi(ii); % betha for Di
                    Levels(5,cc) = STR; % Standby Switch Ration
                    Levels(6,cc) = nLam;
                    cc = cc +1 ;
                end
            end
        end
    end
end

if Small == 1
    save('Slevels','Levels')
else
    save('Llevels','Levels')
end
%% Problem Parameters

for Instance = 1:nTest
Pr.lambda =  Levels(6,Instance) ;

Pr.Nj = Levels(1,Instance);
Pr.Nm = Levels(2,Instance);

nF = 3; % the number of families

Pr.P = randi([1,100],1,Pr.Nj); %ones(1,Pr.Nj); %
Speeds = [1 1.5 2 2.5 3] ;
Pr.V = Speeds(1:Pr.Nm);

Cmax = sum(Pr.P(:))/Pr.Nm; 
Pr.R = randi([0, ceil(Levels(3,Instance)*Cmax)],1,Pr.Nj); % zeros(1,Pr.Nj); %
Pr.d = Pr.R + randi([1,Levels(4,Instance)],1,Pr.Nj).*Pr.P; % zeros(1,Pr.Nj); %

Pr.alpha = randi([1,4],1,Pr.Nj); %ones(1,Pr.Nj); %
Pr.w = randi([1,6],1,Pr.Nj); %ones(1,Pr.Nj); %
Pr.B = 5.*randi([2,4],1,Pr.Nm);

CapRation = Pr.B/10;

Pr.beta1 = 2.*(Pr.V.^2) .* CapRation;             % Operation
Pr.beta2 = 1 .* CapRation;    % Standby
Pr.beta3 = Levels(5,Instance).*CapRation;  % Stitch OFF/ON
Pr.to = Pr.beta3./Pr.beta2;

JobsFamily = randi([1 nF],1,Pr.Nj);
Pr.b = zeros(Pr.Nj) ;
for ii = 1:Pr.Nj
    for jj = ii+1:Pr.Nj
        Pr.b(ii,jj) =  (JobsFamily(ii)==JobsFamily(jj));
        Pr.b(jj,ii) = Pr.b(ii,jj) ;
    end
end

Pr.ft = [0.4 0.8 1.3 0.8 1.3 0.8];
Pr.brk = [-1 7 10 15 18 21 23];


% [~, Order] = sort(Pr.R);
% MachAvailality = 0;
% S = zeros(1,Pr.Nj);
% C = zeros(1,Pr.Nj);
% for job = Order
%     S(job) = max([MachAvailality Pr.R(job)]); 
%     C(job) = S(job) + Pr.P(job)/max(Pr.V);
%     MachAvailality = C(job) ;
% end
% Pr.MaxTWT = sum(max(0,Pr.alpha.*(C-Pr.d))) ;
% 
% [~, mm] = max(Pr.V);
% eOpration = sum(Pr.beta1(mm).*(C - S)) ; % Operating energy
% eStabdby = 0 ;
% eSwitch = Pr.beta3(mm) ;
% Wating = S(Order(2:end)) - C(Order((1:end-1))) ;
% eStabdby = eStabdby + sum((Wating<=Pr.to(mm)).*Wating.*Pr.beta2(mm)) ;
% eSwitch = eSwitch + sum((Wating>Pr.to(mm)).*Pr.beta3(mm)) ;
% Pr.MaxTEC = eOpration + eStabdby + eSwitch ;


  
%% Display for CPLEX

% disp(['Nj=',num2str(Pr.Nj),';']);
% disp(['Nm=',num2str(Pr.Nm),';']);
% % disp(['Nt=',num2str(Pr.Nt),';']);
% 
% % disp(['I=[',num2str(Pr.I),'];']);
% % disp(['gama=[',num2str(Pr.gama),'];']);
% 
% disp(['P=[',num2str(Pr.P),'];']);
% disp(['R=[',num2str(Pr.R),'];']);
% disp(['d=[',num2str(Pr.d),'];']);
% disp(['w=[',num2str(Pr.w),'];']);
% disp(['alpha=[',num2str(Pr.alpha),'];']);
% disp('b=[');
% for ii=1:size(Pr.b,1)
%     if ii<size(Pr.b,1)
%         disp(['[',num2str(Pr.b(ii,:)),'],']);
%     else
%         disp(['[',num2str(Pr.b(ii,:)),']']);
%     end
% end
% disp('];')
% 
% disp(['B=[',num2str(Pr.B),'];']);
% disp(['V=[',num2str(Pr.V),'];']);
% disp(['tau=[',num2str(Pr.to),'];']);
% disp(['beta1=[',num2str(Pr.beta1),'];']);
% disp(['beta2=[',num2str(Pr.beta2),'];']);
% disp(['beta3=[',num2str(Pr.beta3),'];']);
% 
% disp('L=1000;')

% disp(['lambda=' ,num2str(Pr.lambda)]);

if Small == 1
    fName = ['S',num2str(Instance)]; 
else
    fName = ['L',num2str(Instance)]; 
end
save(fName,'Pr')

disp('-----------------------------------------------')
end




 