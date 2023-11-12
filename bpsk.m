clc;
close all;

M = 2; % BPSK
numBits = 100000;

data = randi([0, 1], 1, numBits); % Generate binary data (0 or 1)

% SNR range in dB
SNRdB = 0 : 2 : 10;

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
    modulated_data = pskmod(data, M, 0); % BPSK

    n = sqrt(0.5 / SNR) * (randn(size(modulated_data)) + 1i * randn(size(modulated_data)));
    received_symbols = modulated_data + n;

    % Demodulate received symbols
    demodulated_data = pskdemod(received_symbols, M, 0); % BPSK

    % Calculate Symbol Error Rate (SER)
    ser_simulated(snr_idx) = sum(demodulated_data ~= data) / numBits;

    % Calculate Bit Error Rate (BER)
    ber_simulated(snr_idx) = sum(data ~= demodulated_data) / numBits;

    % Theoretical SER and BER for BPSK
    ser_theoretical(snr_idx) = qfunc(sqrt(2 * SNR));
    ber_theoretical(snr_idx) = ser_theoretical(snr_idx);

end

figure(1)
semilogy(SNRdB, ser_simulated, 'ro-', 'DisplayName', 'Simulated SER');
hold on;
semilogy(SNRdB, ser_theoretical, 'b--', 'DisplayName', 'Theoretical SER');
xlabel('SNR(dB)');
ylabel('SER (log scale)');
title(['SER vs. SNR for BPSK']);
grid on;
legend;

figure(2)
semilogy(SNRdB, ber_simulated, 'ro-', 'DisplayName', 'Simulated BER');
hold on;
semilogy(SNRdB, ber_theoretical, 'b--', 'DisplayName', 'Theoretical BER');
xlabel('SNR(dB)');
ylabel('BER (log scale)');
title(['BER vs. SNR for BPSK']);
grid on;
legend;
figure;
scatterplot(received_symbols);
title('BPSK Constellation');
xlabel('Real Part');
ylabel('Imaginary Part');