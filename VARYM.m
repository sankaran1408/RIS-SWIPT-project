clc;
close all;
clear all;

N =4;  % Number of reflecting meta-surfaces (RIS elements)
SNRdB = 0 : 2 : 14;
SNR = 10.^(SNRdB/10);
num_symbols = 100000;
N_values = ones(size(SNRdB)) * N;  % Keep N constant for all SNR values

% Varying modulation orders
M_values = [4, 8, 64,128];

ser_simulated = zeros(length(M_values), length(SNRdB));

for mi = 1:length(M_values)
    M = M_values(mi);  % Modulation order for QAM
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
        ser_simulated(mi, ii) = error_count / num_symbols;
    end
end

figure;
for mi = 1:length(M_values)
    semilogy(SNRdB, ser_simulated(mi, :), 'o-', 'DisplayName', sprintf('Simulated %d-QAM SER with RIS', M_values(mi)));
    hold on;
end

xlabel('SNR(dB)');
ylabel('SER');
title('RIS SER vs. SNR with Varying Modulation Orders and N=64');
grid on;
legend('Location', 'best');
