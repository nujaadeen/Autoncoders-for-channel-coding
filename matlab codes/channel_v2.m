modulationDemodulationChannel(4, '16qam', 10, true);  % QPSK with Rayleigh fading

function ber = modulationDemodulationChannel(M, modulation, snr_dB, fading)
    % M: Modulation order (e.g., 2 for BPSK, 4 for QPSK, 16 for 16-QAM, etc.)
    % modulation: 'bpsk', 'qpsk', '16qam', etc.
    % snr_dB: Signal-to-Noise Ratio in dB
    % fading: true for Rayleigh fading, false for no fading

    % Parameters
    numBits = 1000 * log2(M);

    % Generate random binary data
    data = randi([0, 1], numBits, 1);

    % Modulation
    modulatedSymbols = modulateData(data, M, modulation);

    % Channel simulation
    receivedSymbols = channelModel(modulatedSymbols, snr_dB, fading);

    % Demodulation
    rxData = demodulateData(receivedSymbols, M, modulation);

    % Calculate Bit Error Rate (BER)
    ber = sum(data ~= rxData) / numBits;

    % Display results
    disp(['Modulation: ', modulation]);
    disp(['SNR (dB): ', num2str(snr_dB)]);
    disp(['Bit Error Rate (BER): ', num2str(ber)]);

    % Plot constellation diagram
    scatterplot(receivedSymbols);
    title('Received Constellation Diagram');
end

function modulatedSymbols = modulateData(data, M, modulation)
    switch lower(modulation)
        case 'bpsk'
            modulatedSymbols = 2 * data - 1;
        case 'qpsk'
            modulatedSymbols = pskmod(data, M, pi/4);
        case '16qam'
            modulatedSymbols = qammod(data, M);
        % Add more cases for other modulation schemes if needed
        otherwise
            error('Invalid modulation scheme.');
    end
end

function receivedSymbols = channelModel(modulatedSymbols, snr_dB, fading)
    % AWGN
    noisePower = 10^(-snr_dB/10);
    noise = sqrt(noisePower/2) * (randn(size(modulatedSymbols)) + 1i * randn(size(modulatedSymbols)));

    % Rayleigh Fading
    if fading
        h = (randn(size(modulatedSymbols)) + 1i * randn(size(modulatedSymbols))) / sqrt(2);
        receivedSymbols = h .* modulatedSymbols + noise;
    else
        receivedSymbols = modulatedSymbols + noise;
    end
end

function rxData = demodulateData(receivedSymbols, M, modulation)
    switch lower(modulation)
        case 'bpsk'
            rxData = real(receivedSymbols) > 0;
        case 'qpsk'
            rxData = pskdemod(receivedSymbols, M, pi/4);
        case '16qam'
            rxData = qamdemod(receivedSymbols, M);
        % Add more cases for other modulation schemes if needed
        otherwise
            error('Invalid modulation scheme.');
    end
end
