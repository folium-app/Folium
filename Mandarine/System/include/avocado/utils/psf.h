#pragma once
#include "avocado/system.h"

enum class PsfType { Main, MainLib, SecondaryLib };

bool loadPsf(System* sys, const std::string& file, PsfType type = PsfType::Main);
