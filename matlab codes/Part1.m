% Define channel parameters
SNR_dB = 10; % Signal-to-Noise Ratio in dB
SNR = 10^(SNR_dB/10); % Convert dB to linear scale
channel_coefficient = 1; % Channel coefficient (can represent fading)

% Generate random binary data
num_bits = 1000;
data = randi([0, 1], 1, num_bits);

% Modulate the data (e.g., BPSK modulation)
modulated_data = 2 * data - 1;

% Add AWGN noise
noise = sqrt(1 / (2 * SNR)) * randn(1, num_bits);
received_signal = channel_coefficient * modulated_data + noise;

% Plot the transmitted and received signals
t = 1:num_bits;

figure;
subplot(2,1,1);
plot(t,modulated_data,'b.');
title('Transmitted signal (BPSK Modulation)');
xlabel('Time');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t,received_signal,'r.');
title('Received signal with AWGN');
xlabel('Time');
ylabel('Amplitude');
grid on;

%display the SNR value
disp(['SNR (dB):', num2str(SNR_dB)]);

% Calculate the bit error rate (BER)
errors = sum(data ~= (received_signal>0));
ber = errors / num_bits;

disp(['Bit Error Rate (BER):', num2str(ber)]);
