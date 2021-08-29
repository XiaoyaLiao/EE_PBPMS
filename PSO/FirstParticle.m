function [Velocity, Particle, Pbest] =FirstParticle(AlgParams,Pr)
%tic

Sol.Priority = inf(Pr.Nv,2*Pr.Np + 1);
Sol.Ass = zeros(1,Pr.Np);

Sol.X = zeros(Pr.N,Pr.N,Pr.Nv) ;
Sol.A = zeros(1,Pr.N) ;
Sol.B = zeros(1,Pr.N) ;
Sol.D = zeros(1,Pr.N) ;
Sol.W = zeros(1,Pr.N) ;
Sol.Y = zeros(Pr.N,Pr.Nf,Pr.Nv) ;
Sol.Routs = zeros(Pr.Nv+1,2*Pr.Np+1) ; % +1 is for dummy vehicle standing for rejected requests
Sol.RoutObj = zeros(Pr.Nv+1,6) ;
Sol.Obj = inf ;

Particle = repmat(Sol,1,AlgParams.PopSize) ;
Pbest = Particle ;
PFeas = zeros(1,AlgParams.PopSize) ;

for ii = 1:AlgParams.PopSize 
    ii
    for pp = 1:Pr.Np
        o = pp ;
        d = pp + Pr.Np ;
        
%         Particle(ii).Priority(:,o) = random('unif',Pr.e(o),Pr.l(o),1,1)/Pr.H ;
%         Particle(ii).Priority(:,d) = random('unif',Pr.e(d),Pr.l(d),1,1)/Pr.H ;

        if Pr.CrtclPnt(pp)==1
            Particle(ii).Priority(:,o) = random('unif',Pr.e(o),Pr.l(o),1,1)/Pr.H ;
            Particle(ii).Priority(:,d) = Particle(ii).Priority(1,o) + 0.001 ;
        else
            Particle(ii).Priority(:,d) = random('unif',Pr.e(d),Pr.l(d),1,1)/Pr.H ;
            Particle(ii).Priority(:,o) = Particle(ii).Priority(1,d) - 0.001 ;
        end
        
        PsblVcls = find(Pr.PsblVclforPss(pp,:)==1) ;
        if isempty(PsblVcls)
            vv = Pr.Nv+1 ;
            nUnSrvd = sum(Particle(ii).Routs(Pr.Nv+1,:)>0) ;
            Particle(ii).Routs(Pr.Nv+1,nUnSrvd+1:nUnSrvd+2) = [o d] ;
            Particle(ii).Ass(pp) = vv ;
        else
            %PsblVcls = [PsblVcls Pr.Nv+1] ;
            %PsblVcls = 1:3 ;
            v = randi([1 numel(PsblVcls)],1,1) ;
            vv = PsblVcls(v) ;
            Particle(ii).Ass(pp) = vv ;
        end
    end
    
    Unserved = find(Particle(ii).Ass==Pr.Nv+1) ;
    Particle(ii).Routs(Pr.Nv+1,1:2*numel(Unserved)) = [Unserved Unserved+Pr.Np] ;
    Particle(ii) = ObjCal(Particle(ii),Pr,Pr.Nv+1) ;
    
    for vv = 1:Pr.Nv
        
        Assigned =  find(Particle(ii).Ass==vv) ;
        if isempty(Assigned)  
            continue
        end
        Particle(ii).Priority(vv,end) = random('unif',Pr.e(Pr.Brk(vv)),Pr.l(Pr.Brk(vv)),1,1)/Pr.H ;
        Assigned = [Assigned Assigned+Pr.Np Pr.Brk(vv)] ;
        [~, Order] = sort(Particle(ii).Priority(vv,[Assigned(1:end-1) 2*Pr.Np+1])) ;
        Rout = Assigned(Order) ;
        Particle(ii).Routs(vv,:) = [Rout zeros(1,2*Pr.Np+1-numel(Rout))] ;
        Particle(ii) = ObjCal(Particle(ii),Pr,vv) ;
        
        Reqs = (Rout(Rout<=Pr.Np)) ;
        
        for ss = Reqs
            Particle(ii) = ImprovePair(Particle(ii),Pr,vv,ss) ;
        end
        
        Particle(ii) = ImproveBreak(Particle(ii),Pr,vv) ;

    end
    Pbest(ii) =  Particle(ii) ; 
end

% toc
% Objs = zeros(AlgParams.PopSize,1) ;
% for ii=1:AlgParams.PopSize
%     Objs(ii) = sum(Particle(ii).RoutObj(:)) ;
% end
% [MIN Ind] = min(Objs)
% any(Particle(Ind).RoutObj(:,2:end)>0)

Sol.Priority = zeros(Pr.Nv,2*Pr.Np+1);
Velocity = repmat(Sol,1,AlgParams.PopSize); 


%toc