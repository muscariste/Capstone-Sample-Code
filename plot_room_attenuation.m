function plot_room_attenuation(numels, elemSpacing, frequency, directions,...
                    w, l, arrayPos, resolution,...
                    ignore_minusXdb, level_to_ignore, plot_one_array, plotTitle)
%% What's going on here...
% This function plots the 2 (or 1) mic-array attenuation patterns for a
% single frequency in a room with specified dimensions

% numels - number of elements in mic array
% elemSpacing - spacing of elements in mic array
% directions - row vector [left pointing direction, right  pointing direction]
%              (in degrees)
% w - room width
% l - room length
% arrayPos - position of array in room measured from the "Chuck" side
% resolution - if you increase this, the simulation takes longer
% ignore_minusXdb - (bool) ignore attenuation below...
% level_to_ignore - the level of attenuation below which to ignore
% plot_one_array - (bool) plot just the left array
% plotTitle - (string) title for the plot

%% Prep input for phased array toolbox funcitons
c = 343; % Speed of sound in m/s
freqs = [frequency,20e3]; % frequency to look at, freqs(2) is vestigal
dir_l = [directions(1);0];
dir_r = [directions(2);0];

%% Build mic array
% create an omnidirectional microphone object
hmic = phased.OmnidirectionalMicrophoneElement('FrequencyRange', freqs);

% create uniform linear array object
ha = phased.ULA('NumElements',numels,'ElementSpacing',elemSpacing,...
                'Element',hmic);

% create steering vector object for linear array
hsv = phased.SteeringVector('SensorArray', ha, 'PropagationSpeed', c);

%% Create mesh grid for the room, place arrays
xRes = 8.5 * resolution;
yRes = 11 * resolution;

x = linspace(-w/2,w/2,xRes);
y = linspace(-l/2,l/2,yRes);

[X,Y] = meshgrid(x,y);

d = ha.getElementPosition;
elYpos = d(2,:) + arrayPos; % y positions of array elements

% no mics outside the room
if (max(elYpos) > l/2) || (min(elYpos) < -l/2)
    display('You dun goofed')
end

%% make pages of r and theta for the room
% as of right now no r dependence, but we could throw some in
pos_l = [-w/2 elYpos]; % left mic xy coordinates
r1 = sqrt((X - pos_l(1)).^2 + (Y - pos_l(2)).^2);
theta1 = -atand((Y - pos_l(2))./(X - pos_l(1)));

pos_r = [w/2 elYpos]; % right mic xy coordinates
r2 = sqrt((X - pos_r(1)).^2 + (Y - pos_r(2)).^2);
theta2 = atand((Y - pos_r(2))./(X - pos_r(1)));

% sv is a vector of complex weights calculated similarly to eqn 66
% in the mic array tutorial (except MATLAB uses sin instead of cos)
sv_l = step(hsv, min(freqs), dir_l);
sv_r = step(hsv, min(freqs), dir_r);
    
% get polar responses
foo_l = plotResponse(ha,min(freqs),c,'RespCut','Az','Weights',sv_l,...
             'AzimuthAngles',-180:180);
    
% get data from polar responses
phi_l = foo_l.XData;
%resp_l = -foo_l.YData.^2; % square resp to fold attenuation
resp_l = foo_l.YData;
    
% get attenuation for theta sheets
R_l = interp1(phi_l,resp_l,theta1);

% ditto for the right array
foo_r = plotResponse(ha,min(freqs),c,'RespCut','Az','Weights',sv_r,...
             'AzimuthAngles',-180:180);
phi_r = foo_r.XData;
%resp_r = -foo_r.YData.^2;
resp_r = foo_r.YData;
R_r = interp1(phi_r,resp_r,theta2);
    
% add and normalize responses
if plot_one_array
    Rtot = R_l;
else
    Rtot = -(R_l .* R_r);
end

% plot
imagesc(Rtot);
set(gca,'XTick',[],'YTick',[]);
xlabel(sprintf('%.1f m',w)); ylabel(sprintf('%.1f m',l));
pbaspect([w l 1]);

% ignore regions attenuated to below -3dB if true
if ignore_minusXdb
    m = max(max(Rtot));
    caxis([m-level_to_ignore m]);
end

title(plotTitle);

end