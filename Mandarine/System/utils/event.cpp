#include "avocado/utils/event.h"

Dexode::EventBus bus;

void toast(const std::string& message) { bus.notify(Event::Gui::Toast{message}); }
