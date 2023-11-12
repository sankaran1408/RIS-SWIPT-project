clc;
clear all;
close all;

M_values = [2,4, 8, 16, 32, 64, 128];

% Initialize cell arrays to store BER and symbols for each M
BER_data = cell(1, length(M_values));
symbols_data = cell(1, length(M_values));
SER_data = cell(1, length(M_values));

SNRdB = 0:2:40; % SNR for simulation
SNRlin = 10.^(SNRdB/10);

% AWGN noise variance
N0 = 1./SNRlin;

for m_index = 1:length(M_values)
    M = M_values(m_index);
    
    % Generate random data for M-PSK symbols (log2(M) bits per symbol)
    numBits = 1000000;
    data_bits = randi([0, M-1], 1, numBits);

    % Modulate data into M-PSK symbols
    psk_symbols = pskmod(data_bits, M, 0);

    % Initialize BER and SER arrays for simulation
    BER = zeros(1, length(SNRlin));
    SER = zeros(1, length(SNRlin));

    % M-PSK symbol mapping
    S = psk_symbols;

    for k = 1:length(SNRdB)
        % Add AWGN noise to the M-PSK symbols
        n = sqrt(N0(k)/2) * (randn(size(S)) + 1i * randn(size(S)));
        received_symbols = S + n;

        % Demodulate the received symbols
        received_bits = pskdemod(received_symbols, M, 0);

        % Calculate Bit Error Rate (BER) from simulation
        error_bits = sum(data_bits ~= received_bits);
        BER(k) = error_bits /(numBits*log2(M));

        % Calculate Symbol Error Rate (SER) from simulation
        SER(k) = error_bits / numBits;
    end
    
    % Store BER, SER, and symbols in the cell arrays
    BER_data{m_index} = BER;
    symbols_data{m_index} = received_symbols;
    SER_data{m_index} = SER;
    
    % Plot scatter plot for the current value of M
    figure;
    scatterplot(received_symbols);
    title(sprintf('%d-PSK Constellation', M_values(m_index)));
    xlabel('Real Part');
    ylabel('Imaginary Part');
end

% Plot BER for all values of M on the same graph
figure;
for m_index = 1:length(M_values)
    semilogy(SNRdB, BER_data{m_index}, 'DisplayName', sprintf('%d-PSKs', M_values(m_index)));
    hold on;
end
xlabel('SNR[dB]');
ylabel('Bit Error Rate');
legend('Location', 'southwest');
title('Bit Error Rate for M-PSK Modulation');
grid on;

% Plot SER for all values of M on the same graph
figure;
for m_index = 1:length(M_values)
    semilogy(SNRdB, SER_data{m_index}, 'DisplayName', sprintf('%d-PSKs', M_values(m_index)));
    hold on;
end
xlabel('SNR[dB]');
ylabel('Symbol Error Rate');
legend('Location', 'southwest');
title(' Symbol Error Rate for M-PSK Modulation');
grid on;
