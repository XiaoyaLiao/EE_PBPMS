clc
clear

Case = 1 ; % 1: small, 2: large, 3: Taguchi
%% Scale adjusting
switch Case

    case 1
    % Small instances
    
        nJob = [9 15 20];
        nMachine = 2;
        nFamily = 2;
        alphaRi = [0.1 .3]; 
        bethaDi = [3 5];       
        STRation = [10 30]; % Standby Switch Ration
        Lambda = [ 0.3 0.5 0.7 ];
    
    case 2 
    % Large instances
    
        nJob = [50 100 200];
        nMachine = [3 5];
        nFamily = 3;
        alphaRi = [.1 .3 .5];
        bethaDi = [3 5];  
        STRation = [10 30]; % Standby Switch Ration
        Lambda = [0.3  0.5  0.7];
        
    case 3 
    % Small instances
        
        nJob = [9 15 20];
        nMachine = 2;
        nFamily = 2;
        alphaRi = [0.1 0.3];
        bethaDi = [3 5];  
        STRation = [10 30]; % Standby Switch Ration
        Lambda = [0.3  0.5  0.7];
end


Levels = [];
switch Case
    case 3
        % Taguchi
        
        for nJ = [100 200]
            if nJ==100
                nM = 3;
            else
                nM = 5;
            end
            nf = 3;
            rr = 0.3;
            for dd = [3 5]
                for nLam = [0.3 0.5 0.7]
                    for STR = [10 30]
                        Level = zeros(7,1);
                        Level(1,1) = nJ;
                        Level(2,1) = nM;
                        Level(3,1) = nf; 
                        Level(4,1) = rr; % alpha for Ri
                        Level(5,1) = dd; % betha for Di
                        Level(6,1) = STR; % Standby Switch Ration
                        Level(7,1) = nLam;
                        Levels = [Levels Level];
                    end
                end
            end
        end
    
    case 2 % Large
        
        for nJ = nJob
            for nM = nMachine
                for nf = nFamily
                   
                    if nM == 3
                        MalphaRi = alphaRi(2:3) ;
                    else
                        MalphaRi = alphaRi(1:2) ;
                    end
                   
                    for rr = MalphaRi
                        for dd = bethaDi
                            for STR = STRation
                                for nLam = Lambda
                                    Level = zeros(7,1);
                                    Level(1,1) = nJ;
                                    Level(2,1) = nM;
                                    Level(3,1) = nf; 
                                    Level(4,1) = rr; % alpha for Ri
                                    Level(5,1) = dd; % betha for Di
                                    Level(6,1) = STR; % Standby Switch Ration
                                    Level(7,1) = nLam;
                                    Levels = [Levels Level];
                                end
                            end
                        end
                    end
                end
            end
        end
        
    case 1 % Small
        for nJ = nJob
            for nM = nMachine
                for nf = nFamily
                   
                    alphaRi ;
                    bethaDi ;
                    for nn = 1:2
                        rr = alphaRi(nn);
                        dd = bethaDi(2-nn+1);
                  
                        for STR = STRation
                            for nLam = Lambda
                                Level = zeros(7,1);
                                Level(1,1) = nJ;
                                Level(2,1) = nM;
                                Level(3,1) = nf; 
                                Level(4,1) = rr; % alpha for Ri
                                Level(5,1) = dd; % betha for Di
                                Level(6,1) = STR; % Standby Switch Ration
                                Level(7,1) = nLam;
                                Levels = [Levels Level];
                            end
                        end
                        
                    end
                end
            end
        end

end

switch Case
    case 1
    save('Slevels','Levels')
    case 2
    save('Llevels','Levels')
    case 3
    save('Tlevels','Levels')   
end
%% Problem Parameters

for Instance = 1:size(Levels,2)
Pr.lambda =  Levels(7,Instance) ;

Pr.Nj = Levels(1,Instance);
Pr.Nm = Levels(2,Instance);

nF = Levels(3,Instance); % the number of families

Pr.P = randi([1,100],1,Pr.Nj); %ones(1,Pr.Nj); %
Speeds = [1 1.5 2 2.5 3] ;
Pr.V = Speeds(1:Pr.Nm);

Cmax = sum(Pr.P(:))/Pr.Nm; 
Pr.R = randi([0, ceil(Levels(4,Instance)*Cmax)],1,Pr.Nj); % zeros(1,Pr.Nj); %
Pr.d = Pr.R + randi([1,Levels(5,Instance)],1,Pr.Nj).*Pr.P; % zeros(1,Pr.Nj); %

Pr.alpha = randi([1,4],1,Pr.Nj); %ones(1,Pr.Nj); %
Pr.w = randi([1,6],1,Pr.Nj); %ones(1,Pr.Nj); %
Pr.B = 5.*randi([3,5],1,Pr.Nm);

CapRation = Pr.B/min(Pr.B);

Pr.beta1 = 2.*(Pr.V.^1.1) .* CapRation;             % Operation
Pr.beta2 = 1 .* CapRation;    % Standby
Pr.beta3 = Levels(6,Instance).*CapRation;  % Stitch OFF/ON
Pr.to = Pr.beta3./Pr.beta2;

JobsFamily = randi([1 nF],1,Pr.Nj);
Pr.b = zeros(Pr.Nj) ;
for ii = 1:Pr.Nj
    for jj = ii+1:Pr.Nj
        Pr.b(ii,jj) =  (JobsFamily(ii)==JobsFamily(jj));
        Pr.b(jj,ii) = Pr.b(ii,jj) ;
    end
end


[~, Order] = sort(Pr.R);
MachAvailality = 0;
S = zeros(1,Pr.Nj);
C = zeros(1,Pr.Nj);
for job = Order
    S(job) = max([MachAvailality Pr.R(job)]); 
    C(job) = S(job) + Pr.P(job)/max(Pr.V);
    MachAvailality = C(job) ;
end
Pr.MaxTWT = sum(max(0,Pr.alpha.*(C-Pr.d))) ;

[~, mm] = max(Pr.V);
eOpration = sum(Pr.beta1(mm).*(C - S)) ; % Operating energy
eStabdby = 0 ;
eSwitch = Pr.beta3(mm) ;
Wating = S(Order(2:end)) - C(Order((1:end-1))) ;
eStabdby = eStabdby + sum((Wating<=Pr.to(mm)).*Wating.*Pr.beta2(mm)) ;
eSwitch = eSwitch + sum((Wating>Pr.to(mm)).*Pr.beta3(mm)) ;
Pr.MaxTEC = eOpration + eStabdby + eSwitch ;


  
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

switch Case
    case 1
        fName = ['S',num2str(Instance)]; 
    case 2
        fName = ['L',num2str(Instance)]; 
    case 3
        fName = ['T',num2str(Instance)]; 
end
save(fName,'Pr')

% disp('-----------------------------------------------')
end




 