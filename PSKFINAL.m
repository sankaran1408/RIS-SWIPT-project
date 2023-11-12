clc;
close all;
M = input("Enter the value of M: ");

numBits = 1000000;

data = randi([0, M-1], 1, numBits);

% SNR range in dB
SNRdB = 0 : 2 :12;

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
    modulated_data = pskmod(data, M, 0); 

    n = sqrt(0.5 / SNR) * (randn(size(modulated_data)) + 1i * randn(size(modulated_data)));
    received_symbols = modulated_data + n;

    % Demodulate received symbols
    demodulated_data = pskdemod(received_symbols, M, 0); % '0' for non-gray coding

    % Calculate Symbol Error Rate (SER)
    ser_simulated(snr_idx) = sum(demodulated_data ~= data) / numBits;

    % Calculate Bit Error Rate (BER)
    data_matrix = de2bi(data, log2(M)); % Convert data to a matrix
    demod_matrix = de2bi(demodulated_data, log2(M)); % Convert demodulated data to a matrix
    ber_simulated(snr_idx) = sum(sum(data_matrix ~= demod_matrix)) / (log2(M)*numBits);


    ser_theoretical(snr_idx) = 2 * qfunc(sqrt((2 * SNR)) * sin(pi / M));

    ber_theoretical(snr_idx) = ser_theoretical(snr_idx) / log2(M);
end

figure(1)
semilogy(SNRdB, ser_simulated, 'ro-', 'DisplayName', 'Simulated SER');
hold on;
semilogy(SNRdB, ser_theoretical, 'b--', 'DisplayName', 'Theoretical SER');
xlabel('SNR(dB)');
ylabel('SER (log scale)');
title(['SER vs. SNR for ' num2str(M) '-PSK']);
grid on;
legend;

figure(2)
semilogy(SNRdB, ber_simulated, 'ro-', 'DisplayName', 'Simulated BER');
hold on;
semilogy(SNRdB, ber_theoretical, 'b--', 'DisplayName', 'Theoretical BER');
xlabel('SNR(dB)');
ylabel('BER (log scale)');
title(['BER vs. SNR for ' num2str(M) '-PSK']);
grid on;
legend;




