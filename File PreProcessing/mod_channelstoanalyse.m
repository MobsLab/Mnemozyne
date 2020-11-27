function mod_channelstoanalyse(varargin)
%==========================================================================
% Details: Modify ExpeInfo and ChannelToAnalyze folder with what is fed as
% varargin
%
% INPUTS: channel name + new channel    # **needs to be completed - some channels are missing**
%       - Bulb_deep
%       - Bulb_sup
%       - dHPC_deep
%       - dHPC_rip
%       - EKG
%       - PFCx_deep
%       - PFCx_sup
%       - PFCx_deltadeep
%       - PFCx_deltasup
%       - PFCx_spindle
%       - Ref
%
%   ex: mod_channeltoanalyse('Bulb_deep',11,'Ref','30')
%
% NOTES:
%       - 
%
%   Written by Samuel Laventure - 2019
%      
%  see also...
%==========================================================================
load('ExpeInfo');

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'bulb_deep'
            Bulb_deep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.Bulb_deep=Bulb_deep;
            load([pwd '/ChannelsToAnalyse/Bulb_deep.mat']);
            channel=Bulb_deep;
            save([pwd '/ChannelsToAnalyse/Bulb_deep.mat'],'channel');
            if ~isnumeric(Bulb_deep) 
                error('Incorrect value for property ''Bulb_deep''.');
            end
        case 'bulb_sup'
            Bulb_sup = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.Bulb_deep=Bulb_sup;
            load([pwd '/ChannelsToAnalyse/Bulb_sup.mat']);
            channel=Bulb_sup;
            save([pwd '/ChannelsToAnalyse/Bulb_sup.mat'],'channel');
            if ~isnumeric(Bulb_sup) 
                error('Incorrect value for property ''Bulb_sup''.');
            end
        case 'dhpc_deep'
            dHPC_deep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.dHPC_deep=dHPC_deep;
            load([pwd '/ChannelsToAnalyse/dHPC_deep.mat']);
            channel=dHPC_deep;
            save([pwd '/ChannelsToAnalyse/dHPC_deep.mat'],'channel');            
            if ~isnumeric(dHPC_deep) 
                error('Incorrect value for property ''dHPC_deep''.');
            end
        case 'dhpc_rip'
            dHPC_rip = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.dHPC_deep=dHPC_rip;
            load([pwd '/ChannelsToAnalyse/dHPC_rip.mat']);
            channel=dHPC_rip;
            save([pwd '/ChannelsToAnalyse/dHPC_rip.mat'],'channel');  
            if ~isnumeric(dHPC_rip) 
                error('Incorrect value for property ''dHPC_rip''.');
            end    
        case 'ekg'
            EKG = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.EKG=EKG;
            load([pwd '/ChannelsToAnalyse/EKG.mat']);
            channel=EKG;
            save([pwd '/ChannelsToAnalyse/EKG.mat'],'channel');  
            if ~isnumeric(EKG) 
                error('Incorrect value for property ''EKG''.');
            end
        case 'pfcx_deep'
            PFCx_deep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_deep=PFCx_deep;
            load([pwd '/ChannelsToAnalyse/PFCx_deep.mat']);
            channel=PFCx_deep;
            save([pwd '/ChannelsToAnalyse/PFCx_deep.mat'],'channel');  
            if ~isnumeric(PFCx_deep) 
                error('Incorrect value for property ''PFCx_deep''.');
            end
        case 'pfcx_deltadeep'
            PFCx_deltadeep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_deltadeep=PFCx_deltadeep;
            load([pwd '/ChannelsToAnalyse/PFCx_deltadeep.mat']);
            channel=PFCx_deltadeep;
            save([pwd '/ChannelsToAnalyse/PFCx_deltadeep.mat'],'channel');
            if ~isnumeric(PFCx_deltadeep) 
                error('Incorrect value for property ''PFCx_deltadeep''.');
            end
         case 'pfcx_deltasup'
            PFCx_deltasup = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_deltasup=PFCx_deltasup;
            load([pwd '/ChannelsToAnalyse/PFCx_deltasup.mat']);
            channel=PFCx_deltasup;
            save([pwd '/ChannelsToAnalyse/PFCx_deltasup.mat'],'channel');
            if ~isnumeric(PFCx_deltasup) 
                error('Incorrect value for property ''PFCx_deltasup''.');
            end
         case 'pfcx_spindle'
            PFCx_spindle = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_spindle=PFCx_spindle;
            load([pwd '/ChannelsToAnalyse/PFCx_spindle.mat']);
            channel=PFCx_spindle;
            save([pwd '/ChannelsToAnalyse/PFCx_spindle.mat'],'channel');
            if ~isnumeric(PFCx_spindle) 
                error('Incorrect value for property ''PFCx_spindle''.');
            end   
         case 'ref'
            Ref = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.Ref=Ref;
            load([pwd '/ChannelsToAnalyse/Ref.mat']);
            channel=Ref;
            save([pwd '/ChannelsToAnalyse/Ref.mat'],'channel');
            if ~isnumeric(Ref) 
                error('Incorrect value for property ''Ref''.');
            end   
         otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
    save('ExpeInfo.mat','ExpeInfo')
end




end