function Occup = fPixelOccup(beh,id_Sess,varargin)
%
%   INPUT
%       beh                         cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%
%   OPTIONAL (VARARGIN)
%       cond                        conditionning session (1/0)
%                                   default -> 1 
%
%   OUTPUT
%      [Occup - Structure]
%       Occup.img                   flipped (y,x) image of occupancyfor
%                                   each trial
%       Occup.x                     x for plotting imagesc
%       Occup.y                     y for plotting imagesc
%       Occup.img_sessavg           averaged image per mouse/session
%       Occup.img_global            averaged image per session
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

% Default values
cond=1;

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

for imouse=1:length(beh)
    for isess=1:3
        if ~(~cond && isess>2)
            for itrial=1:length(id_Sess{isess,imouse})
                [img, x, y] = ...
                    CalculatePixelOccupancy(beh{imouse}.behavResources(id_Sess{isess,imouse}(itrial))); 
                Occup.img(imouse,isess,itrial,1:size(img,1),1:size(img,2)) = img;
                Occup.x(imouse,isess,itrial) = x;
                Occup.y(imouse,isess,itrial) = y;
                clear img x y
            end
            % Keep one averaged map for each session per mouse
            Occup.img_sessavg(imouse,isess,1:size(Occup.img,1),1:size(Occup.img,2)) = ...
                squeeze(mean(Occup.img(imouse,isess,:,:,:)));
        end
    end
end
% create global map per session
for isess=1:3
    if ~(~cond && isess>2)
        Occup.img_global(isess,1:size(Occup.img,1),1:size(Occup.img,2)) = ...
            sum(cat(3,Occup.img_sessavg(:,isess,:,:)),3); 
    end    
end