%% housekeeping
clc;
clear all;
close all;

%% Constant variables
%Declaration of constant variabls of interest when it comes to evaluating
%anthropogenic signals as signals of opportunity for passive radar sounding
%of glaciers. 
disp("Hello! Hope your day is well, enjoy the plethora of autocorrelation plots. ")

Rt = 100:100:5000; % 30 km distance is average
Rt2 = 2500:50:4500;
thickness = 400; %thickness of glacier 400 m
tower_height = 500; %assume tower is 100 m above the glacier. 
tower_height2 = [50, 100, 200, 500, 1000]; %different tower heights to compare resolution
ref_ind = 1.78; %refractive index of ice
k = 1.38*10^-23;

Fs = 6*10^6; % 6 MHz sampling rate of theoretical SDR
BW = Fs;
fc = 0; %placeholder for the frequencies I will input into OFDM generator
%function so I can simulate the different signals of opportunity. 
fc_dvb = [174; 180; 186; 192; 198; 204; 210; 216; 222; 228] .* 10^6; 
%different center frequencies for the III band for dvb-t signals
fc_dvb_uhf = (470:6:890)'.*10^6; %uhf for dvb-t
fc_5g_lowband = (600:6:900)'.*10^6; %low band for LTE, especially 5G
fc_5g_midband = (1700:60:4700)'.*10^6;% mid band for LTE especially 5G


for i = 1:length(fc_dvb_uhf)
    videofile=VideoWriter(['Vid 2 OFDM, fc = ', num2str(fc_dvb_uhf(i))], 'MPEG-4');
    videofile.FrameRate = round(1/.1);
    %videofile.Quality = 100;
    open(videofile)
    [ofdm_signal1(:,i)] = ofdmgen1(fc_dvb_uhf(i),BW);

    for j = 1:length(Rt)
        %[ofdm_signal2] = ofdmgen2(fc,BW);
    
        [auto_corr(:,j), tau(j), SNR_avg(j), time(j,:)] = PRS(ofdm_signal1(:,i), Rt(j), ref_ind, thickness, Fs, fc_dvb_uhf(i,1), tower_height);
    
        figure(j)
        hold on
        title("OFDM signal varying Rt, Fc = ", strcat(num2str(fc_dvb_uhf(i))), 'FontSize', 17);
        a = plot(time(j,:)'.*10^6, 10*log10(abs(auto_corr(:,j)./max(abs(auto_corr(:,j))))), 'b', 'LineWidth', 1.5);
        b = xline(tau(j)*10^6,'r--', 'LineWidth',0.3);
        %yline(-5,'color', 'cyan','LineWidth', 0.25);
        %yline(-10, 'color', 'magenta', 'LineWidth', 0.25);
        xlim([0,55])
        %xticks(linspace(0,55,23));
        ylim([-45,0]);
        xlabel("Time[μs]", 'FontSize', 15)
        ylabel("dB", 'FontSize', 15)
        c = plot(0,0);
        legend("Autocorrelation", "Expected delay", strcat("Rt =", num2str(Rt(j)) ), 'FontSize', 15);
        hold off
    
        %saveas(figure(i), strcat("OFDM, Rt", num2str(Rt(i)), ".jpg"));
        drawnow
        writeVideo(videofile,getframe(gcf))
        delete(a);
        delete(b);
    end
hold off
close(videofile)
end
