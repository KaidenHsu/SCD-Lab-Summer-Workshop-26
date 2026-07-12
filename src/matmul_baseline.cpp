#include <array>
#include <chrono>
#include <cstdint>
#include <iostream>

int main() {
    constexpr int repetitions = 10'000'000;
    std::array<std::uint8_t, 9> a = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    std::array<std::uint8_t, 9> b = {9, 8, 7, 6, 5, 4, 3, 2, 1};

    const auto begin = std::chrono::steady_clock::now();
    for (int trial = 0; trial < repetitions; ++trial) {
        std::array<std::uint32_t, 9> c = {};

        for (int i = 0; i < 3; ++i)
            for (int j = 0; j < 3; ++j)
                for (int k = 0; k < 3; ++k)
                    c[i * 3 + j] += a[i * 3 + k] * b[k * 3 + j];

    }
    const auto end = std::chrono::steady_clock::now();

    const auto total_ns = std::chrono::duration_cast<std::chrono::nanoseconds>(
        end - begin
    ).count();

    std::cout << "Average runtime: "
              << static_cast<double>(total_ns) / repetitions << " ns\n";
}
