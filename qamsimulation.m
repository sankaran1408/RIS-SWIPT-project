clc;
clear all;
close all;

M_values = [4,8,16,32, 64,128]; 

BER_data = cell(1, length(M_values));
symbols_data = cell(1, length(M_values));
SER_data = cell(1, length(M_values));

SNRdB = 0:2:20; 
SNRlin = 10.^(SNRdB/10);

% AWGN noise variance
N0 = 1./SNRlin;

for m_index = 1:length(M_values)
    M = M_values(m_index);
    
    % Generate random data for QAM symbols (log2(M) bits per symbol)
    numBits = 1000000;
    data_bits = randi([0, M-1], 1, numBits);

    % Modulate data into QAM symbols
    qam_symbols = qammod(data_bits, M, 'gray');

    % Initialize BER and SER arrays for simulation
    BER = zeros(1, length(SNRlin));
    SER = zeros(1, length(SNRlin));

    for k = 1:length(SNRdB)
        % Add AWGN noise to the QAM symbols
        n = sqrt(N0(k)/2) * (randn(size(qam_symbols)) + 1i * randn(size(qam_symbols)));
        received_symbols = qam_symbols + n;

        % Demodulate the received symbols
        received_bits = qamdemod(received_symbols, M, 'gray');

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
    
    % Plot scatter plot for the current QAM order
    figure;
    scatterplot(received_symbols);
    title(sprintf('%d-QAM Constellation', M_values(m_index)));
    xlabel('Real Part');
    ylabel('Imaginary Part');
end

% Plot BER for all QAM orders on the same graph
figure;
for m_index = 1:length(M_values)
    semilogy(SNRdB, BER_data{m_index}, 'DisplayName', sprintf('%d-QAM', M_values(m_index)));
    hold on;
end
xlabel('SNR[dB]');
ylabel('Bit Error Rate');
legend('Location', 'southwest');
title('Bit Error Rate for QAM Modulation');
grid on;

% Plot SER for all QAM orders on the same graph
figure;
for m_index = 1:length(M_values)
    semilogy(SNRdB, SER_data{m_index}, 'DisplayName', sprintf('%d-QAM', M_values(m_index)));
    hold on;
end
xlabel('SNR[dB]');
ylabel('Symbol Error Rate');
legend('Location', 'southwest');
title(' Symbol Error Rate for QAM Modulation');
grid on;
