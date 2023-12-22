% Define channel parameters
SNR_dB = 10; % Signal-to-Noise Ratio in dB
SNR = 10^(SNR_dB/10); % Convert dB to linear scale

% Generate random binary data
num_bits = 1000;
data = randi([0, 1], 1, num_bits);

% Channel coding type ('none', 'hamming')
channel_coding_type = 'hamming';

% Encode the data
encoded_data = encode_data(data, channel_coding_type);

% Choose modulation type ('bpsk', 'qpsk', '16qam')
modulation_type = '16qam';

% Modulate the data
modulated_data = modulate_data(encoded_data, modulation_type);

figure;
subplot(3,1,1);
stairs(real(data), 'b'); % Plot the real part
title(['original signal (' upper(modulation_type) ' Modulation)']);
ylim([-1.5 1.5])
xlabel('Time');
ylabel('Amplitude');
grid on;

subplot(3,1,2);
stairs(real(encoded_data), 'r'); % Plot the real part
title(['Encoded data (' upper(modulation_type) ' Modulation)']);
ylim([-1.5 1.5])
xlabel('Time');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
stairs(real(modulated_data), 'r'); % Plot the real part
title(['Modulated data (' upper(modulation_type) ' Modulation)']);
ylim([-4 4])
xlabel('Time');
ylabel('Amplitude');
grid on;

% Add Rayleigh fading
fading_channel = (1/sqrt(2)) * (randn(1, num_bits) + 1i * randn(1, num_bits)); % Rayleigh fading
received_signal_with_fading = fading_channel .* modulated_data;

% Add AWGN to the received signal with fading
noise = sqrt(1 / (2 * SNR)) * (randn(1, num_bits) + 1i * randn(1, num_bits)); % Complex AWGN
received_signal = received_signal_with_fading + noise;

% Plot the transmitted and received signals
t = 1:length(modulated_data);

figure;
subplot(2,1,1);
stairs(t, real(modulated_data), 'b'); % Plot the real part
title(['Transmitted signal (' upper(modulation_type) ' Modulation)']);
ylim([-4 4])
xlabel('Time');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
stairs(t, real(received_signal), 'r'); % Plot the real part
title(['Received signal with Rayleigh Fading and AWGN (' upper(modulation_type) ' Modulation)']);
xlabel('Time');
ylabel('Amplitude');
grid on;



% Display the SNR value
disp(['SNR (dB): ', num2str(SNR_dB)]);

% Calculate the bit error rate (BER)
errors = sum(data ~= (real(received_signal) > 0)); % Compare with real part
ber = errors / num_bits;

disp(['Bit Error Rate (BER): ', num2str(ber)]);


% Function to encode data based on coding type
function encoded_data = encode_data(data, coding_type)
    switch coding_type
        case 'none'
            encoded_data = data;
        case 'hamming'
            m = 3; % Hamming(7, 4)
            n = 2^m - 1;
            k = 4;
            encoded_data = encode(data, n, k, 'hamming/binary');
        otherwise
            error('Unsupported coding type');
    end
end

% Function to decode data based on coding type
function decoded_data = decode_data(data, coding_type)
    switch coding_type
        case 'none'
            decoded_data = data;
        case 'hamming'
            m = 3; % Hamming(7, 4)
            n = 2^m - 1;
            k = 4;
            decoded_data = decode(data, n, k, 'hamming/binary');
        otherwise
            error('Unsupported coding type');
    end
end

% Function to modulate data based on modulation type
function modulated_signal = modulate_data(data, modulation_type)
    switch modulation_type
        case 'bpsk'
            modulated_signal = 2 * data - 1;
        case 'qpsk'
            data_symbols = 2 * data - 1;
            modulated_signal = (1/sqrt(2)) * (data_symbols(1:2:end) + 1i * data_symbols(2:2:end));
        case '16qam'
            % Ensure the length of data is divisible by 4
            if mod(length(data), 4) ~= 0
                % If not, pad with zeros
                data = [data, zeros(1, 4 - mod(length(data), 4))];
            end

            % Map each 4-bit group to a complex symbol
            data_symbols = reshape(data, 4, []).';
            decimal_values = bin2dec(num2str(data_symbols));
            symbol_mapping = [
                -3 -3; -3 -1; -3 3; -3 1;
                -1 -3; -1 -1; -1 3; -1 1;
                3 -3; 3 -1; 3 3; 3 1;
                1 -3; 1 -1; 1 3; 1 1
            ];
            modulated_signal = symbol_mapping(decimal_values + 1, 1) + 1i * symbol_mapping(decimal_values + 1, 2) / sqrt(10);
        otherwise
            error('Unsupported modulation type');
    end
end
