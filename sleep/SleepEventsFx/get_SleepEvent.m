function [evt, evtmean, evtdif] = get_SleepEvent(dirPath,evtType,sEpoch,subst)

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
        case 'ripples'
            nameFile = 'Ripples';
            load([dirPath{isuj}{1} nameFile '.mat'], evtType,[nameFile 'Epoch'],'T');
            evtEpoch = RipplesEpoch;
            evtData = ripples;
        case 'Spindles'
            load([dirPath{isuj}{1} evtType '.mat'], evtType,[evtType 'Epoch_PFCx'],'T');
            evtEpoch = SpindlesEpoch_PFCx;
            evtData = Spindles;
    end
    for isess=1:2
        istage = 0;
        for ist=1:7
            %skip rem sleep in second position (no rip or spindles in rem)
            if ist==2
                ist=ist+1;
            else
                istage = istage+1;
                if ~(subst(isuj)) && istage>3 % special case: skip if no substage
                    evtmean.amp(isess,3:5,isuj) = nan;
                    evtmean.freq(isess,3:5,isuj) = nan;
                    evtmean.dur(isess,3:5,isuj) = nan;
                    evtmean.waveforms(isess,3:5,isuj,1:size(T,2)) = nan;
                    evtmean.globalden(isess,3:5,isuj) = nan;
                    evtmean.localden(isess,3:5,isuj) = nan;
                    ist=7; istage=7;
                end
                evt.epoch{isuj,isess,istage} = and(evtEpoch,sEpoch{isuj}{isess,istage});
                % identify event indexes
                idx = find(ismember(Start(evtEpoch),Start(evt.epoch{isuj,isess,istage})));
                evtstart = Start(and(evt.epoch{isuj,isess,istage},sEpoch{isuj}{isess,istage}));

                evt.amp{isuj,isess,istage} = evtData(idx,6);
                evt.freq{isuj,isess,istage} = evtData(idx,5); 
                evt.dur{isuj,isess,istage} = evtData(idx,4); 
                evt.waveforms{isuj,isess,istage} = T(idx,1:size(T,2));

                % calculate densities
                numss = length(idx);       
                sesslen = sum(Stop(sEpoch{isuj}{isess,istage},'s')-Start(sEpoch{isuj}{isess,istage},'s'));
                if numss
                    % global density
                    evt.globalden{isuj,isess,istage} = numss/sesslen;
                    % local density
                    for ievt=1:length(evtstart)
                        evt.localden{isuj,isess,istage}(ievt) = length(find(evtstart<evtstart(ievt)+30*1E4 & evtstart>evtstart(ievt)-30*1E4));
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
            end
        end
    end
    
    %calculate diff
    for ist=1:size(evt.amp,3)
        evtdif.amp(ist,isuj) = ((evtmean.amp(2,ist,isuj)-evtmean.amp(1,ist,isuj))/evtmean.amp(1,ist,isuj))*100;
        evtdif.freq(ist,isuj) = ((evtmean.freq(2,ist,isuj)-evtmean.freq(1,ist,isuj))/evtmean.freq(1,ist,isuj))*100;
        evtdif.dur(ist,isuj) = ((evtmean.dur(2,ist,isuj)-evtmean.dur(1,ist,isuj))/evtmean.dur(1,ist,isuj))*100;
        evtdif.globalden(ist,isuj) = ((evtmean.globalden(2,ist,isuj)-evtmean.globalden(1,ist,isuj))/evtmean.globalden(1,ist,isuj))*100;
        evtdif.localden(ist,isuj) = ((evtmean.localden(2,ist,isuj)-evtmean.localden(1,ist,isuj))/evtmean.localden(1,ist,isuj))*100;
    end
end
evt.params.orderName = {'mouse','session (pre/post)','sleep stage'};
evtmean.params.orderName = {'session (pre/post)','sleep stage','mouse','data'};
evtdif.params.orderName = {'sleep stage','data per mouse'};
end