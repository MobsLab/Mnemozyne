function figH = FigSpeedDir(sd,a,id_Sess,mNum,varargin)
%
%   INPUT
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

% Default values
cond=1;
warning('off','all')

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
    % set labels
    lbls = {'t1','t2','t3','t4','t5','t6','t7','t8'};

    for it=1:nbprepost(i)
        probelbls{1,it}=lbls{1,it};
    end
    for it=1:nbcond{i}
        condlbls{1,it}=lbls{1,it};
    end

    supertit = ['Mouse ' num2str(mNum(i))  ' - Direction and Speed'];
    figH{i} = figure('Color',[1 1 1], 'rend','painters', ...
            'pos',[1 1 1400 800],'Name', supertit, 'NumberTitle','off');
        % Trajectories
        subplot(2,3,1) 
            for k=1:length(id_Sess{1,i})  
                for idir=1:3
                    for iseg=1:size(sd{i}.xdir{1,k},2)
                        sd{i}.xdir{1,k}{idir,iseg}(isnan(sd{i}.xdir{1,k}{idir,iseg})) = 0;
                        if sd{i}.xdir{1,k}{idir,iseg}
                            x=sd{i}.xdir{1,k}{idir,iseg}';
                            y=sd{i}.ydir{1,k}{idir,iseg}';
                            z=zeros(size(x));
                            s=sd{i}.vdir{1,k}{idir,iseg}';
                            surface([x;x], [y;y], [z;z], [s;s],...
                                'FaceColor', 'no',...
                                'EdgeColor', 'interp',...
                                'LineWidth', .5);
                            hold on
                        end
                    end
                end
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title('Pre-tests')
            colormap('jet')
            caxis([-15 15])
            % constructing the u maze
            f_draw_umaze
            makepretty_erc
            %legend
            axP = get(gca,'Position');
            hcb = colorbar('Location','westoutside');
            ylabel(hcb,'(cm/s)')
            set(gca, 'Position', axP)

        subplot(2,3,2) 
             for k=1:length(id_Sess{3,i})  
                for idir=1:3
                    for iseg=1:size(sd{i}.xdir{2,k},2)
                        sd{i}.xdir{2,k}{idir,iseg}(isnan(sd{i}.xdir{2,k}{idir,iseg})) = 0;
                        if sd{i}.xdir{2,k}{idir,iseg}
                            x=sd{i}.xdir{2,k}{idir,iseg}';
                            y=sd{i}.ydir{2,k}{idir,iseg}';
                            z=zeros(size(x));
                            s=sd{i}.vdir{2,k}{idir,iseg}';
                            surface([x;x], [y;y], [z;z], [s;s],...
                                'FaceColor', 'no',...
                                'EdgeColor', 'interp',...
                                'LineWidth', .5);
                            hold on
                        end
                    end
                end
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title('Cond')
            colormap('jet')
            caxis([-15 15])
            % constructing the u maze
            f_draw_umaze
            makepretty_erc

        subplot(2,3,3) 
             for k=1:length(id_Sess{2,i})   
                for idir=1:3
                    for iseg=1:size(sd{i}.xdir{3,k},2)
                        sd{i}.xdir{3,k}{idir,iseg}(isnan(sd{i}.xdir{3,k}{idir,iseg})) = 0;
                        if sd{i}.xdir{3,k}{idir,iseg}
                            x=sd{i}.xdir{3,k}{idir,iseg}';
                            y=sd{i}.ydir{3,k}{idir,iseg}';
                            z=zeros(size(x));
                            s=sd{i}.vdir{3,k}{idir,iseg}';
                            surface([x;x], [y;y], [z;z], [s;s],...
                                'FaceColor', 'no',...
                                'EdgeColor', 'interp',...
                                'LineWidth', .5);
                            hold on
                        end
                    end
                end
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title('Post-tests')
            colormap('jet')
            caxis([-15 15])
            % constructing the u maze
            f_draw_umaze
            makepretty_erc

        % Barplots
        ymax = squeeze(max(max(max(sd{i}.speed(:,:,:)))))*1.1;
        subplot(2,3,4)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(squeeze(sd{i}.speed(1,1:length(id_Sess{1,i}),1:2)),...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorpoints',1);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{'Toward', 'Away'});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            ylabel('Speed cm/s');
            ylim([0 ymax]);
            makepretty_erc
            %legend (hidden plot)
        %                 axP = get(gca,'Position');
        %                 legend(probelbls,'Location','westoutside')
        %                 set(gca, 'Position', axP)  

        if cond
            subplot(2,3,5)
                [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(squeeze(sd{i}.speed(2,1:length(id_Sess{3,i}),1:2)),...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorpoints',1);
                h_occ.FaceColor = 'flat';
                h_occ.CData(2,:) = [1 1 1];
                set(gca,'Xtick',[1:2],'XtickLabel',{'Toward', 'Away'});
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                ylim([0 ymax]);
            makepretty_erc
        end

        subplot(2,3,6)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(squeeze(sd{i}.speed(3,1:length(id_Sess{2,i}),1:2)),...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorpoints',1);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{'Toward', 'Away'});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            ylim([0 ymax]);
            makepretty_erc
end
end