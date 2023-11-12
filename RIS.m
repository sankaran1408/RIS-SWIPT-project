clc;
close all;
clear all;

 M = 4;  % Modulation order for QAM
SNRdB = 0 : 2 : 20;

SNR = 10.^(SNRdB/10);

ser_simulated = zeros(1, length(SNRdB));

num_symbols = 100000;
x = randi([0, 1], 1, num_symbols);  % Generate random binary data

N = 4;  % Number of reflecting meta-surfaces (RIS elements)

for ii = 1 : length(SNRdB)
    % Modulation for QAM
    qam_symbols = qammod(x, M); 
    
    % AWGN noise for BPSK
    n = sqrt(0.5 / SNR(ii)) * (randn(size(qam_symbols)) + 1i * randn(size(qam_symbols)));
    
    h_i = (randn(N, size(qam_symbols,2)) + 1i * randn(N, size(qam_symbols,2))) / sqrt(2);
    
    phi_i = 2 * pi * rand(1, N);
    
    g_i = (randn(N, size(qam_symbols,2)) + 1i * randn(N, size(qam_symbols,2))) / sqrt(2);

    G = zeros(size(qam_symbols));
    
    for jj = 1 : size(qam_symbols, 2)
        for j = 1 : N
            G(:, jj) = G(:, jj) + g_i(j, jj).*exp(1i * phi_i(j))  .* h_i(j, jj);
        end
    end
    received_symbols = G .* qam_symbols + n;

    received_bits = qamdemod(received_symbols./G, M); 

    error_count = sum(x ~= received_bits);
    ser_simulated(ii) = error_count / num_symbols;
end
 figure;
 semilogy(SNRdB, ser_simulated, 'ro-', 'DisplayName', sprintf('Simulated %d-QAM SER with RIS', M));
 xlabel('SNR(dB)');
 ylabel('SER');
 title(sprintf('RIS SER vs. SNR for %d-QAM with RIS,N=4', M));
 grid on;
 legend;