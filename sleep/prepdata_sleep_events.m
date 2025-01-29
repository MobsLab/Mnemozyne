function prepdata_sleep_events()

expname = {'mfb','pag','nov'};
rip_idx = [1 3 4 5 6];
spi_idx = [1 5 6];


for iexp=1:length(expname)
    load([expname{iexp} '_ripples_data.mat']);
    ripdat{iexp}=ripples_data;
    clear ripples_data;
    load([expname{iexp} '_spindles_data.mat']);
    spidat{iexp}=spindles_data;
    clear spindles_data;
end

for iexp=1:length(expname)
    for istag=1:length(rip_idx)
        rip.amp(iexp,1:length(rip_idx),1:size(ripdat{iexp}.ripdif.amp,2)) = ripdat{iexp}.ripdif.amp(rip_idx,:); 
        rip.freq(iexp,1:length(rip_idx),1:size(ripdat{iexp}.ripdif.freq,2)) = ripdat{iexp}.ripdif.freq(rip_idx,:); 
        rip.dur(iexp,1:length(rip_idx),1:size(ripdat{iexp}.ripdif.dur,2)) = ripdat{iexp}.ripdif.dur(rip_idx,:); 
        rip.globalden(iexp,1:length(rip_idx),1:size(ripdat{iexp}.ripdif.globalden,2)) = ripdat{iexp}.ripdif.globalden(rip_idx,:); 
        rip.localden(iexp,1:length(rip_idx),1:size(ripdat{iexp}.ripdif.localden,2)) = ripdat{iexp}.ripdif.localden(rip_idx,:); 
    end
    for istag=1:length(spi_idx)
        spi.amp(iexp,1:length(spi_idx),1:size(spidat{iexp}.spidif.amp,2)) = spidat{iexp}.spidif.amp(spi_idx,:); 
        spi.freq(iexp,1:length(spi_idx),1:size(spidat{iexp}.spidif.freq,2)) = spidat{iexp}.spidif.freq(spi_idx,:); 
        spi.dur(iexp,1:length(spi_idx),1:size(spidat{iexp}.spidif.dur,2)) = spidat{iexp}.spidif.dur(spi_idx,:); 
        spi.globalden(iexp,1:length(spi_idx),1:size(spidat{iexp}.spidif.globalden,2)) = spidat{iexp}.spidif.globalden(spi_idx,:); 
        spi.localden(iexp,1:length(spi_idx),1:size(spidat{iexp}.spidif.localden,2)) = spidat{iexp}.spidif.localden(spi_idx,:); 
    end
end

clr = {[0 .8 0],[.9 0 0],[1 1 1],[0 0 0]};  %arbitrary order. can change or automate later
ripstag = {'NREM','Wake','N1','N2','N3'};
supertit = 'Change in ripples amplitude Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1100 600],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(rip_idx)
        if istag>1
            pos=istag+1;
        else
            pos=istag;
        end
        subplot(2,3,pos)
            [p,h,her] = PlotErrorBarN_SL(squeeze(rip.amp(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(ripstag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in ripples frequency Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1100 600],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(rip_idx)
        if istag>1
            pos=istag+1;
        else
            pos=istag;
        end
        subplot(2,3,pos)
            [p,h,her] = PlotErrorBarN_SL(squeeze(rip.freq(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(ripstag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in ripples duration Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1100 600],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(rip_idx)
        if istag>1
            pos=istag+1;
        else
            pos=istag;
        end
        subplot(2,3,pos)
            [p,h,her] = PlotErrorBarN_SL(squeeze(rip.dur(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(ripstag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in ripples global density Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1100 600],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(rip_idx)
        if istag>1
            pos=istag+1;
        else
            pos=istag;
        end
        subplot(2,3,pos)
            [p,h,her] = PlotErrorBarN_SL(squeeze(rip.globalden(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(ripstag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in ripples local density Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1100 600],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(rip_idx)
        if istag>1
            pos=istag+1;
        else
            pos=istag;
        end
        subplot(2,3,pos)
            [p,h,her] = PlotErrorBarN_SL(squeeze(rip.localden(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(ripstag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
    
%% Spindles
spistag = {'NREM','N2','N3'};
supertit = 'Change in spindles amplitude Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1000 400],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(spi_idx)
        subplot(1,3,istag)
            [p,h,her] = PlotErrorBarN_SL(squeeze(spi.amp(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(spistag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in spindles frequency Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1000 400],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(spi_idx)
        subplot(1,3,istag)
            [p,h,her] = PlotErrorBarN_SL(squeeze(spi.freq(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(spistag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in spindles duration Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1000 400],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(spi_idx)
        subplot(1,3,istag)
            [p,h,her] = PlotErrorBarN_SL(squeeze(spi.dur(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(spistag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in spindles global density Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1000 400],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(spi_idx)
        subplot(1,3,istag)
            [p,h,her] = PlotErrorBarN_SL(squeeze(spi.globalden(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(spistag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    
supertit = 'Change in spindles local density Post-PreSleep (%)';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1000 400],'Name', supertit, 'NumberTitle','off');
    for istag=1:length(spi_idx)
        subplot(1,3,istag)
            [p,h,her] = PlotErrorBarN_SL(squeeze(spi.localden(:,istag,:))',...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',0);
                h.FaceColor = 'flat';
                h.FaceAlpha = .5;
                for ico=1:length(h.CData)
                    h.CData(ico,:) = clr{ico};
                end
                title(spistag{istag})
                set(gca,'xticklabel',{[]})    
                set(h, 'LineWidth', 1);
                set(her, 'LineWidth', 1);
                ylabel('% change');
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
end