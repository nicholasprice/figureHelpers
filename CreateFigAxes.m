function [AxHand, FigHand] = CreateFigAxes(FigDim, varargin) %Left, Bot, Wi, Hi)
%CREATEFIGAXES creates a new figure with specified axes
%[AxHand, FigHand] = CreateFigAxes(FigDim, varargin);
% there are scaling constants (ScrWid / ScrRes) below that can be customised to a specific
% monitor, so that the size on your screen matches the size of the figure
% when printed on paper
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
% NicP Long ago

%scaling for screen size (to be customised to your monitor)
ScrWid = 29.5; %cm
ScrRes = 1920; %pixels
PixWid = ScrWid/ScrRes; %width of a pixel in cm

FigHand = figure;
set(FigHand,'PaperPosition',[1 5 FigDim]); %position of figure on printed A4 paper
set(FigHand,'Position',[40 40 1*FigDim/PixWid]); %ensures that pixels map directly to cm (with known scaling factor)
%could also get pixelwidth and then scale according to that, so figure size
%on screen matches paper size
set(FigHand,'defaultaxesfontsize',8)
set(FigHand,'defaulttextfontsize',8)
set(FigHand,'color','w');


if length(varargin)>1,
    Left = varargin{1};     Bot = varargin{2};     Wi = varargin{3};     Hi = varargin{4};

    %parse subplot sizes - make them all the same length
    nPlot = max([length(Left), length(Bot), length(Wi), length(Hi)]);
    if length(Left)<nPlot, Left = [Left Left(end)*ones(1,nPlot-length(Left))]; end
    if length(Bot)<nPlot, Bot = [Bot Bot(end)*ones(1,nPlot-length(Bot))]; end
    if length(Wi)<nPlot, Wi = [Wi Wi(end)*ones(1,nPlot-length(Wi))]; end
    if length(Hi)<nPlot, Hi = [Hi Hi(end)*ones(1,nPlot-length(Hi))]; end
else
    xy = varargin{1};
    nPlot = prod(xy);
    if length(xy)==1, % just specified total number of subplots
%         xy = [ceil(sqrt(nPlot)) ceil(sqrt(nPlot))]; % floor(sqrt(nPlot))];        % make things as square as possible
        xy = [ceil(sqrt(nPlot)) ceil(nPlot/ceil(sqrt(nPlot)))];
    end
    LeftMin = 0.04; % leftmost allowed position
    BotMin = 0.05; %lowest allowed position
    WiScale = 0.85; %proportion of horizontal graph to empty space
    HiScale = 0.85;
    Wi = ones(1,nPlot)*WiScale*(1-LeftMin)/xy(1);
    Hi = ones(1,nPlot)*HiScale*(1-BotMin)/xy(2);
    LeftGap = (1-LeftMin)/xy(1);
    Left = (modPos(1:nPlot,xy(1))-1)*LeftGap + LeftMin;
    BotGap = (1-BotMin)/xy(2);
    Bot = floor((prod(xy)-(1:nPlot))/xy(1))*BotGap + BotMin;  
end

%make the subplots
for a = 1:nPlot,
    AxHand(a) = axes('position',[Left(a) Bot(a) Wi(a) Hi(a)]);
end
set(AxHand,'nextplot','add'); %effectively hold on
