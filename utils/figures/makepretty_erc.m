
function makepretty_erc(varargin)
%==========================================================================
% Details: standardize axis/subplot/plot appearence
%
% INPUTS:
%       - fsize             Font size for X and Y labels (default is 17)
%       - fsizet            font size for title (default is 16)
%       - lwidth            Line width (default is 2)
%
% NOTES:
%   From S. Bagur
%   Adapted by D. Bryzgalov & S. Laventure 2020-12
%      
%==========================================================================
% Parse parameter list
for i = 1:2:length(varargin)
	if ~ischar(varargin{i})
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help malepretty_erc">makepretty_erc</a>'' for details).']);
	end
	switch(lower(varargin{i}))
        case 'fsizel'
            fsizel =  varargin{i+1};
            if ~isnumeric(fsizel)
				error('Incorrect value for property ''fsizel''');
            end
         case 'fsizet'
			fsizet = varargin{i+1};
			if ~isnumeric(fsizet)
				error('Incorrect value for property ''fsizet'' (type ''help <a href="matlab:help FindSpindlesSB">FindSpindlesSB</a>'' for details).');
            end  
		case 'lwidth'
			lwidth = varargin{i+1};
			if ~isnumeric(lwidth)
				error('Incorrect value for property ''lwidth'' (type ''help <a href="matlab:help FindSpindlesSB">FindSpindlesSB</a>'' for details).');
            end  
    end    
end
%Default values 
if ~exist('fsizel','var')
    fsizel = 17;
end
if ~exist('fsizet','var')
    fsizet = 16;
end
if ~exist('lwidth','var')
    lwidth = 2;
end

% set some graphical attributes of the current axis
set(get(gca, 'XLabel'), 'FontSize', fsizel);
set(get(gca, 'YLabel'), 'FontSize', fsizel);
set(gca, 'FontSize', 13);
box off
set(gca,'Linewidth',lwidth)
set(get(gca, 'Title'), 'FontSize', fsizet);

ch = get(gca, 'Children');

for c = 1:length(ch)
    thisChild = ch(c);
    if strcmp('line', get(thisChild, 'Type'))
        if strcmp('-', get(thisChild, 'LineStyle'))
            set(thisChild, 'LineWidth', lwidth);
        end
    elseif strcmp('stair', get(thisChild, 'Type'))
                    set(thisChild, 'LineWidth', lwidth);
    elseif strcmp('errorbar', get(thisChild, 'Type'))
                    set(thisChild, 'LineWidth', lwidth);
    end
end

end
