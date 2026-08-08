#include <string_view>
#include <variant>
#include <fstream>
#include "filesystem-compat.h"
#include "nwg_tools.h"
#include "grid.h"
#include "log.h"

CacheEntry::CacheEntry(std::string desktop_id, int clicks): desktop_id(std::move(desktop_id)), clicks(clicks) { }

/*
 * Returns locations of .desktop files
 * */
std::vector<fs::path> get_app_dirs() {
    std::vector<fs::path> result;
    result.reserve(2);
    
    fs::path home;
    if (auto home_ = getenv("HOME")) {
        home = home_;
    }
    
    if (!home.empty()) {
        result.emplace_back(home) /= ".config/desktop-files";
    }
    
    result.emplace_back("/usr/local/share") /= "desktop-files";
    
    return result;
}

/*
 * Returns vector of strings out of the pinned cache file content
 * */
std::vector<std::string> get_pinned(const fs::path& pinned_file) {
    std::vector<std::string> lines;
    if (std::ifstream in{ pinned_file }) {
        for (std::string str; std::getline(in, str);) {
            // add non-empty lines to the vector
            if (!str.empty()) {
                lines.emplace_back(std::move(str));
            }
        }
    } else {
        Log::info("Could not find ", pinned_file, ", creating!");
        save_string_to_file("", pinned_file);
    }
    return lines;
}

/*
 * Returns n cache items sorted by clicks; n should be the number of grid columns
 * */
std::vector<CacheEntry> get_favourites(ns::json&& cache, int number) {
    // read from json object
    std::vector<CacheEntry> sorted_cache {}; // not yet sorted
    for (auto it : cache.items()) {
        sorted_cache.emplace_back(it.key(), it.value());
    }
    // actually sort by the number of clicks
    std::sort(sorted_cache.begin(), sorted_cache.end(), [](const CacheEntry& lhs, const CacheEntry& rhs) {
        return lhs.clicks > rhs.clicks;
    });
    // Trim to the number of columns, as we need just 1 row of favourites
    auto from = sorted_cache.begin() + number;
    auto to = sorted_cache.end();
    sorted_cache.erase(from, to);
    return sorted_cache;
}
