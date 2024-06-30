#pragma once

#include <string_view>

#include "quicktype_fwd.h"

namespace validator {

void globalInit();
void globalDestroy();
void Validate(std::string_view id, std::string_view data);
template <typename T> void Validate(std::string_view);

}
