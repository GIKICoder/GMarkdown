#ifndef SYNTECT_H
#define SYNTECT_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// FFI-safe structure for style ranges
typedef struct {
    size_t start;
    size_t end;
    uint32_t foreground; // RGBA color
    uint32_t background; // RGBA color
    uint32_t font_style; // 0=normal, 1=bold, 2=italic, 3=underline
} StyleRange;

// FFI-safe structure for highlighting results
typedef struct {
    char *text;
    StyleRange *ranges;
    size_t range_count;
} HighlightResult;

// Initialize syntect with embedded resources
bool syntect_initialize(void);

// Enhanced highlight with real syntax definitions
HighlightResult *syntect_highlight_fast(const char *text, const char *syntax, const char *theme);

// Get syntax by extension
char *syntect_get_syntax_by_extension(const char *extension);

// Get syntax names
char **syntect_get_syntax_names(void);

// Get theme names
char **syntect_get_theme_names(void);

// Clear cache
void syntect_clear_cache(void);

// Get cache size
size_t syntect_cache_size(void);

// Free highlight result
void syntect_highlight_result_free(HighlightResult *result);

// Free string array
void syntect_free_string_array(char **strings);

#ifdef __cplusplus
}
#endif

#endif // SYNTECT_H