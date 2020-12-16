
function makepretty_erc(varargin)
%==========================================================================
% Details: standardize axis/subplot/plot appearence
%
% INPUTS:
%       - fsize             Font size for X and Y labels (default is 17)
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
        case 'fsize'
            fsize =  varargin{i+1};
            if ~isnumeric(fsize)
				error('Incorrect value for property ''fsize''');
            end
		case 'lwidth'
			lwidth = varargin{i+1};
			if ~isnumeric(lwidth)
				error('Incorrect value for property ''lwidth'' (type ''help <a href="matlab:help FindSpindlesSB">FindSpindlesSB</a>'' for details).');
            end
    end    
end
%Default values 
if ~exist('fsize','var')
    fsize = 17;
end
if ~exist('lwidth','var')
    lwidth = 2;
end

% set some graphical attributes of the current axis
set(get(gca, 'XLabel'), 'FontSize', fsize);
set(get(gca, 'YLabel'), 'FontSize', fsize);
set(gca, 'FontSize', 13);
box off
set(gca,'Linewidth',1.6)
set(get(gca, 'Title'), 'FontSize', 16);

ch = get(gca, 'Children');

for c = 1:length(ch)
    thisChild = ch(c);
    if strcmp('line', get(thisChild, 'Type'))
        if strcmp('.', get(thisChild, 'Marker'))
            % if get(thisChild, 'MarkerSize')<15
            %             set(thisChild, 'MarkerSize', 15);
            % end
        end
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
