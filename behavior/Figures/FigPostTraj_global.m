
function figH = FigPostTraj_global(Occup,a,id_Sess,mNum)

%   INPUT
%       Occup                       occupancy by zone (.data)(see fZoneOccup)
%       a                           cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%
%   OUTPUT
%       figH                        figure handle       
%
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

nbpost = length(id_Sess{2,1});
supertit = 'Post-test trajectories per trial';
figH = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2100 600],'Name', supertit, 'NumberTitle','off');
    for itrial=1:length(id_Sess{2,imouse})
        subplot(2,nbpost,itrial) 
            for i=1:length(a)
                if itrial<=nbpost
                    % -- trajectories    
                    p1(i) = plot(Data(a{i}.behavResources(id_Sess{2,i}(itrial)).AlignedXtsd),...
                        Data(a{i}.behavResources(id_Sess{2,i}(itrial)).AlignedYtsd),...
                             'linewidth',1.5);  
                    hold on
                        tempX = Data(a{i}.behavResources(id_Sess{2,i}(itrial)).AlignedXtsd);
                        tempY = Data(a{i}.behavResources(id_Sess{2,i}(itrial)).AlignedYtsd);
                        plot(tempX(a{i}.behavResources(id_Sess{2,i}(itrial)).PosMat(:,4)==1), ...
                            tempY(a{i}.behavResources(id_Sess{2,i}(itrial)).PosMat(:,4)==1),...
                            'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                        clear tempX tempY
                    axis off

                    xlim([-.05 1.05])
                    ylim([-.05 1.05])
                    title(['Trial #' num2str(itrial)])
                    % constructing the u maze
                    f_draw_umaze 
                    if itrial == 1 && i== length(a)
                        axP = get(gca,'Position');
                        mice_str = cellstr(string(mNum)); 
                        lg = legend(p1([1:length(mNum)]),mice_str,'Location','WestOutside');
                        title(lg,'Mice')
                        set(gca, 'Position', axP)
                    end
                end
            end

        subplot(2,nbpost,itrial+nbpost)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(squeeze(squeeze(Occup(:,2,itrial,1:2)))*100,...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'paired',0, 'colorpoints',1);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{'Stim', 'No-stim'});
            xtickangle(45)
            set(gca, 'FontSize', 12);
            set(gca, 'LineWidth', 1.5);
            set(h_occ, 'LineWidth', 1.5);
            set(her_occ, 'LineWidth', 1.5);
            ylabel('% time');
            ylim([0 100])    
            makepretty_erc
    end