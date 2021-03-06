%% Schelter 2006 5-dimensional VAR[4]
%
% An example taken from Schelter et al. (2006) 
%
%
% ==========================================================================
%      Schelter, Winterhalder, Hellwig, Guschlbauer, L?cking, Timmer
%       Direct or indirect? Graphical models for neural oscillators
%               J Physiology - Paris 99:37-46, 2006.
%         http://dx.doi.org/10.1016/j.jphysparis.2005.06.006
%
%      Example 5-dimensional VAR[4]
% ==========================================================================

%% 

%% Generate data sample from fschelter2006 function
%

clc; clear; format compact; format short

flgRepeat = 0; % You may want to repeat simulation using the same data set 
               % with different analysis parameters. If this is the case, 
               % run schelter2006.m with flgRepeat = 0, then set it to 1,
               % and you will be able to play with the same dataset using
               % different analysis and plotting parameters. 
               % When flgRepeat == 0, the state number is saved in
               % schelter2006_state.mat file, so that randn can be
               % initialized with the same state number in subsequent
               % simulations.

nDiscard = 5000;   % number of points discarded at beginning of simulation
nPoints  = 5000;   % number of analyzed samples points

[u aState] = fschelter2006(nPoints, nDiscard, flgRepeat);

if ~flgRepeat, save schelter2006_state.mat aState; end;

%chLabels = {'x_1';'x_2';'x_3';'x_4';'x_5'}; %or 
chLabels = [];

fs = 1;

%%
% Data pre-processing: detrending and normalization options
flgDetrend = 1;     % Detrending the data set
flgStandardize = 0; % No standardization

[nChannels,nSegLength]=size(u);
if nChannels > nSegLength, u=u.'; 
   [nChannels,nSegLength]=size(u);
end;

if flgDetrend,
   for i=1:nChannels, u(i,:)=detrend(u(i,:)); end;
   disp('Time series were detrended.');
end;

if flgStandardize,
   for i=1:nChannels, u(i,:)=u(i,:)/std(u(i,:)); end;
   disp('Time series were scale-standardized.');
end;

%%
% MVAR model estimation

maxIP = 30;         % maximum model order to consider.
alg = 1;            % 1: Nutall-Strand MVAR estimation algorithm;
%                   % 2: minimum least squares methods;
%                   % 3: Vieira Morf algorithm;
%                   % 4: QR ARfit algorith.

criterion = 1;      % Criterion for order choice:
%                   % 1: AIC, Akaike Information Criteria; 
%                   % 2: Hanna-Quinn;
%                   % 3: Schwarz;
%                   % 4: FPE;
%                   % 5: fixed order given by maxIP value.

disp('Running MVAR estimation routine...')

[IP,pf,A,pb,B,ef,eb,vaic,Vaicv] = mvar(u,maxIP,alg,criterion);

disp(['Number of channels = ' int2str(nChannels) ' with ' ...
    int2str(nSegLength) ' data points; MAR model order = ' int2str(IP) '.']);

%==========================================================================
%    Testing for adequacy of MAR model fitting through Portmanteau test
%==========================================================================
h = 20; % testing lag
MVARadequacy_signif = 0.05; % VAR model estimation adequacy significance
                            % level
aValueMVAR = 1 - MVARadequacy_signif;
flgPrintResults = 1;
[Pass,Portmanteau,st,ths] = mvarresidue(ef,nSegLength,IP,aValueMVAR,h,...
                                           flgPrintResults);

%%
% Granger causality test (GCT) and instantaneous GCT

gct_signif  = 0.01;  % Granger causality test significance level
igct_signif = 0.01;  % Instantaneous GCT significance level
flgPrintResults = 1; % Flag to control printing gct_alg.m results on command window.
[Tr_gct, pValue_gct, Tr_igct, pValue_igct] = gct_alg(u,A,pf,gct_signif, ...
                                              igct_signif,flgPrintResults);
 
%% Original PDC estimation
%
% PDC analysis results are saved in *c* structure.
% See asymp_dtf.m or issue 
%
%   >> help asymp_pdc 
%
% command for more detail.

nFreqs = 128;
metric = 'info';  % euc  = original PDC or DTF;
                 % diag = generalized PDC (gPDC) or DC;
                 % info = information PDC (iPDC) or iDTF.
alpha = 0.01;

c=asymp_pdc(u,A,pf,nFreqs,metric,alpha);

%%
% PDCn Matrix Layout Plotting

flgPrinting = [1 1 1 1 1 0 2]; % overriding default setting
flgColor = 0;
w_max=fs/2;
alphastr = int2str(100*alpha);
   
for kflgColor = flgColor,
   h=figure;
   set(h,'NumberTitle','off','MenuBar','none', ...
      'Name', 'Schelter et al. J Physiology - Paris 99:37-46, 2006.')

   [hxlabel hylabel] = xplot(c,...
      flgPrinting,fs,w_max,chLabels,kflgColor);
   [ax,hT]=suplabel(['Linear pentavariate Model II: ' ...
      int2str(nPoints) ' data points.'],'t');
   set(hT,'FontSize',12); % Title font size
   xplot_title(alpha,metric);
end;

%% Result from Schelter et al.(2006) 
% Figure 3, page 41.
%
% <<fig_schelter2006_result.png>>
% 

%%
% Figure shows the results from Schelter et al. (2006) that is in agreement
% with the present simulation.



%% Some remarks
%
% * Compare this plot with Fig.3, page 41,in Schelter et al. (2006),
%   depicting PDC''s amplitude plots, while this example plots squared
%   PDC.
%
% * Note that, for linear model, the mean amplitude of PDC estimates
%   is roughly proportional to relative coefficient values of
%   the autoregressive model.
%