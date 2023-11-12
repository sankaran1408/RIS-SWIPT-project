clc
close all;
M = 8; 
SNRdB = 0 : 2 : 40;

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
    % Modulation for QAM
    qam_symbols = qammod(x, M);
    
    % AWGN noise for QAM
    n = sqrt(0.5 / SNR(i)) * (randn(size(qam_symbols)) + 1i * randn(size(qam_symbols)));
    
    % Simulate the received signal with channel and noise for QAM
    received_symbols = h .* qam_symbols + n;
    
    % Demodulation for QAM
    received_bits = qamdemod(received_symbols ./ h, M);
    
    % Calculate Bit Error Rate (BER) using the specified formula with varying h
    SNR_lin = 10^(SNRdB(i)/10);
    for I = 1:num_symbols
        ber_theoretical(i) = ber_theoretical(i) + (4 * (1 - (1 / sqrt(M))) .* qfunc(sqrt(2 * SNR_lin.*abs(h(I))^2)));
    end
    ber_theoretical(i) = ber_theoretical(i) / (num_symbols*log2(M)); % Updated formula
    
    bit_errors = sum(de2bi(x, log2(M)) ~= de2bi(received_bits, log2(M))); % Compare bit by bit
    ber_simulated(i) = sum(bit_errors) / (num_symbols * log2(M));
    
    % Calculate Symbol Error Rate (SER) for QAM
    ser_theoretical(i) = ber_theoretical(i) * log2(M);
    symbol_error_count = sum(x ~= received_bits);
    ser_simulated(i) = symbol_error_count / num_symbols;
end


% Plot the simulated and theoretical SER
figure;
semilogy(SNRdB, ser_simulated, 'ro-', 'DisplayName', sprintf('Simulated %d-QAM SER', M));
hold on;
semilogy(SNRdB, ser_theoretical, 'b--', 'DisplayName', sprintf('Theoretical %d-QAM SER', M));
xlabel('SNR(dB)');
ylabel('SER');
title(sprintf('Wireless Communication SER vs. SNR for %d-QAM', M));
grid on;
legend;
