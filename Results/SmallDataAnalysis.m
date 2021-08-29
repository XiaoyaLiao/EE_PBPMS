%1.No	2.nJ	3.nM	4.nF	5.alpha	6.betha	7.STR	8.landa	9.Obj	10.TWT	11.TEC	12.Obj	13.TWT	14.TEC
Results = [
1	9	2	2	0.1	5	10	0.3	0.869400703	12	499.4345816	0.869400703	12	499.4345816
2	9	2	2	0.1	5	10	0.5	0.759783713	52	533.7518473	0.759783713	52	533.7518473
3	9	2	2	0.1	5	10	0.7	0.35599418	2	489.2690627	0.35599418	2	489.2690627
4	9	2	2	0.1	5	30	0.3	1.028339056	32	727.2506996	1.028339056	32	727.2506996
5	9	2	2	0.1	5	30	0.5	0.750241507	15	584.2346319	0.758873849	0	622.2138477
6	9	2	2	0.1	5	30	0.7	0.299733436	0	584.0140238	0.301786356	0	588.0140238
7	9	2	2	0.3	3	10	0.3	1.056906612	0	755.9955769	0.967748365	46	651.9863954
8	9	2	2	0.3	3	10	0.5	0.591539299	7.333333333	562.3128007	0.591539299	7.333333333	562.3128007
9	9	2	2	0.3	3	10	0.7	0.426655158	0	533.2552904	0.426655158	0	533.2552904
10	9	2	2	0.3	3	30	0.3	0.922179297	21	555.5840329	0.926185553	21	558.2506996
11	9	2	2	0.3	3	30	0.5	0.597912303	35	615.7518473	0.630564255	35	652.0184888
12	9	2	2	0.3	3	30	0.7	0.377908762	0.333333333	803.9829104	0.378836415	0.333333333	805.9829104
13	15	2	2	0.1	5	10	0.3	1.045354485	60.66666667	769.9058894	Inf	260.6666667	552.4506493
14	15	2	2	0.1	5	10	0.5	0.961753548	163.6666667	565.8208345	0.947392249	84.66666667	652.0276703
15	15	2	2	0.1	5	10	0.7	0.38347493	0	618.4966827	0.382486813	5.666666667	591.1748263
16	15	2	2	0.1	5	30	0.3	0.880409809	48	616.0276703	0.886436679	30	627.3610037
17	15	2	2	0.1	5	30	0.5	0.765201472	134	572.3863786	0.810927523	167.3333333	582.8173914
18	15	2	2	0.1	5	30	0.7	0.345077461	0	631.9863535	0.346711762	0	634.9794673
19	15	2	2	0.3	3	10	0.3	0.969325527	849	489.4897965	0.995179677	995.3333333	488.3311637
20	15	2	2	0.3	3	10	0.5	0.665011718	90.66666667	656.5784202	0.65460078	92.66666667	642.5772726
21	15	2	2	0.3	3	10	0.7	0.312780142	18	553.9685643	0.315831431	18	560.2185643
22	15	2	2	0.3	3	30	0.3	0.923680693	809.6666667	431.8621514	0.931455891	655	467.7610288
23	15	2	2	0.3	3	30	0.5	0.767779896	326.3333333	868.4945131	0.764711399	269.6666667	890.3335848
24	15	2	2	0.3	3	30	0.7	0.417552013	10.33333333	1080.01177	0.417552013	10.33333333	1080.01177
25	20	2	2	0.1	5	10	0.3	0.903174759	297	468.1035122	0.9171661	159.3333333	495.0000943
26	20	2	2	0.1	5	10	0.5	0.757787404	32.66666667	753.2415495	0.730145043	17.66666667	774.8622457
27	20	2	2	0.1	5	10	0.7	0.460876347	0	1203.922209	0.448546245	0	1171.712952
28	20	2	2	0.1	5	30	0.3	1.056035457	273	648.8208345	0.998228621	140	664.8139483
29	20	2	2	0.1	5	30	0.5	0.734146355	50.66666667	633.8966135	0.734146355	50.66666667	633.8966135
30	20	2	2	0.1	5	30	0.7	0.446935344	35.66666667	918.2346319	0.446935344	35.66666667	918.2346319
31	20	2	2	0.3	3	10	0.3	1.12443691	980	646.5346194	1.13609769	1088	642.5346194
32	20	2	2	0.3	3	10	0.5	0.974605173	284.3333333	936.1795428	1.027495604	303	982.8485048
33	20	2	2	0.3	3	10	0.7	0.458775857	45.33333333	1129.142691	0.359336302	20	943.6187152
34	20	2	2	0.3	3	30	0.3	0.770384548	157.6666667	684.5564884	0.77470911	139.3333333	705.5564884
35	20	2	2	0.3	3	30	0.5	0.825152502	272.6666667	1138.581905	0.862036185	217.3333333	1289.489922
36	20	2	2	0.3	3	30	0.7	0.421585198	38	1149.579568	0.420577927	38	1146.496808
];

% Results(97:144,12:14) = aa ;


TS_is_Better = (Results(:,9)<=Results(:,12));
TWT_is_Better = (Results(:,10)<=Results(:,13));
TEC_is_Better = (Results(:,11)<=Results(:,14));
TS_diff = (Results(:,9) - Results(:,12));
TWT_diff = (Results(:,10) - Results(:,13));
TEC_diff = (Results(:,11) - Results(:,14));

%1.No	2.nJ	3.nM	4.nF   5.alpha	6.betha	7.STR	8.landa	9.Obj	10.TWT	11.TEC	12.Obj	13.TWT	14.TEC

nJ = [9 15 20]; % 50 100 200
nM = [ 2 ]; % 3 5
% alpha = [0.1 0.3 0.5]; % 0.1 0.3 0.5
% betha = [3 5]; % 3 5
% STR = [10 30]; % 10 30
% landa = [0.3 0.5 0.7]; % 0.3 0.5 0.7



CompleteReport = [];

for nJ = [9 15 20]; 
for nM = [ 2 ];
for alpha = [0.1 0.3] % 0.1 0.3 0.5
for betha = [3 5] % 3 5
    
    if alpha == 0.1 && betha == 3
%         continue
    end
for STR = [ 10 30 ] % 10 30
for landa = [0.3 0.5 0.7] % 0.3 0.5 0.7

    
rJ = [];
for ii = 1:size(Results,1)
    if any(nJ == Results(ii,2))
        rJ = [rJ Results(ii,1)];
    end
end

rM = []; 
for ii = rJ
    if any(Results(ii,3)==nM) 
        rM = [rM Results(ii,1)];
    end
end

ra = [];
for ii = rM
    if any(Results(ii,5)==alpha) 
        ra = [ra Results(ii,1)];
    end
end

rb = [] ;
for ii = ra
    if any(Results(ii,6)==betha)
        rb = [rb Results(ii,1)];
    end
end

rSTR = [];
for ii = rb
    if any(Results(ii,7)==STR)
        rSTR = [rSTR Results(ii,1)];
    end
end

rlanda = [];
for ii = rSTR
    if any(Results(ii,8)==landa)
        rlanda = [rlanda Results(ii,1)];
    end
end



SelectedRows = rlanda'; 
SelectedSummary = [Results(SelectedRows,1:9) TS_is_Better(SelectedRows)];


Report = zeros(1,3);
% Report: {TS(ObjDomPercent, TWTDom, TECDom), TSp(ObjDomPercent, TWTDom, TECDom) }


H = Results(SelectedRows,9) <= Results(SelectedRows,12);
DominantRow = Results(SelectedRows(H),1) ;
if ~isempty(DominantRow)
Report(1) = round(100*numel(DominantRow)/numel(SelectedRows));
Report(2) = 100*mean((Results(DominantRow,12) - Results(DominantRow,9))./Results(DominantRow,9));

end
Report(3) = numel(SelectedRows);
if ~isempty(SelectedRows)
    H =[alpha betha STR landa Report]; % alpha betha STR landa Report
    CompleteReport =[CompleteReport; H];
end

end
end
end
end
end
end
% [~,Order] = sort(CompleteReport(:,5),'descend');
% CompleteReport = CompleteReport(Order,:);

disp(num2str(CompleteReport))
num2str(mean(CompleteReport(:,end-2)))




