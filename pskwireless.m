clc
clear all;
close all;

M = 4; % Specify the modulation order
SNRdB = 0 : 2 : 30;

SNR = 10.^(SNRdB/10);

% Initialize BER and SER arrays
ber_simulated = zeros(1, length(SNRdB));
ser_simulated = zeros(1, length(SNRdB));
ber_theoretical = zeros(1, length(SNRdB));
ser_theoretical = zeros(1, length(SNRdB));

% Generate random data
num_symbols = 100000;
x = randi([0, M-1], 1, num_symbols);

% Generate Rayleigh fading channel coefficients h for all symbols
h = (randn(1, num_symbols) + 1i * randn(1, num_symbols)) / sqrt(2);

for i = 1 : length(SNRdB)
    if M == 2  % BPSK
        % Modulation for BPSK
        bpsk_symbols = pskmod(x, M, 0);
        psk_symbols = bpsk_symbols;
        
        % AWGN noise for BPSK
        n = sqrt(0.5 / SNR(i)) * (randn(size(psk_symbols)) + 1i * randn(size(psk_symbols)));
        
        % received signal with channel and noise for BPSK
        received_symbols = h .* bpsk_symbols + n ;
        
        % Demodulation for BPSK
        received_bits = pskdemod(received_symbols./h, M, 0);
        
        % Calculate Bit Error Rate (BER) using the specified formula with varying h
        SNR_lin = 10^(SNRdB(i)/10);
        
        for I = 1:num_symbols
            ber_theoretical(i) = ber_theoretical(i) + qfunc(sqrt(2 * SNR_lin * abs(h(I))^2));
        end
        ber_theoretical(i) = ber_theoretical(i) / num_symbols; % Updated formula
        
        symbol_error_count = sum(x ~= received_bits);
        ber_simulated(i) = symbol_error_count / (num_symbols);
        
        % Calculate Symbol Error Rate (SER) for BPSK
        ser_theoretical(i) = ber_theoretical(i) * log2(M);
        symbol_error_count = sum(x ~= (received_bits));
        ser_simulated(i) = symbol_error_count / length(x);
    else
        % Modulation for QPSK and other PSK
        psk_symbols = pskmod(x, M, 0);
        
        % AWGN noise for other PSK modulations
        n = sqrt(0.5 / SNR(i)) * (randn(size(psk_symbols)) + 1i * randn(size(psk_symbols)));
        
        % Simulate the received signal with channel and noise for other PSK
        received_symbols = h .* psk_symbols + n;
        
        % Demodulation for QPSK and other PSK
        received_bits = pskdemod(received_symbols./h, M, 0);
        
        % Calculate Bit Error Rate (BER) using the specified formula with varying h
        SNR_lin = 10^(SNRdB(i)/10);
        
        for I = 1:num_symbols
         ber_theoretical(i) = ber_theoretical(i) + qfunc(sqrt(2 * SNR_lin/log2(M) * (abs(h(I))^2)) * sin(pi/M));

        end
        ber_theoretical(i) = ber_theoretical(i) / (num_symbols * log2(M));
        
        bit_errors = sum(de2bi(x, log2(M)) ~= de2bi(received_bits, log2(M))); % Compare bit by bit
        ber_simulated(i) = sum(bit_errors) / (num_symbols * log2(M));
        
        % Calculate Symbol Error Rate (SER) for other PSK modulations
        ser_theoretical(i) = ber_theoretical(i) * log2(M);
        symbol_error_count = sum(x ~= received_bits);
        ser_simulated(i) = symbol_error_count / num_symbols;
    end
end

% Plot the simulated and theoretical BER
figure;
semilogy(SNRdB, ber_simulated, '-', 'DisplayName', sprintf('Simulated %d-PSK BER', M));
hold on;
semilogy(SNRdB, ber_theoretical, '--', 'DisplayName', sprintf('Theoretical %d-PSK BER', M));
xlabel('SNR(dB)');
ylabel('BER');
title(sprintf('BER vs. SNR for %d-PSK', M));
grid on;
legend;

% Plot the simulated and theoretical SER
figure;
semilogy(SNRdB, ser_simulated, '-', 'DisplayName', sprintf('Simulated %d-PSK SER', M));
hold on;
semilogy(SNRdB, ser_theoretical, '--', 'DisplayName', sprintf('Theoretical %d-PSK SER', M));
xlabel('SNR(dB)');
ylabel('SER');
title(sprintf('SER vs. SNR for %d-PSK', M));
grid on;
legend;