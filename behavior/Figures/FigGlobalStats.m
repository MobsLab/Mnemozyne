function figH = FigGlobalStats(Occup,NumEntries,FirstTime,VZmean,varargin)
%
%   INPUT
%       Occup                       averaged by session, occupation by zone
%       NumEntries                  averaged by session, number of entries
%                                   in stim zone
%       FirsTime                    averaged by session, latency to stim
%                                   zone entry
%       VZmean                      averaged by session, speed in stim zone
%
%   Note: all format must be (imouse, isess) - only Occup has also izone
%
%   OUTPUT
%       figH                        figure handle                                   
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 21/05/2021
% github.com/samlaventure


figH.globalstats = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
    Occupancy_Axes = axes('position', [0.07 0.55 0.41 0.41]);
    NumEntr_Axes = axes('position', [0.55 0.55 0.41 0.41]);
    First_Axes = axes('position', [0.07 0.05 0.41 0.41]);
    Speed_Axes = axes('position', [0.55 0.05 0.41 0.41]);

    % Occupancy
    axes(Occupancy_Axes);
        [~,h_occ, her_occ] = PlotErrorBarN_SL([squeeze(Occup(:,1,1))*100 squeeze(Occup(:,2,1))*100],...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
        h_occ.FaceColor = 'flat';
        h_occ.CData(2,:) = [1 1 1];
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 12);
        set(gca, 'LineWidth', 1);
        set(h_occ, 'LineWidth', 1);
        set(her_occ, 'LineWidth', 1);
        line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
        text(2.3,23.2,'Random Occupancy','FontSize',8);
        ylabel('% time');
        title('Occupancy in rewarded zone', 'FontSize', 14);
        ylim([0 max(max([squeeze(Occup(:,1,1))*100 squeeze(Occup(:,2,1))*100]))*1.2])
        makepretty_erc

    axes(NumEntr_Axes);
        % set y max
        ymax = max(max(NumEntries))+(max(max(NumEntries))*.15);
        [~,h_nent, her_nent] = PlotErrorBarN_SL(NumEntries,...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
        h_nent.FaceColor = 'flat';
        h_nent.CData(2,:) = [1 1 1];
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 12);
        set(gca, 'LineWidth', 1);
        set(h_nent, 'LineWidth', 1);
        set(her_nent, 'LineWidth', 1);
        ylabel('Number of entries');
        title('Nbr of entries to the rewarded zone', 'FontSize', 14);
        ylim([0 ymax])
        makepretty_erc

    axes(First_Axes);
        [~,h_first, her_first] = PlotErrorBarN_SL(FirstTime,...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
        h_first.FaceColor = 'flat';
        h_first.CData(2,:) = [1 1 1];
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 12);
        set(gca, 'LineWidth', 1);
        set(h_first, 'LineWidth', 1);
        set(her_first, 'LineWidth', 1);
        ylabel('Time (s)');
        title('First time to enter the reward zone', 'FontSize', 14);
        ylim([0 max(max([FirstTime]))*1.2])
        makepretty_erc

    axes(Speed_Axes);
        [~,h_speed, her_speed] = PlotErrorBarN_SL([VZmean],...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
        h_speed.FaceColor = 'flat';
        h_speed.CData(2,:) = [1 1 1];
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 12);
        set(gca, 'LineWidth', 1);
        set(h_speed, 'LineWidth', 1);
        set(her_speed, 'LineWidth', 1);
        ylabel('Speed (cm/s)');
        title('Average speed in the reward zone', 'FontSize', 14);
        ylim([0 max(max(VZmean))*1.2])
        makepretty_erc