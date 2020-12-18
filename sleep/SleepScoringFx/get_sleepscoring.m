
function [rem, nrem, wake] = get_sleepscoring(isubj, sscoring, tdat)
    rem = and(sscoring.REMEpoch, tdat{isubj}{1});
    nrem = and(sscoring.SWSEpoch, tdat{isubj}{1});
    wake = and(sscoring.Wake, tdat{isubj}{1});
end