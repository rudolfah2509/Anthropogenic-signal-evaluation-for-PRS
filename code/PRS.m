function [auto_corr, tau, SNR_avg, time] = PRS(wavedata, Rt, ref_ind, thickness, Fs, fc, tower_height)

    %This function takes in the local geometry of the potential passive
    %radar location and the signal structure of the illuminator of
    %opportunity. 
    %Based on this it calculates the expected time delay between the direct
    %path signal and the reflected path and constructs new signal data
    %based on this. This signal data will include both the direct path and
    %reflected path and will be similar to what would be recorded in the
    %field. 
    %Then an autocorrelation is performed. Other outputs of the function
    %can be ignored as they are used to better understand the data. 

    % All the inputs to the function:

    %wavedata = unmodulated data of RF signal.
    %Rt = distance from transmitter to target
    %Rr = distance from target to receiver
    %L = distance between transmitter and receiver
    %beta = bistatic angle
    %ref_ind = refractive index. For ice = 1.31, 1.78
    %thickness = thickness of glacier
    %Fs = sample frequency

    %calculating the expected delay time based on transmitter distance, ice
    %thickness, and snell's law. 
    c = 299792458; % speed of light in a vaccuum. Approximated as same for air
    v = c/ref_ind; % calculating speed of light through glacier
    %WRONG math, its not beta/2, look in notes. 
    
    theta_rad = (pi/2)-atan(tower_height/Rt);
    theta = theta_rad * 180/pi;
    theta2 = asin(sind(theta)/ref_ind);
    AOA = atan(tower_height/Rt);
    AOA = AOA * 180/pi;
    R_ice = 2*thickness/cosd(theta);
    R_direct = sqrt(tower_height^2 + (Rt*cosd(90-theta) + 2*R_ice*theta2)^2);

    %L = sqrt(Rt^2+R_ice^2-2*Rt*R_ice*cosd(beta)); % direct path distance
    t_d = R_direct/c; %time for direct path
    t_r = Rt/c + (R_ice)/v; % expected time for reflected path
    tau = t_r-t_d;

    %constants from the radar equation
    PtGt = 8000; % 8 kW SEAN
    gamma = 0.3; %subsurface reflectivity 0.2-0.4 
    lambda = c/fc;
    Area = pi*lambda*tower_height*cosd(theta); % 
    Gr = 10^(6/10);% 6 dB
    sigma_b = gamma*4*pi*Area^2 /lambda^2; 
    k = 1.38*10^(-23);
    T_0 = 290;
    B = Fs; %bandwidth of the receiver will be the sampling frequency SEAN
    NF = 10^(15/10); %noise figure is 15 dB, can use 1-3, lower 
    ALFA = 10^((-13*R_ice)/10^4); %

    %Loading in complex waveform data
    x = wavedata;%.waveform;
    time = (0:length(x)-1)/Fs;
    n = length(x);
    fVals = (-n/2:n/2-1)/n*Fs;
    F = fft(x,n);

    %From wavedata the goal should be to determine P/Pn for the direct and
    %reflected path and then add wgn to my base signal and perform an
    %autocorrelation on that. 

    %Rr in this case will be distance from transmitter directly to receiver
    %R_ice will be distance from bedrock to receiver
    PrPn = (PtGt/(4*pi*Rt^2)) * sigma_b * (1/(4*pi*R_ice^2)) * ((Gr*lambda^2)/(4*pi)) * 1/(k*T_0*B*NF) * ALFA;
    PdPn = (PtGt/(4*pi*R_direct^2)) * sigma_b * ((Gr*lambda^2)/(4*pi)) * 1/(k*T_0*B*NF);

    PrPn = 10*log10(PrPn);        
    PdPn = 10*log10(PdPn);

    %These two numbers will be SNR for my awgn to my base signal. 
    direct_x = awgn(F, PdPn);
    reflected_x = awgn(F,PrPn);

    %Pre-allocating vectors to the same length of a zero-vector. 
    white_test = zeros(length(x),1);
    %F_noise = zeros(length(x),length(noise_range));
    %F_r_noise = F_noise;
    F_temp = white_test;
    F_x = F_temp;
    PSD = F_x;
    auto_corr = PSD;

    %Shifting the reflected signal by the expected time delay
    F_shift = reflected_x.*exp(-1i.*(2*pi*fVals'*tau));
    x_shifted = ifft(F_shift);

    %Adding the noise values and signal values together
    Fx = direct_x + F_shift;
    %x_all = ifft(Fx);

    NFFT = length(Fx);
    %Calculate the power spectral density of the sampled signal data
    PSD = (1/(Fs*NFFT))*(Fx.*conj(Fx));

    %perform an inverse fft on the  psd to get the autocorrelation between the
    %signals
    auto_corr = ifft(PSD);
    SNR_val2 = 10*log10(abs(auto_corr)./max(abs(auto_corr)));
    SNR_avg = mean(SNR_val2);

    % figure()
    % hold on
    % title("Plot of autocorrelation of signal and perfectly reflected signal")
    % plot(t',abs(auto_corr), 'linewidth', 2);
    % xline(tau,'color', 'red', 'LineWidth',0.5);
    % xlim([0,5*10^-5])
    % %ylim([0,1]);
    % xlabel("Time[s]")
    % ylabel("Magnitude")
    % legend("Autocorrelation", "Expected delay");
    % hold off
    % %Include PSD plot as well

end
