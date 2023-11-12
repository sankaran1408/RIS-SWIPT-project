clc;
clear all;
close all;

M = 16; 

% Number of bits to transmit
numBits = 100000;
data = randi([0, M-1], 1, numBits);


SNRdB = 0 : 1 : 20;
ser_simulated = zeros(1, length(SNRdB));
ser_theoretical = zeros(1, length(SNRdB));
ber_simulated = zeros(1, length(SNRdB));
ber_theoretical = zeros(1, length(SNRdB));

% Iterate through different SNR values
for snr_idx = 1 : length(SNRdB)
    SNRdB_current = SNRdB(snr_idx);
    
    % Calculate the SNR per symbol (Eo/No) for the given SNRdB
    SNRx = 10^(SNRdB_current / 10);
    
    % Calculate the signal energy per symbol (Eo) based on modulation order
    Eo = SNRx / log2(M);

    % Modulate binary data into QAM symbols
    qam_symbols = sqrt(Eo) * qammod(data, M);
    
    % Add AWGN noise to the QAM symbols
    n = sqrt(0.5 / Eo) * (randn(size(qam_symbols)) + 1i * randn(size(qam_symbols)));
    received_symbols = qam_symbols + n;

    % Demodulate the received symbols
    received_data = qamdemod(received_symbols, M);
    ser_simulated(snr_idx) = sum(received_symbols ~= qam_symbols) / numBits;
    ser_theoretical(snr_idx) = 4 * (1 - (1 / sqrt(M))) * qfunc(sqrt(2 * SNRx));
    ber_simulated(snr_idx) = ser_simulated(snr_idx) / log2(M);
    ber_theoretical(snr_idx) = ser_theoretical(snr_idx) / log2(M);
end

% Plot both simulated and theoretical BER on the same graph
semilogy(SNRdB, ber_simulated, 'ro', 'DisplayName', 'Simulated BEP');
hold on;
semilogy(SNRdB, ber_theoretical, 'b-', 'DisplayName', 'Theoretical BEP');
xlabel('SNR(dB)');
ylabel('BEP');
title(['BEP vs. SNR for ' num2str(M) '-QAM']);
grid on;
legend;

% Plot Symbol Error Probability (SEP) versus SNR
figure;
semilogy(SNRdB, ser_simulated, 'ro', 'DisplayName', 'Simulated SEP');
hold on;
semilogy(SNRdB, ser_theoretical, 'b-', 'DisplayName', 'Theoretical SEP');
xlabel('SNR(dB)');
ylabel('SEP');
title(['SEP vs. SNR for ' num2str(M) '-QAM']);
grid on;
legend;

