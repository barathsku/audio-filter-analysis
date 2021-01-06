%% Prechecks
clear variables; close all;

%% Original/Noisy Audio Read
[ori_data, ori_rate] = audioread('original.wav');
[noisy_data, noisy_rate] = audioread('noisy.wav');

%% Filter Specifications
% Original Audio - Time Domain Graph
figure('name','Original Audio Spectrum');
subplot(2, 1, 1);
plot(abs(ori_data));
title('Time Domain');
xlabel('Time (s)');
ylabel('Magnitude');

% Original Audio - Frequency Domain Graph
subplot(2, 1, 2);
plot(abs(fft(ori_data, 8000)));
title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Noisy Audio - Time Domain Graph
figure('name', 'Noisy Audio Spectrum');
subplot(2,1,1);
plot(abs(noisy_data));
title('Time Domain');
xlabel('Time');
ylabel('Magnitude');

% Noisy Audio - Frequency Domain Graph
subplot(2,1,2);
plot(abs(fft(noisy_data, 8000)));
title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Unwanted Frequency Extraction
figure('name','Data Analysis');
data_diff = ori_data - noisy_data;
plot(abs(fft(data_diff, 8000)));
title('Frequency Difference Between Original/Noisy Audios');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
axis([1500 6500 0 1000]);

cutoff_freq = 1904/(noisy_rate/2); % 0.476

%% FIR Filter Design
% Normalizing noisy data
noisy_data = noisy_data(1:noisy_rate*8);
noisy_data = noisy_data*(1/max(abs(noisy_data)));

% Rectangular Window
rect_n = 37;
rect_filter = fir1(rect_n-1, cutoff_freq, rectwin(rect_n), 'noscale');
rect_filter_output = filter(rect_filter, 1, noisy_data);
audiowrite('output_rectwin.wav', rect_filter_output, 8000);

% Hanning Window
hanning_n = 125;
hanning_filter = fir1(hanning_n-1, cutoff_freq, hanning(hanning_n), 'noscale');
hanning_filter_output = filter(hanning_filter, 1, noisy_data);
audiowrite('output_hanning.wav', hanning_filter_output, 8000);

% Hamming Window
hamming_n = 133;
hamming_filter = fir1(hamming_n-1, cutoff_freq, hamming(hamming_n), 'noscale');
hamming_filter_output = filter(hamming_filter, 1, noisy_data);
audiowrite('output_hamming.wav', hamming_filter_output, 8000);

% Blackman Window
blackman_n = 221;
blackman_filter = fir1(blackman_n-1, cutoff_freq, blackman(blackman_n), 'noscale');
blackman_filter_output = filter(blackman_filter, 1, noisy_data);
audiowrite('output_blackman.wav', blackman_filter_output, 8000);

%figure('name', 'All Filters' Frequency Response');
%freqz(rect_filter); hold on;
%freqz(hanning_filter); hold on;
%freqz(hamming_filter); hold on;
%freqz(blackman_filter); hold on;

%title('Filtered frequency spectrum');
%lines = findall(gcf,'type','line');
%lines(1).Color = 'red'; % Blackman
%lines(2).Color = 'green'; % Hamming
%lines(3).Color = 'blue'; % Hanning
%lines(4).Color = 'yellow'; % Rectangular Window

%% IIR Filter Design
% Initialization variables
Ap = 3;  % Passband ripple
As = 40; % Stopband attenuation
Wp = 1904/(noisy_rate/2); % 1904 Hz = Passband edge frequency
Ws = 2104/(noisy_rate/2); % 2104 Hz = Stopband edge frequency

% Butterworth filter
[butter_n, butter_Wn] = buttord(Wp, Ws, Ap, As);
[butter_x, butter_y] = butter(Ap, butter_Wn);
butter_filter_output = filter(butter_x, butter_y, noisy_data);
audiowrite('output_butter.wav', butter_filter_output, 8000);

% Chebyshev filter
cheby_n = 13;
[cheby_x, cheby_y] = cheby1(cheby_n, Ap, Wp);
cheby_filter_output = filtfilt(cheby_x, cheby_y, noisy_data);
audiowrite('output_cheby.wav', cheby_filter_output, 8000);

% Frequency spectrum
figure('name', 'Butterworth/Chebyshev Frequency Response');
freqz(butter_x, butter_y); hold on;
freqz(cheby_x, cheby_y);

% Butterworth frequency analysis
figure('name', 'Frequency Analysis');
plot(abs(fft(butter_filter_output, 8000)));
title('Butterworth Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% Filtered Signal Evaluation
% FIR Filter (Hanning) - Time Domain Graph
figure('name', 'FIR Filter (Hanning)');
subplot(2,1,1);
plot(abs(hanning_filter_output));
title('Time Domain');
xlabel('Time');
ylabel('Magnitude');

% FIR Filter (Hanning) - Frequency Domain Graph
subplot(2,1,2);
plot(abs(fft(hanning_filter_output, 8000)));
title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% IIR Filter (Chebyshev) - Time Domain Graph
figure('name', 'IIR Filter (Chebyshev)');
subplot(2,1,1);
plot(abs(cheby_filter_output));
title('Time Domain');
xlabel('Time');
ylabel('Magnitude');

% IIR Filter (Chebyshev) - Frequency Domain Graph
subplot(2,1,2);
plot(abs(fft(cheby_filter_output, 8000)));
title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
