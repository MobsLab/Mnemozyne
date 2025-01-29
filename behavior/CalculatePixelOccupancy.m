function [occHS, xx, yy] = CalculatePixelOccupancy(behavResources_slice,varargin)

%   INPUT
%       behavResources_slice        one session structure of concatenated 
%                                   behavioral data
%   OUTPUT
%       nn                          Occupancy by pixel (smoothed hist bin count)
%       xx                          xx a row vector for plotting using
%                                   imagesc(xx,yy,nn)
%       yy                          yy a row vector for plotting using
%                                   imagesc(xx,yy,nn)
%
%   OPTIONAL (VARARGIN)
%       sizexy                      size of image on axis x and y
%                                   format  -> [xxx yyy]
%                                   default -> [240 320] 
%
%   See: PrgMatlab/CodesMATLAB/WagenaarMBL/hist2.m
%   Note: if problem with hist2 it is because of eeglab hist2 function
%         place it in an another path temprorarly or reload PrgMatlab path)
%
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

% Default values
sizexy = [240 320];
freqVideo=15;           % frame rate
smo=2;                  % smoothing factor

% Optional Parameters
for i=1:2:length(varargin)    
    switch(lower(varargin{i})) 
        case 'sizexy'
            sizexy = varargin{i+1};
            if ~isnum(sizexy) || ~(length(sizexy)==2)
                error('Incorrect value for property ''sizexy'' (must be numericala and composed of 2 number (x and y)).');
            end
    end
end

% get x and y data
x = behavResources_slice.AlignedXtsd;
y = behavResources_slice.AlignedYtsd;

[occH, xx, yy] = hist2(x,y, sizexy(1), sizexy(2));
occHS(1:sizexy(2),sizexy(1)) = SmoothDec(occH/freqVideo,[smo,smo]); 
end