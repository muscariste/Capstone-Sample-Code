% plot room attenuation for frequencies
%% Array parameters
numels = 3;
elemSpacing = 0.17;

l_dir = 45;
r_dir = 45;

%% Plot parameters
freqs = [600 1000 1600]; % room atten. patterns for freqs1
saturate_dB = 12; % saturate at X dBs of attenuation

%% Room dimensions
room_width = 12;
room_length = 10;
arrayPos = 4;

%% Guts
c = 343;
n = 1;
figure(1315)

for freq = freqs;
    subplot(1,length(freqs),n)
    m = freq*elemSpacing / c;
    plotTitle = sprintf('d/\\lambda = %.1f, \n \\theta_l = %d %c, \\theta_r = %d %c',...
        m, l_dir, char(176), r_dir, char(176));
    plot_room_attenuation(numels,elemSpacing,freq,[l_dir,r_dir],room_width,...
        room_length,arrayPos, 100,...
        true, saturate_dB, false, plotTitle);
    n = n+1;
end