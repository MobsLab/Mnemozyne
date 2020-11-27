function [latencies, NotFound, NotFound_idx] = GetLatencyThreshold(rawchan, StimEpoch, ThresholdUsed, varargin)

%% Default param
Isplot = false;

%% Optional arguments

for i=1:2:length(varargin) 
    switch(lower(varargin{i}))    
        case 'plot'
            Isplot = varargin{i+1};
            if Isplot ~= 1 && Isplot ~= 0
                error('Incorrect value for property ''Plot'' (type ''help GetLatencyThreshold'' for details).');
            end
    end
end

%% Main
ISTemp = intervalSet(Start(StimEpoch)-100,Start(StimEpoch));
NotFound = 0;
latencies = nan(1,length(Start(StimEpoch)));
NotFound_idx = zeros(1,length(Start(StimEpoch)));
NegPeak = zeros(1,length(Start(StimEpoch)));

if Isplot
    PlotAllStims(rawchan, StimEpoch, ThresholdUsed, ISTemp)
end
    
for i=1:length(Start(StimEpoch))
    OneStimSig = Restrict(rawchan,subset(ISTemp,i));
    
    Crossed = thresholdIntervals(OneStimSig,ThresholdUsed/0.195+1,'Direction','Below');
    if ~isempty(Start(Crossed))
        [NegPeak(i), time_id] = FindLatencyThreshold(Crossed, OneStimSig);
        
        t = Range(OneStimSig);
        latencies(i) = (End(subset(ISTemp,i)) - t(time_id))/10;
    else
        NotFound = NotFound+1;
        NotFound_idx(i) = i;
    end
end
NotFound_idx = nonzeros(NotFound_idx);

end



%% Auxiliary
function [NegPeak, time_id] = FindLatencyThreshold(CrossedEpoch, OneStimSig)

NegPeak_temp = zeros(length(Start(CrossedEpoch)), 1);
idxL = zeros(length(Start(CrossedEpoch)), 1);

for j=1:length(Start(CrossedEpoch))
    try
        NegPeak_temp(j) = min(Data(Restrict(PerTemp,subset(CrossedEpoch,j))));
    catch
        datatemp = Data(OneStimSig); % sometimes the very last point crosses threshold - than Restrict doesn't work
        timetemp = Range(OneStimSig);
        NegPeak_temp(j) = datatemp(timetemp == Start(subset(CrossedEpoch,j)));
        clear datatemp timetemp
    end
    temp_id = find(Data(OneStimSig)==NegPeak_temp(j));
    idxL(j) = max(temp_id);
end

if length(Start(CrossedEpoch)) > 1
    [time_id,ii] = max(idxL);
    NegPeak = NegPeak_temp(ii);
else
    NegPeak = NegPeak_temp;
    time_id = idxL;
end

end


function PlotAllStims(rawchan, StimEpoch, ThresholdUsed, ISTemp)

fff = figure('units', 'normalized', 'outerposition', [0.1 0.6 0.6 0.5]);
title('Stimulations');
tabs = arrayfun(@(x) uitab('Title', ['Stim' num2str(x)]), 1:length(Start(StimEpoch)));
ax = arrayfun(@(tab) axes(tab), tabs);
arrayfun(@(k) title(ax(k), ['Stim' num2str(k)], 'FontSize', 16), 1:length(Start(StimEpoch)));
arrayfun(@(k) set(ax(k), 'NextPlot','add', 'FontSize', 16, 'FontWeight', 'bold'), 1:length(Start(StimEpoch)));


arrayfun(@(k) plot(ax(k), Range(Restrict(rawchan,subset(ISTemp,k)), 's'),...
    Data(Restrict(rawchan,subset(ISTemp,k))), 'k', 'LineWidth', 2), 1:length(Start(StimEpoch)));
arrayfun(@(k) ylabel(ax(k), 'Amplitude (a.u.)'), 1:length(Start(StimEpoch)));
arrayfun(@(k) xlabel(ax(k), 'Time'), 1:length(Start(StimEpoch)));

for i = 1:length(Start(StimEpoch))
    axes(ax(i));
    line(xlim, [ThresholdUsed/0.195 ThresholdUsed/0.195], 'Color', 'r', 'LineWidth',3);
end

for i = 1:length(Start(StimEpoch))
    axes(ax(i));
    line([Start(subset(StimEpoch,i),'s') Start(subset(StimEpoch,i),'s')], ylim, 'Color', 'b', 'LineWidth',3);
end

end