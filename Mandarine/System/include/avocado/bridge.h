//
//  bridge.h
//  Mandarine
//
//  Created by Jarrod Norwell on 14/6/2026.
//

#include <string>

namespace mandarine {
void print_about(void);

void initialize_paths(void);
void initialize_memory_cards(void);
void initialize_system(void);

void destroy_system(void);

void insert_disc(std::string);
}
