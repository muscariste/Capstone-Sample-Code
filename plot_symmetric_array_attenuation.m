function plot_symmetric_array_attenuation(numels, elemSpacing, frequency,...
                    direction, arrayPos, w, l, resolution,...
                    ignore_minusXdb, level_to_ignore, plotTitle)
%% Plot single symmetric array attenuation pattern
% numels - number of elements in mic array
% elemSpacing - spacing of elements in mic array
% frequency - frequency for the attenuation pattern
% direction - pointing direction of array
% arrayPos - position of center of mic array
% w - room width
% l - room length
% resolution - if you increase this, the simulation takes longer
% ignore_minusXdb - (bool) ignore attenuation below...
% level_to_ignore - the level of attenuation below which to ignore
% plotTitle - (string) title for the plot

%% Prep input for phased array toolbox funcitons
c = 343; % Speed of sound in m/s
freqs = [frequency,20e3]; % frequency to look at, freqs(2) is vestigal

%% Build mic array
% create an omnidirectional microphone object
hmic = phased.OmnidirectionalMicrophoneElement('FrequencyRange', freqs);

% create uniform linear array object
ha = phased.ULA('NumElements',numels,'ElementSpacing',elemSpacing,...
                'Element',hmic);

% create steering vector object for linear array
hsv = phased.SteeringVector('SensorArray', ha, 'PropagationSpeed', c);

%% Create mesh grid for the room, place arrays
xRes = w * resolution;
yRes = l * resolution;

x = linspace(-w/2,w/2,xRes);
y = linspace(-l/2,l/2,yRes);

[X,Y] = meshgrid(x,y);

%% make pages of r and theta for the room
% as of right now no r dependence, but we could throw some in
r = sqrt((X - arrayPos(1)).^2 + (Y - arrayPos(2)).^2);
theta = -atand((Y - arrayPos(2))./(X - arrayPos(1)));

% sv is a vector of complex weights calculated similarly to eqn 66
% in the mic array tutorial (except MATLAB uses sin instead of cos)
sv = step(hsv, min(freqs), direction);
    
% get polar responses
foo = plotResponse(ha,min(freqs),c,'RespCut','Az','Weights',sv,...
             'AzimuthAngles',-180:180);
    
% get data from polar responses
phi = foo.XData;
resp = foo.YData;
    
% get attenuation for theta sheets
R = interp1(phi,resp,theta);

% plot
imagesc(flipud(R));
set(gca,'XTick',[],'YTick',[]);
xlabel(sprintf('%.1f m',w)); ylabel(sprintf('%.1f m',l));
pbaspect([w l 1]);

% ignore regions attenuated to below -3dB if true
if ignore_minusXdb
    m = max(max(R));
    caxis([m-level_to_ignore m]);
end

title(plotTitle);

end