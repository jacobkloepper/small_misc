#include <iostream>
#include <vector>
#include <cmath>

// Given a decimal int dec and the number of boolean variables, create a vector
// of the binary representation of that integer.
std::vector<int> binary_vector(int dec, int num_vars) {
    std::vector<int> vec {};

    int temp {};

    // Get the binary representation
    while (dec) {
        temp = dec % 2;
        vec.push_back(temp);
        dec = dec / 2;
    }

    // Fill the rest of the vector with zeroes.
    for (size_t i {vec.size()}; i < num_vars; i++) {
        vec.push_back(0);
    }

    return vec;
}

// Given n Boolean variables, a vector containing their names, and the specific minterm asked for,
// print the minterm to stdout.
void print_canon(int num_vars, std::vector<char> names, int minterm) {
    std::vector<int> min = binary_vector(minterm, num_vars);
    int name_idx {};

    for (size_t i {0}; i < min.size(); i++) {
        std::cout << names.at(name_idx);

        if (!min.at(min.size()-1-i)) {
            std::cout << "\'";
        }
        name_idx++;
    }
}

std::vector<char> name_vars(int num_vars) {
    std::vector<char> vec {};
    char _var {};

    std::cout << "Name them:" << std::endl;

    for (int i {0}; i < num_vars; i++) {
        std::cin >> _var;
        vec.push_back(_var);
    }

    return vec;
}

int main() {
    std::cout << "How many Boolean variables? 4 max." << std::endl;

    int num_vars;
    std::cin >> num_vars;

    std::vector<char> names {name_vars(num_vars)};

    // Continuously output minterms given the above Boolean variables.
    while (true) {
        std::vector<int> minterms{};
        int minterm{};

        std::cout << "Which minterms are included? Input -1 to stop. Input -2 to end." << std::endl;

        // Loop while in use.
        while (minterm != -1) {

            // Break program on use.
            if (minterm == -2) {
                return 0;
            }

            // Too large case.
            if (minterm > pow(2, num_vars) - 1) {
                std::cout << "Minterms must be on [0," << pow(2, num_vars) - 1 << "]." << std::endl;
                std::cin >> minterm;
            }

            // Normal case.
            else {
                std::cin >> minterm;
                if (minterm != -1) {
                    minterms.push_back(minterm);
                }
            }
        }

        // Print minterm canonical form to stdout.
        std::cout << "The Boolean function is written in canonical form as follows:" << std::endl;
        std::cout << "F = ";

        for (size_t i{0}; i < minterms.size(); i++) {
            print_canon(num_vars, names, minterms.at(i));
            if (i != minterms.size() - 1) {
                std::cout << " + ";
            }
        }

        std::cout << std::endl;
        std::cout << std::endl;
    }
}