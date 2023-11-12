clc;
close all;
clear all;

M = 64;  % Modulation order for QAM
SNRdB = 0 : 2 : 20;
SNR = 10.^(SNRdB/10);
num_symbols = 100000;
M_values = ones(size(SNRdB)) * M;  % Keep M constant for all SNR values

% Varying the number of reflecting meta-surfaces (N)
N_values = [4, 8, 16, 64];

ser_simulated = zeros(length(N_values), length(SNRdB));

for ni = 1:length(N_values)
    N = N_values(ni);  % Number of reflecting meta-surfaces (RIS elements)
    x = randi([0, 1], 1, num_symbols);  % Generate random binary data

    for ii = 1 : length(SNRdB)
        qam_symbols = qammod(x, M);
        n = sqrt(0.5 / SNR(ii)) * (randn(size(qam_symbols)) + 1i * randn(size(qam_symbols)));
        h_i = (randn(N, size(qam_symbols,2)) + 1i * randn(N, size(qam_symbols,2))) / sqrt(2);
        phi_i = 2 * pi * rand(1, N);
        g_i = (randn(N, size(qam_symbols,2)) + 1i * randn(N, size(qam_symbols,2))) / sqrt(2);
        G = zeros(size(qam_symbols));

        for jj = 1 : size(qam_symbols, 2)
            for j = 1 : N
                G(:, jj) = G(:, jj) + g_i(j, jj) * exp(1i * phi_i(j)) * h_i(j, jj);
            end
        end
        received_symbols = G .* qam_symbols + n;
        received_bits = qamdemod(received_symbols./G, M);
        error_count = sum(x ~= received_bits);
        ser_simulated(ni, ii) = error_count / num_symbols;
    end
end

figure;
for ni = 1:length(N_values)
    semilogy(SNRdB, ser_simulated(ni, :), 'o-', 'DisplayName', sprintf('Simulated %d-RIS SER with %d-QAM', N_values(ni), M));
    hold on;
end

xlabel('SNR(dB)');
ylabel('SER');
title('RIS SER vs. SNR with Varying Number of N, M=64');
grid on;
legend('Location', 'best');
