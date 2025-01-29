function figH = FigLatencyToZone(FirstTime,a,id_Sess,mNum)
%
%   INPUT
%       FirstTime                   latency to enter the zone
%       a                           cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%       mNum                        mice id #
%                                   format -> [mouse1,mouse2,mouse#] in
%                                   integer 
%
%   OUTPUT
%       figH                        figure handle                                   
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 21/05/2021
% github.com/samlaventure

% Optional Parameters
for i=1:2:length(varargin)    
    switch(lower(varargin{i})) 
        case 'cond'
            cond = varargin{i+1};
            if ~(cond==1) && ~(cond==0)
                error('Incorrect value for property ''cond'' (must be 0 or 1');
            end
    end
end

for i=1:length(a)    
    % xlabels
    lbls = {'t1','t2','t3','t4','t5','t6','t7','t8'};
    for it=1:nbprepost(i)
        probelbls{1,it}=lbls{1,it};
    end     
    probedur = floor(a{i}.behavResources(id_Sess{1,i}(1)).PosMat(end,1)- ...
        a{i}.behavResources(id_Sess{1,i}(1)).PosMat(1,1));
    nbprepost = length(id_Sess{1,i});
    
    % figure
    supertit = ['Mouse ' num2str(mNum(i))  ' - Latency to first entry'];
    figH{i} = figure('Color',[1 1 1], 'rend','painters', ...
        'pos',[10 10 1300 600],'Name', supertit, 'NumberTitle','off');
        pre_max=squeeze(FirstTime(:,1,1:nbprepost,1));
        post_max=squeeze(FirstTime(:,2,1:nbprepost,1));
        max_y = max(max([post_max post_max]));
        max_y=max_y*1.15; 
        %pre
        subplot(1,2,1)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(FirstTime(i,1,1:nbprepost,1),...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showPoints',0);
                ylim([0 max_y])
                set(gca,'Xtick',[1:nbprepost],'XtickLabel',probelbls);                  
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                ylabel('time (s)');
                hline(probedur,'--k','Max duration')
                title('Pre-Tests latency')
            makepretty_erc    
        %post        
        subplot(1,2,2)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(FirstTime(i,2,1:nbprepost,1),...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showPoints',0);
                ylim([0 max_y])
                set(gca,'Xtick',[1:nbprepost],'XtickLabel',probelbls);  
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                ylabel('time (s)');
                hline(probedur,'--k','Max duration')
                title('Post-Tests latency')
            makepretty_erc 
        % Supertitle
        mtit(['M' num2str(mNum(i))], 'fontsize',14, ...
            'xoff', -.6, 'yoff', 0,'color',	[0, 0.4470, 0.7410]);           
end