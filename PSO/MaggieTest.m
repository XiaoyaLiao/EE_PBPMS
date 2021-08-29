S = 91 ;
a = 0.8*0.2 ;
b = 0.4*0.8 ;
c = 0.2*1.5 ;
Profit = 0 ;
for T1 = 0:1
    for T2 = 0:1
        for T3 = 0:1
Gain = [] ;          
 for s1 = 0:1:91 
     for s2 = 0:1:91-s1
          s3 = 91-s1-s2 ;
            P = [] ; 
            for rr = 1:30
                xx = 0 ;
                for tt = 50
                a = (rand<0.8)*.02 * (rand<1-0.5*T1) ;
                b = (rand<0.4)*.08 * (rand<1-0.5*T2) ;
                c = (rand<0.2)*.15 * (rand<1-0.5*T3) ;
%                 s1 = randi([0 91],1,1) ;
%                 s2 = randi([0 91-s1],1,1) ;
%                 s3 = randi([0 91-s1-s2],1,1) ;
                xx = [xx a*s1+b*s2+c*s3] ;
                end
                P = [P mean(xx)] ; 
            end
            Gain = [Gain; s1 s2 s3 mean(P)] ;
         
     end
     
 end
[Bst, ind] = max(Gain(:,end)) ;
Profit = Profit + Gain(ind,end) ;
disp([T1 T2 T3 ])
disp(Gain(ind,:))
disp('----------')

        end
    end
end
Profit

