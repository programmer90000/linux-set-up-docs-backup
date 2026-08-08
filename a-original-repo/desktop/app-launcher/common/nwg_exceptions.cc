#include <cerrno>
#include <cstring>
#include "nwg_exceptions.h"

std::string error_description(int err) {
    errno = 0;
    auto cstr = std::strerror(err);
    if (!cstr || errno) {
        throw std::runtime_error{ "failed to retrieve errno description: strerror return NULL" };
    }
    return { cstr };
}
