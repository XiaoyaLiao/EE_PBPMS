%% %%%%%%%%%%%%%%%%%% PSO %%%%%%%%%%%%%%%%%%%%%%%%%
%% start of the program
clc;
clear ;
close all;
tic;
%%%%%%%%%%%%%%%%%%%% tune dx and localSearch rate
%% Inputs

load('Pr');


%% Algorithm Parameter
AlgParams.PopSize = 100;
AlgParams.Iteration = 100;

AlgParams.BreakCondition = 50;
xmin = [repmat(Pr.e(1:2*Pr.Np)/Pr.H,Pr.Nv,1) Pr.e(Pr.Brk)'/Pr.H] ; 
xmax = [repmat(Pr.l(1:2*Pr.Np)/Pr.H,Pr.Nv,1) Pr.l(Pr.Brk)'/Pr.H] ;
dx= xmax-xmin;
vmax = 0.4*dx;

w=0.99;
wdamp=0.995;

c1=2;
c2=2;
cp = 0.4 ;
cg = 0.3 ;
cr = 0.0 ;
%% Initial Population

[Velocity, Particle, Pbest] = FirstParticle(AlgParams,Pr);

[Min, Andc] = min([Pbest.Obj]) ;
Gbest = Particle(Andc(1)) ;

TheBests = zeros(1,AlgParams.Iteration) ;
TheMeans = zeros(1,AlgParams.Iteration) ;
TheBests(1) = Min ;
TheMeans(1) = mean([Particle.Obj]) ;

%% Main Loop
for Iteration=2:AlgParams.Iteration
disp(['Iteration :  ' , num2str(Iteration)]);

for i=1:AlgParams.PopSize
%disp(['particle: ' , num2str(i)])

%%% Priority
    Velocity(i).Priority=w.*Velocity(i).Priority ...
                        +c1*rand(size(Velocity(i).Priority)).*(Pbest(i).Priority-Particle(i).Priority)...
                        +c2*rand(size(Velocity(i).Priority)).*(Gbest.Priority-Particle(i).Priority);

    Velocity(i).Priority=min(max(Velocity(i).Priority,-vmax),vmax);
    
    Particle(i).Priority=Particle(i).Priority+Velocity(i).Priority;
    
    Particle(i).Priority=min(max(Particle(i).Priority,xmin),xmax);
        
%%% Assignment
    Equivals = find(Pbest(i).Ass==Gbest.Ass) ;
    ChanceP = w.*cp.*ones(1,Pr.Np) ; %
    ChanceG = w.*cg.*ones(1,Pr.Np) ;
    ChanceR = w.*cr.*ones(1,Pr.Np) ;
    ChanceP(Equivals) = ChanceP(Equivals) + ChanceG(Equivals) ;
    
    Guid = rand(1,Pr.Np) ;
    Slctd = find(Guid<=ChanceP) ;
    Particle(i).Ass(Slctd) = Pbest(i).Ass(Slctd) ;
    
    Guid = rand(1,Pr.Np) ;
    Slctd = find(Guid<=ChanceG) ;
    Particle(i).Ass(Slctd) = Gbest.Ass(Slctd) ; 
    
    Guid = rand(1,Pr.Np) ;
    Slctd = find(Guid<=ChanceR) ;
    for pp = Slctd
        PsblVcls = find(Pr.PsblVclforPss(pp,:)==1) ;
        if isempty(PsblVcls)
            vv = Pr.Nv+1 ;
        else
           % PsblVcls = [PsblVcls Pr.Nv+1] ;
           %PsblVcls = 1:3 ;
            %PsblVcls(PsblVcls==Particle(i).Ass(pp)) = [] ;
            %PsblVcls(PsblVcls==Pbest(i).Ass(pp)) = [] ;
            %PsblVcls(PsblVcls==Gbest.Ass(pp)) = [] ;
            v = randi([1 numel(PsblVcls)],1,1) ;
            vv = PsblVcls(v) ;
        end
        Particle(i).Ass(pp) = vv ;
    end
    
    %%% Local search

    Particle(i) = PreAssign(Pr,Particle(i)) ;

    if rand<.0 %%%%%%%%
        if sum(sum(Particle(i).RoutObj(:,2:end)))==0
            for cc =1:Pr.Nv 
                Particle(i) = RemoveRout(Particle(i),Pr) ; 
            end
        end
        %Particle(i) = LocalSearch(Particle(i),Pr,1:Pr.Nv) ;
    end
    if rand<0.5
        %Particle(i) = ServeUnserved(Particle(i),Pr) ;
    end
    if rand<0.2
        %Particle(i) = LocalSearch(Particle(i),Pr,1:Pr.Nv) ;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if  Particle(i).Obj < Pbest(i).Obj 
        Pbest(i) = Particle(i) ;    
    end
    if Particle(i).Obj < Gbest.Obj
        Gbest=Particle(i);
    end
    if sum(sum(Gbest.RoutObj(:,2:end))) == 0 
        %Gbest = ServeUnserved(Gbest,Pr) ;
        NGbest = RemoveRout(Gbest,Pr) ; 
        if NGbest.Obj < Gbest.Obj
            Gbest = NGbest ;
        end
        %Gbest = LocalSearch(Gbest,Pr,1:Pr.Nv) ;
    end
end 

w=w*wdamp;

TheBests(Iteration) = Gbest.Obj ;
TheMeans(Iteration) = mean([Particle.Obj]) ;

if Iteration > AlgParams.BreakCondition && round(TheBests(Iteration-AlgParams.BreakCondition)) == round(TheBests(Iteration))
    break
end

Y = TheBests(Iteration) ;
X= Iteration;
plot(X,Y,'.r');
pause(0.001)
hold on

end



%% Results
% %clc
Y = TheBests(1:Iteration) ;
Y2= TheMeans(1:Iteration) ;
X=1:numel(Y);
plot(X,Y,'.r');title('Best');
Gbest

% Var = VariableFunc(Gbest,Pr); 
 disp(['CPU Time: ', num2str(toc)])


