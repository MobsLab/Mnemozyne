function figH = FigSpeedDir_global(dirspeed,varargin)
%
%   INPUT
%       dirspeed                    grouped mean (session average) speed by direction (toward, away)
%
%   OPTIONAL (VARARGIN)
%       cond                        conditionning session (1/0)
%                                   default -> 1 
%
%   OUTPUT
%       figH                        figure handle                                   
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 21/05/2021
% github.com/samlaventure

if cond 
    dspeed = [squeeze(dirspeed(:,1,:)) nan(length(a),1) squeeze(dirspeed(:,2,:)) ...
        nan(length(a),1) squeeze(dirspeed(:,3,:))];
else
    dspeed = [squeeze(dirspeed(:,1,:)) nan(length(a),1) squeeze(dirspeed(:,3,:))];
end
    
ymax = max(max(dspeed))*1.2;

supertit = ['Global speed by direction'];
figH.globalspeed = figure('Color',[1 1 1], 'rend','painters', ...
    'pos',[1 1 800 500],'Name', supertit, 'NumberTitle','off');

    [p,h,her] = PlotErrorBarN_SL(dspeed,...
        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);

        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0]; h.CData(2,:) = [1 1 1];
        h.CData(4,:) = [0 0 0]; h.CData(5,:) = [1 1 1];
        if cond
            h.CData(7,:) = [0 0 0]; h.CData(8,:) = [1 1 1];
            set(gca,'xticklabel',{'','           Pre','','','            Cond','','','            Post',''})    
        else
            set(gca,'xticklabel',{'','           Pre','','','            Post',''})    
        end
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel({'Speed','cm/s'});
        ylim([0 ymax])
        % creating legend with hidden-fake data (hugly but effective)
                b2=bar([-2],[ 1],'FaceColor','flat');
                b1=bar([-3],[ 1],'FaceColor','flat');
                b1.CData(1,:) = repmat([0 0 0],1);
                b2.CData(1,:) = repmat([1 1 1],1);
                legend([b1 b2],{'Toward SZ','Away from SZ'},'Location','NorthEast')
        makepretty_erc 