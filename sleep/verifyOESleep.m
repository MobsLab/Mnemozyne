function fgh = verifyOESleep()
load('Sleep_Scorer-103.0_TEXT_group_1.mat','text');
txt = text;

ss(1) = 0;
ss(2) = 0;
ss(3) = 0;

for i=1:size(txt,1)
    switch txt(i,1:4)
        case 'NREM'
            ss(1)=ss(1)+1;
        case 'REM '
            ss(2)=ss(2)+1;
        case 'Wake'
            ss(3)=ss(3)+1;
    end
end
fgh = figure; 
bar(ss)
xticklabels({'NREM','REM','Wake'})
title('Sleep scoring ratio')
ylabel('Seconds')
end