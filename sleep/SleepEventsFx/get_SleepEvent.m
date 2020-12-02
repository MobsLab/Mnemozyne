function [evt evtmean] = get_SleepEvent(dirPath,evtType,sEpoch,subst)

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
    for istage=1:7
        for isess=1:2
            if ~(subst(isuj)) && istage>3 % special case: skip if no substage
                evtmean.amp(isess,4:6,isuj) = nan;
                evtmean.freq(isess,4:6,isuj) = nan;
                evtmean.dur(isess,4:6,isuj) = nan;
                evtmean.waveforms(isess,4:6,isuj,1:size(T,2)) = nan;
                evtmean.globalden(isess,4:6,isuj) = nan;
                evtmean.localden(isess,4:6,isuj) = nan;
                istage=7;
            end
            evt.epoch{isuj,isess,istage} = and(RipplesEpoch,sEpoch{isess,istage});
            % identify event indexes
            idx = find(ismember(Start(RipplesEpoch),Start(evt.epoch{isuj,isess,istage})));
            ripstart = Start(and(evt.epoch{isuj,isess,istage},sEpoch{isess,istage}));

            evt.amp{isuj,isess,istage} = Ripples(idx,6);
            evt.freq{isuj,isess,istage} = Ripples(idx,5); 
            evt.dur{isuj,isess,istage} = Ripples(idx,4); 
            evt.waveforms{isuj,isess,istage} = T(idx,1:size(T,2));

            % calculate densities
            numss = length(idx);       
            sesslen = sum(Stop(sEpoch{isess,istage},'s')-Start(sEpoch{isess,istage},'s'));
            % global density
            evt.globalden{isuj,isess,istage} = numss/sesslen;
            % local density
            for ievt=1:length(ripstart)
                numev(ievt) = length(find(ripstart<ripstart(ievt)+30*1E4 & ripstart>ripstart(ievt)-30*1E4));
            end
            evt.localden{isuj,isess,istage} = mean(numev);

            evtmean.amp(isess,istage,isuj) = mean(evt.amp{isuj,isess,istage});
            evtmean.freq(isess,istage,isuj) = mean(evt.freq{isuj,isess,istage});
            evtmean.dur(isess,istage,isuj) = mean(evt.dur{isuj,isess,istage});
            if ~isempty(evt.waveforms{isuj,isess,istage})
                evtmean.waveforms(isess,istage,isuj,1:size(T,2)) ...
                    = mean(evt.waveforms{isuj,isess,istage});
            end
            evtmean.globalden(isess,istage,isuj) = mean(evt.globalden{isuj,isess,istage});
            evtmean.localden(isess,istage,isuj) = mean(evt.localden{isuj,isess,istage});
        end
    end
end
evt.params.orderName = {'mouse','session (pre/post)','sleep stage'};
evtmean.params.orderName = {'session (pre/post)','sleep stage','mouse','data'};
end