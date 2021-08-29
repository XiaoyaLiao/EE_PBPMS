clc;
clear;
close all ;

%% Benchmark 
a = [3 48 480 6 90];
b = [0   -1.044    2.000  0  0    0 1440
  1   -2.973    6.414 10  1    0 1440
  2   -3.066    0.546 10  1    0 1440
  3    5.164    0.547 10  1    0 1440
  4   -1.317    6.934 10  1    0 1440
  5   -6.741    6.832 10  1    0 1440
  6    4.891    0.627 10  1    0 1440
  7    0.524    2.226 10  1    0 1440
  8   -6.500    7.723 10  1    0 1440
  9   -0.417   -0.157 10  1    0 1440
 10    2.303    1.164 10  1    0 1440
 11    2.548    0.629 10  1    0 1440
 12   -4.261   -2.639 10  1    0 1440
 13   -7.667    9.934 10  1  325  358
 14   -2.067    5.789 10  1  111  152
 15   -5.204    0.657 10  1  395  421
 16   -4.138    5.082 10  1  386  401
 17   -9.194    2.759 10  1   86  114
 18   -6.512    3.021 10  1  409  426
 19    1.860    9.672 10  1  454  470
 20   -4.094    8.321 10  1  175  202
 21   -3.776   -3.333 10  1  416  453
 22    2.377    2.908 10  1  147  177
 23   -4.303    2.045 10  1  471  499
 24   -3.530   -2.490 10  1  321  346
 25   -5.476    1.437 10 -1  258  287
 26   -4.933    3.337 10 -1  329  361
 27    5.740    2.382 10 -1  209  252
 28   -2.275    5.541 10 -1  416  460
 29   -5.662    7.334 10 -1  305  349
 30   -3.856   -0.370 10 -1  432  458
 31   -1.678    1.954 10 -1  202  236
 32   -1.156    1.161 10 -1  225  252
 33   -4.655    9.797 10 -1  102  123
 34    1.623    0.932 10 -1  260  276
 35    0.129    0.735 10 -1  178  215
 36   -2.640    2.953 10 -1  381  397
 37    0.435    1.469 10 -1    0 1440
 38   -5.066   -2.313 10 -1    0 1440
 39   -2.283   -0.981 10 -1    0 1440
 40   -7.110   -1.862 10 -1    0 1440
 41   -0.785    3.207 10 -1    0 1440
 42    1.188   -2.493 10 -1    0 1440
 43   -1.893   -2.373 10 -1    0 1440
 44   -1.192    1.175 10 -1    0 1440
 45    2.984    1.163 10 -1    0 1440
 46    1.227   -5.581 10 -1    0 1440
 47   -3.793   -2.161 10 -1    0 1440
 48    4.288   -0.297 10 -1    0 1440] ;
b = b' ;
%% Preparation 

Pr.Np = a(2)/2 ;
Pr.Nv = a(1) ;
Pr.Nf = 10 ;
Pr.Ne = 4 ;
Pr.H = 1440 ;

Pr.N = 2*Pr.Np + 3*Pr.Nv ; % Nodes
Pr.Org = 1:Pr.Np ;
Pr.Dst = Pr.Np+1:2*Pr.Np ;
Pr.DpS = 2*Pr.Np+1:2*Pr.Np+Pr.Nv ;
Pr.DpE = 2*Pr.Np+Pr.Nv+1:2*Pr.Np+2*Pr.Nv ;
Pr.Brk = 2*Pr.Np+2*Pr.Nv+1:2*Pr.Np+3*Pr.Nv ;
% Node orders: Origins, Destination, Depot(Start), Depot(End)


Pr.teta = randi([0 0],Pr.Np, Pr.Ne) ; % Request required features
Pr.q = zeros(Pr.N,Pr.Nf) ; % Request required capacity 
Pr.q(Pr.Org,1) =  b(5,Pr.Org+1) ; 
Pr.q(Pr.Dst,1) =  b(5,Pr.Dst+1) ; 

Pr.e = [b(6,2:end) repmat(b(6,1),1,2*Pr.Nv) 300.*ones(1,Pr.Nv)] ; 
Pr.l = [b(7,2:end) repmat(b(7,1),1,2*Pr.Nv) 390.*ones(1,Pr.Nv)] ;

Pr.S = zeros(1,Pr.N);
Pr.S(1:2*Pr.Np) = 10 ; 
Pr.SF = ones(1,Pr.Nv) ; % Vehidle speed factor

XY = [b(2:3,2:end) repmat(b(2:3,1),1,2*Pr.Nv)] ;
Pr.T = zeros(Pr.N,Pr.N) ;
for ii = 1:Pr.N-Pr.Nv
    for jj = ii+1:Pr.N-Pr.Nv
        Pr.T(ii,jj) = ((XY(1,ii)-XY(1,jj))^2 + (XY(2,ii)-XY(2,jj))^2)^0.5 ;
        Pr.T(jj,ii) = Pr.T(ii,jj) ;
    end
end
Pr.C = Pr.T ;

Pr.R = zeros(Pr.Nv,Pr.Ne) ; % Vehicle Features                       
Pr.Q = zeros(Pr.Nv,Pr.Nf) ; % Vehicle Equiped Capacity
Pr.Q(:,1) = a(4) ; 


Pr.UP = a(5).*ones(1,Pr.Np) ;
Pr.UV = a(3).*ones(1,Pr.Nv) ;

Pr.CrtclPnt = ones(1,2*Pr.Np) ;
for ii = 1:Pr.Np
    if Pr.e(ii) == 0 && Pr.l(ii) == Pr.H 
        Pr.e(ii) = max(0,Pr.e(ii+Pr.Np)-Pr.UP(ii)-Pr.S(ii)) ;
        Pr.l(ii) = min(Pr.l(ii+Pr.Np)-Pr.T(ii,ii+Pr.Np)-Pr.S(ii), Pr.H) ;
        Pr.CrtclPnt(ii) = 0 ;
    else
        Pr.e(ii+Pr.Np) = max(0,Pr.e(ii)+Pr.T(ii,ii+Pr.Np)+Pr.S(ii)) ;
        Pr.l(ii+Pr.Np) = min(Pr.l(ii)+Pr.UP(ii)+Pr.S(ii),Pr.H) ;            
        Pr.CrtclPnt(ii+Pr.Np) = 0 ;
    end
end

% some othe must be added based on 
            
Pr.PsblVclforPss = zeros(Pr.Np,Pr.Nv) ;
for ii = 1:Pr.Np
    for jj = 1:Pr.Nv
        if sum(Pr.teta(ii,:).*Pr.R(jj,:)) == sum(Pr.teta(ii,:))
            Pr.PsblVclforPss(ii,jj) = 1 ;
        end
    end
end

Pr.MaxFonNodes = zeros(Pr.N,Pr.Nf,Pr.Nv); 
for vv = 1:Pr.Nv
    Pr.MaxFonNodes(:,:,vv) = repmat(Pr.Q(vv,:),Pr.N,1) ;
end

Pr.Fare = zeros(1,Pr.Np) ;
FareRate = 2.*ones(1,Pr.Np) ;

Pr.FeatRate = randi([1 5],1,Pr.Ne) ;
Pr.CapRate = randi([1 3],1,Pr.Nf) ;

% Vehicles fixed cost
Pr.F =  Pr.SF .* (Pr.R*Pr.FeatRate'+Pr.Q*Pr.CapRate')'; %randi([20 30],1,Pr.Nv) ; % Vehicle fixed cost ;

xx=[] ; 
for pp = 1:Pr.Np
    H = sum(Pr.teta(pp,:).*Pr.FeatRate) +  sum(Pr.q(pp,:).*Pr.CapRate) ;
    Pr.Fare(pp) = 0.5*mean(Pr.F) + (H^(1/3)) * Pr.C(pp,pp+Pr.Np) ; 
    xx = [xx; Pr.Fare(pp) Pr.C(pp,pp+Pr.Np)] ;
end

num2str(xx)
save('Pr','Pr');













 