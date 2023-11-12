clc;
clear all;
close all;

M = input("Enter the value of M: ");

numBits = 100000;

% Generate random bits
data = randi([0, M-1], 1, numBits);

% SNR range in dB
SNRdB = 0 : 2 : 12;

% Arrays to store simulated SER and BER
ser_simulated = zeros(1, length(SNRdB));
ber_simulated = zeros(1, length(SNRdB));

% Arrays to store theoretical SER and BER
ser_theoretical = zeros(1, length(SNRdB));
ber_theoretical = zeros(1, length(SNRdB));

for snr_idx = 1 : length(SNRdB)
    SNRdB_current = SNRdB(snr_idx);
    
    % Calculate the noise variance from SNR
    SNR = 10^(SNRdB_current / 10);

    % Modulate symbols
    modulated_data = qammod(data, M, "gray");

    n = sqrt(0.5 / SNR) * (randn(size(modulated_data)) + 1i * randn(size(modulated_data)));
    received_symbols = modulated_data + n;

    % Demodulate received symbols
    demodulated_data = qamdemod(received_symbols, M, 'gray');
    ser_simulated(snr_idx) = sum(demodulated_data ~= data) / numBits;
    data_matrix = de2bi(data, log2(M)); % Convert data to a matrix
    demod_matrix = de2bi(demodulated_data, log2(M)); % Convert demodulated data to a matrix
    ber_simulated(snr_idx) = sum(sum(data_matrix ~= demod_matrix)) / (log2(M)*numBits);
    Eo = SNR / log2(M);
    ser_theoretical(snr_idx) = 4 * (1 - (1 / sqrt(M))) * qfunc(sqrt(2 * SNR));
    ber_theoretical(snr_idx) = ser_theoretical(snr_idx) / log2(M);
end

% Plot SER and BER with scatter plots
figure(1)
semilogy(SNRdB, ser_simulated, 'ro-', 'DisplayName', 'Simulated SER');
hold on;
semilogy(SNRdB, ser_theoretical, 'b--', 'DisplayName', 'Theoretical SER');
xlabel('SNR(dB)');
ylabel('SER (log scale)');
title(['SER vs. SNR for ' num2str(M) '-QAM']);
grid on;
legend;
scatter(SNRdB, ser_simulated, 'filled', 'r', 'DisplayName', 'Scatter Plot');
legend;

figure(2)
semilogy(SNRdB, ber_simulated, 'ro-', 'DisplayName', 'Simulated BER');
hold on;
semilogy(SNRdB, ber_theoretical, 'b--', 'DisplayName', 'Theoretical BER');
xlabel('SNR(dB)');
ylabel('BER (log scale)');
title(['BER vs. SNR for ' num2str(M) '-QAM']);
grid on;
legend;