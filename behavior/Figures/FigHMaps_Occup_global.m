function figH = FigHMaps_Occup_global(OccupPixel,Occup)
%
%   INPUT
%       Occup                       occupation by pixel (see fPixelOccup)
%
%
%   OUTPUT
%       figH                        figure handle                                   
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 21/05/2021
% github.com/samlaventure

% calculate occupancy means
occHS_pre_mean = squeeze(OccupPixel.img_global(1,:,:));
occHS_post_mean = squeeze(OccupPixel.img_global(2,:,:));
if cond
    occHS_cond_mean = squeeze(OccupPixel.img_global(3,:,:));
end

figH = figure('Color',[1 1 1], 'render','painters','position',[10 10 1900 375]);
    % occupancy
    subplot(1,4,1)
        imagesc([1:320],[1:240],flip(squeeze(occHS_pre_mean))) 
        caxis([0 .04]) % control color intensity here
        colormap(hot)
        axis off
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        t_str = {'Pre-tests'};
        title(t_str, 'FontSize', 14);
        %add visuals
        rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
        rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone
    subplot(1,4,2)
            imagesc([1:320],[1:240],flip(squeeze(occHS_cond_mean))) 
            caxis([0 .04]) % control color intensity here
            colormap(hot)
            axis off
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            t_str = {'Cond'};
            title(t_str, 'FontSize',14);  
            %add visuals
            rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
            rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone

    subplot(1,4,3)
        imagesc([1:320],[1:240],flip(squeeze(occHS_post_mean))) 
        caxis([0 .04]) % control color intensity here
        colormap(hot)
        axis off
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        t_str = {'Post-tests'};
        title(t_str, 'FontSize',14); 
        %add visuals
        rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
        rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone

    voidtmp = nan(length(Dir.path),1);    
    subplot(1,4,4)
        [~,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Occup(:,1,1))*100  squeeze(Occup(:,3,1))*100 squeeze(Occup(:,2,1))*100],...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
        set(gca,'Xtick',[1:3],'XtickLabel',{'Pre','Cond','Post',});
        set(gca, 'FontSize', 12);
        set(gca, 'LineWidth', 1);
        set(h_occ, 'LineWidth', 1);
        set(her_occ, 'LineWidth', 1);
        ylabel('% time');
        ylim([0 85])
        t_str = {'Time spent in stim zone by session'};
        title(t_str, 'FontSize', 14);   
     makepretty_erc