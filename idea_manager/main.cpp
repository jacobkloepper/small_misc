#include <iostream>
#include <fstream>
#include <vector>
#include <string>

// Get the inputs to the questions as specified in the template.
void get_inputs(std::vector<std::string>& input) {
    std::string tmp_input;
    std::cout << "What is the name of the idea?" << std::endl;
    std::getline(std::cin, tmp_input);
    input.push_back(tmp_input);

    std::cout << "What language(s) do you plan to use?" << std::endl;
    std::getline(std::cin, tmp_input);
    input.push_back(tmp_input);

    std::cout << "Provide a brief summary." << std::endl;
    std::getline(std::cin, tmp_input);
    input.push_back(tmp_input);

    while (tmp_input != "q") {
        std::cout << "Provide a list of potential issues or notes. Input \"q\" to terminate." << std::endl;
        std::getline(std::cin, tmp_input);
        if (tmp_input != "q") {
            input.push_back(tmp_input);
        }
    }
}

// Get size of longest line, include extra formatted characters.
unsigned long get_max_line_size(std::vector<std::string>& input) {
    unsigned long max_size = 0;
    for (size_t i {0}; i < input.size(); i++) {
        if (i == 0 ) {
            if (input.at(i).size() + 6 > max_size) {
                max_size = input.at(i).size()+6;
            }
        } else if (i == 1) {
            if (input.at(i).size() + 13 > max_size) {
                max_size = input.at(i).size() + 13;
            }
        } else if (i == 2) {
            if (input.at(i).size() + 9 > max_size) {
                max_size = input.at(i).size() + 9;
            }
        } else if (i > 2) {
                if (input.at(i).size() + (7) > max_size) {
                    max_size = input.at(i).size() + (7);
                }
            }
        }
    // Catch for if each line is very short.
    if (max_size < 34) {
        max_size = 34;
    }
    return max_size;
}

void append_file(std::vector<std::string>& input) {
    // Open the idea file in append mode
    std::ofstream ofile;
    ofile.open("ideas.txt", std::ios_base::app);
    if (!ofile.is_open()) {
        std::cout << "failed to open ideas.txt" << std::endl;
        exit(1);
    }

    // Get size of longest line.
    unsigned long max_size {get_max_line_size(input)};

    ofile << std::string(int(max_size), '-') << std::endl;
    ofile << "Name: " << input.at(0) << std::endl;
    ofile << "Language(s): " << input.at(1) << std::endl;
    ofile << "Summary: " << input.at(2) << std::endl;

    if (input.size()-1 > 2) {
        ofile << std::endl;
        ofile << "List of potential issues or notes:" << std::endl;
        for (size_t i {3}; i < input.size(); i++) {
            ofile << "    " << i-2 << ". " << input.at(i) << std::endl;
        }
    }
    ofile << std::string(int(max_size), '-') << std::endl;
    ofile << std::endl;

    ofile.close();
}

int main() {
    while(true) {
        std::vector<std::string> input;
        get_inputs(input);

        append_file(input);

        std::cout << "Idea added." << std::endl;
    }
    return 0;
}
