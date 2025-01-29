function figH = FigHeatMaps_global(Occup,varargin)
%
%   INPUT
%       Occup                       occupation by pixel (see fPixelOccup)
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

% calculate occupancy means
x_pre_mean = squeeze(mean(mean(Occup.x(:,1,:),1)));
y_pre_mean = squeeze(mean(mean(Occup.y(:,1,:),1)));
occHS_pre_mean = squeeze(Occup.img_global(1,:,:));
x_post_mean = squeeze(mean(mean(Occup.x(:,2,:),1)));
y_post_mean = squeeze(mean(mean(Occup.y(:,2,:),1)));
occHS_post_mean = squeeze(Occup.img_global(2,:,:));
if cond
    x_cond_mean = squeeze(mean(mean(Occup.x(:,3,:),1)));
    y_cond_mean = squeeze(mean(mean(Occup.y(:,3,:),1)));
    occHS_cond_mean = squeeze(Occup.img_global(3,:,:));
end

figH = figure('Color',[1 1 1], 'render','painters','position',[10 10 1600 375]);
    % occupancy
    subplot(1,3,1)
        imagesc([1:320],[1:240],flip(squeeze(occHS_pre_mean))) 
        caxis([0 .008]) % control color intensity here
        colormap(hot)
        axis off
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        t_str = {'PRE-TESTS'};
        title(t_str, 'FontSize', 14, 'interpreter','latex',...
         'HorizontalAlignment', 'center');
        %add visuals
        rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
        rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone
    if cond
        subplot(1,3,2)
            imagesc([1:320],[1:240],flip(squeeze(occHS_cond_mean))) 
            caxis([0 .008]) % control color intensity here
            colormap(hot)
            axis off
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            t_str = {'COND'};
            title(t_str, 'FontSize', 14, 'interpreter','latex',...
             'HorizontalAlignment', 'center');  
            %add visuals
            rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
            rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone
    end
    subplot(1,3,3)
        imagesc([1:320],[1:240],flip(squeeze(occHS_post_mean))) 
        caxis([0 .008]) % control color intensity here
        colormap(hot)
        axis off
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        t_str = {'POST-TESTS'};
        title(t_str, 'FontSize', 14, 'interpreter','latex',...
         'HorizontalAlignment', 'center'); 
        %add visuals
        rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
        rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone