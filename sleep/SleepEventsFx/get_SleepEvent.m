function [evt, evtmean] = get_SleepEvent(dirPath,evtType,sEpoch,subst)

%==========================================================================
% Details: get sleep stages epochs for SleepEvents analyses
%
% INPUTS:
%       - Vtsd              Vtsd from behavResources (speed in tsd format)
%
% OUTPUT:
%       - sEpoch            Epoch (timestamps) for each sleep/wake stages
%       - subst             Substages done (yes=1; no=0)
%
% NOTES:
%
%   Written by Samuel Laventure - 2020-11/12
%      
%==========================================================================
for isuj=1:length(dirPath)
    switch evtType 
        case 'Ripples'
            load([dirPath{isuj}{1} evtType '.mat'], evtType,[evtType 'Epoch'],'T');
        case 'Spindles'
            load([dirPath{isuj}{1} evtType '.mat'], evtType,[evtType 'Epoch_PFCx'],'T');
    end
    for isess=1:2
        istage = 1;
        for ist=1:7
            %skip rem sleep in second position (no rip or spindles in rem)
            if ist==2
                ist=ist+1;
            else
                if ~(subst(isuj)) && istage>3 % special case: skip if no substage
                    evtmean.amp(isess,3:5,isuj) = nan;
                    evtmean.freq(isess,3:5,isuj) = nan;
                    evtmean.dur(isess,3:5,isuj) = nan;
                    evtmean.waveforms(isess,3:5,isuj,1:size(T,2)) = nan;
                    evtmean.globalden(isess,3:5,isuj) = nan;
                    evtmean.localden(isess,3:5,isuj) = nan;
                    ist=7; istage=6;
                end
                evt.epoch{isuj,isess,istage} = and(RipplesEpoch,sEpoch{isuj}{isess,istage});
                % identify event indexes
                idx = find(ismember(Start(RipplesEpoch),Start(evt.epoch{isuj,isess,istage})));
                ripstart = Start(and(evt.epoch{isuj,isess,istage},sEpoch{isuj}{isess,istage}));

                evt.amp{isuj,isess,istage} = Ripples(idx,6);
                evt.freq{isuj,isess,istage} = Ripples(idx,5); 
                evt.dur{isuj,isess,istage} = Ripples(idx,4); 
                evt.waveforms{isuj,isess,istage} = T(idx,1:size(T,2));

                % calculate densities
                numss = length(idx);       
                sesslen = sum(Stop(sEpoch{isuj}{isess,istage},'s')-Start(sEpoch{isuj}{isess,istage},'s'));
                if numss
                    % global density
                    evt.globalden{isuj,isess,istage} = numss/sesslen;
                    % local density
                    for ievt=1:length(ripstart)
                        evt.localden{isuj,isess,istage}(ievt) = length(find(ripstart<ripstart(ievt)+30*1E4 & ripstart>ripstart(ievt)-30*1E4));
                    end
                else
                    evt.globalden{isuj,isess,istage} = nan;
                    evt.localden{isuj,isess,istage} = nan;
                end


                evtmean.amp(isess,istage,isuj) = mean(evt.amp{isuj,isess,istage});
                evtmean.freq(isess,istage,isuj) = mean(evt.freq{isuj,isess,istage});
                evtmean.dur(isess,istage,isuj) = mean(evt.dur{isuj,isess,istage});
                if ~isempty(evt.waveforms{isuj,isess,istage})
                    evtmean.waveforms(isess,istage,isuj,1:size(T,2)) ...
                        = mean(evt.waveforms{isuj,isess,istage});
                end
                evtmean.globalden(isess,istage,isuj) = evt.globalden{isuj,isess,istage}; 
                evtmean.localden(isess,istage,isuj) = mean(evt.localden{isuj,isess,istage}); 
                istage = istage+1;
            end
        end
    end
end
evt.params.orderName = {'mouse','session (pre/post)','sleep stage'};
evtmean.params.orderName = {'session (pre/post)','sleep stage','mouse','data'};
end