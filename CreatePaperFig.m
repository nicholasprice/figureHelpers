function [AxHand, figHand] = CreatePaperFig(figDim, varargin)
% CREATEPAPERFIG creates a figure and axes with specified dimensions
% [AxHand, figHand] = CreatePaperFig(FigDim, varargin);
% Optional input argument allows scaling of figure so that the size on your screen matches the size of the printed figure
%
% Two modes of operation:
% (1) specify left,bottom,width,height of each axes
% (2) specify number of subplots and they will be automagically created
%
% INPUTS
% FigDim = dimensions of figure (in cm)
% varargin depends on mode of operation
% (1) 4 inputs specifying Left, Bot, Wi, Hi values between 0 and 1
%     note that you can just specify a single value for Wi and Hi and it
%     will be applied to all values
% (2) scalar specifying total number of subplots OR a 2 element [x y]
%       vector specifying number of subplots down and across
%
% OUTPUTS
% handle to figure and handles to axes
%
% USAGE
% CreateFigAxes([15 10],10); % make a 15x10cm figure with 10 panels
% CreateFigAxes([20 10],[0.1 0.55],[0.1],0.4,0.8);
%
% NicP 6Mar2024, based on CreateFigAxes

p = inputParser;
p.addRequired('figDim', @isnumeric);
p.addParameter('nAx',0, @isnumeric); % number of axes, specified as 1 element (total number of axes) or 2 element (row/columns)
p.addParameter('axDim', []); %, @isstruct);
p.addParameter('axDimUnits', 'normalized', @ischar); % 'normalized' or 'centimeters' / 'cm'
p.addParameter('fontAxes', 8, @isnumeric);
p.addParameter('fontText', 12, @isnumeric);
p.addParameter('scrWiCm', 52.2, @isnumeric); % screen width in cm. We leave this here because some systems have scaling factors which are hard to determine programmatically within Matlab.
% p.addOptional('whichMonitor',1, @isnumeric); % which monitor to use

p.parse(figDim, varargin{:});
param = p.Results;

%scaling for screen size (to be customised to your monitor)
tmp = get(0, 'ScreenSize'); % need to check that this works with multi-monitor
scrWiPix = tmp(3);
scrScale = scrWiPix/param.scrWiCm; % width of a pixel in cm

figHand = figure;
set(figHand,'PaperUnits','centimeters','PaperType','A4','PaperPosition',[1 5 figDim]); %position of figure on printed A4 paper
set(figHand,'Position',[40 40 1*figDim*scrScale]); %ensures that pixels map directly to cm (with known scaling factor)
% set(figHand,'defaultaxesfontsize',param.fontAxes);
set(figHand,'defaulttextfontsize',param.fontText);
set(figHand,'color','w');

if isfield(param.axDim,'Left') % specified axes positions
    Left = param.axDim.Left;     Bot = param.axDim.Bot;     
    Wi = param.axDim.Wi;     Hi = param.axDim.Hi;

    %parse subplot sizes - make them all the same length
    nPlot = max([length(Left), length(Bot), length(Wi), length(Hi)]);
    if length(Left)<nPlot, Left = [Left Left(end)*ones(1,nPlot-length(Left))]; end
    if length(Bot)<nPlot, Bot = [Bot Bot(end)*ones(1,nPlot-length(Bot))]; end
    if length(Wi)<nPlot, Wi = [Wi Wi(end)*ones(1,nPlot-length(Wi))]; end
    if length(Hi)<nPlot, Hi = [Hi Hi(end)*ones(1,nPlot-length(Hi))]; end
else
    if length(param.nAx)==1, % just specified total number of subplots
        nXY = [ceil(sqrt(param.nAx)) ceil(param.nAx/ceil(sqrt(param.nAx)))];
        nPlot = param.nAx;
    else
        nXY = param.nAx;
        nPlot = prod(nXY);
    end
    
    % nPlot = prod();
    % if length(xy)==1, % just specified total number of subplots
%         xy = [ceil(sqrt(nPlot)) ceil(sqrt(nPlot))]; % floor(sqrt(nPlot))];        % make things as square as possible
        % xy = [ceil(sqrt(nPlot)) ceil(nPlot/ceil(sqrt(nPlot)))];
    % end
    LeftMin = 0.04; % leftmost allowed position
    BotMin = 0.05; %lowest allowed position
    WiScale = 0.85; %proportion of horizontal graph to empty space
    HiScale = 0.85;
    Wi = ones(1,nPlot)*WiScale*(1-LeftMin)/nXY(1);
    Hi = ones(1,nPlot)*HiScale*(1-BotMin)/nXY(2);
    LeftGap = (1-LeftMin)/nXY(1);
    Left = (modPos(1:nPlot,nXY(1))-1)*LeftGap + LeftMin;
    BotGap = (1-BotMin)/nXY(2);
    Bot = floor((prod(nXY)-(1:nPlot))/nXY(1))*BotGap + BotMin;  
end

%make the subplots
for a = 1:nPlot
    AxHand(a) = axes('Units',param.axDimUnits, 'position',[Left(a) Bot(a) Wi(a) Hi(a)],'FontSize',param.fontAxes);
end
set(AxHand,'nextplot','add'); %effectively hold on



function out = modPos(x,y)
out = mod(x,y);
out(out==0) = y;
