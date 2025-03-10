#include "vi.h"

void VI::bump_current_line() {
    m_current_line++;
    m_current_line %= 0x400;
}
