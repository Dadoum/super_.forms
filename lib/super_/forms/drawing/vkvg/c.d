module super_.forms.drawing.vkvg.c;

version(VulkanRender):

import core.stdc.stdint;
import erupted;
import super_.forms.utils;
import super_.forms.drawing.vkvg;

__gshared extern(C):

struct vkvg_text_t;
struct vkvg_context_t;
struct vkvg_surface_t;
struct vkvg_device_t;
struct vkvg_pattern_t;

enum Matrix identityMatrix = {1,0,0,1,0,0};

struct Matrix {
    float xx; float yx;
    float xy; float yy;
    float x0; float y0;
}

version (VKVG_static) {
    debug {
        DebugStats vkvg_device_get_stats (vkvg_device_t* dev);
        DebugStats vkvg_device_reset_stats (vkvg_device_t* dev);
    }

    void vkvg_matrix_init_identity (Matrix *matrix);
    void vkvg_matrix_init (Matrix *matrix,
    float xx, float yx,
    float xy, float yy,
    float x0, float y0);
    void vkvg_matrix_init_translate (Matrix *matrix, float tx, float ty);
    void vkvg_matrix_init_scale (Matrix *matrix, float sx, float sy);
    void vkvg_matrix_init_rotate (Matrix *matrix, float radians);
    void vkvg_matrix_translate (Matrix *matrix, float tx, float ty);
    void vkvg_matrix_scale (Matrix *matrix, float sx, float sy);
    void vkvg_matrix_rotate (Matrix *matrix, float radians);
    void vkvg_matrix_multiply (Matrix *result, const Matrix *a, const Matrix *b);
    void vkvg_matrix_transform_distance (const Matrix *matrix, float *dx, float *dy);
    void vkvg_matrix_transform_point (const Matrix *matrix, float *x, float *y);
    Status vkvg_matrix_invert (Matrix *matrix);

    vkvg_device_t* vkvg_device_create (VkSampleCountFlags samples, bool deferredResolve);
    vkvg_device_t* vkvg_device_create_from_vk (VkInstance inst, VkPhysicalDevice phy, VkDevice vkdev, uint32_t qFamIdx, uint32_t qIndex);
    vkvg_device_t* vkvg_device_create_from_vk_multisample (VkInstance inst, VkPhysicalDevice phy, VkDevice vkdev, uint32_t qFamIdx, uint32_t qIndex, VkSampleCountFlags samples, bool deferredResolve);
    void vkvg_device_destroy (vkvg_device_t* dev);
    Status vkvg_device_status (vkvg_device_t* dev);
    vkvg_device_t* vkvg_device_reference (vkvg_device_t* dev);
    uint32_t vkvg_device_get_reference_count (vkvg_device_t* dev);
    void vkvg_device_set_dpy (vkvg_device_t* dev, int hdpy, int vdpy);
    void vkvg_device_get_dpy (vkvg_device_t* dev, int* hdpy, int* vdpy);

    vkvg_surface_t* vkvg_surface_create (vkvg_device_t* dev, uint32_t width, uint32_t height);
    vkvg_surface_t* vkvg_surface_create_from_image (vkvg_device_t* dev, const char* filePath);
    vkvg_surface_t* vkvg_surface_create_for_VkhImage (vkvg_device_t* dev, void* vkhImg);
    vkvg_surface_t* vkvg_surface_reference (vkvg_surface_t* surf);
    uint32_t vkvg_surface_get_reference_count (vkvg_surface_t* surf);
    void vkvg_surface_destroy (vkvg_surface_t* surf);
    void vkvg_surface_clear (vkvg_surface_t* surf);
    VkImage	vkvg_surface_get_vk_image (vkvg_surface_t* surf);
    VkFormat vkvg_surface_get_vk_format (vkvg_surface_t* surf);
    uint32_t vkvg_surface_get_width (vkvg_surface_t* surf);
    uint32_t vkvg_surface_get_height (vkvg_surface_t* surf);
    void vkvg_surface_write_to_png (vkvg_surface_t* surf, const char* path);
    void vkvg_surface_write_to_memory (vkvg_surface_t* surf, const ubyte* bitmap);
    void vkvg_multisample_surface_resolve (vkvg_surface_t* surf);
    vkvg_context_t* vkvg_create (vkvg_surface_t* surf);
    void vkvg_destroy (vkvg_context_t* ctx);
    vkvg_context_t* vkvg_reference (vkvg_context_t* ctx);
    uint32_t vkvg_get_reference_count (vkvg_context_t* ctx);
    void vkvg_flush (vkvg_context_t* ctx);
    void vkvg_new_path (vkvg_context_t* ctx);
    void vkvg_close_path (vkvg_context_t* ctx);
    void vkvg_new_sub_path (vkvg_context_t* ctx);
    void vkvg_path_extents (vkvg_context_t* ctx, float *x1, float *y1, float *x2, float *y2);
    void vkvg_get_current_point (vkvg_context_t* ctx, float* x, float* y);
    void vkvg_line_to (vkvg_context_t* ctx, float x, float y);
    void vkvg_rel_line_to (vkvg_context_t* ctx, float dx, float dy);
    void vkvg_move_to (vkvg_context_t* ctx, float x, float y);
    void vkvg_rel_move_to (vkvg_context_t* ctx, float x, float y);
    void vkvg_arc (vkvg_context_t* ctx, float xc, float yc, float radius, float a1, float a2);
    void vkvg_arc_negative (vkvg_context_t* ctx, float xc, float yc, float radius, float a1, float a2);
    void vkvg_curve_to (vkvg_context_t* ctx, float x1, float y1, float x2, float y2, float x3, float y3);
    void vkvg_rel_curve_to (vkvg_context_t* ctx, float x1, float y1, float x2, float y2, float x3, float y3);
    void vkvg_quadratic_to (vkvg_context_t* ctx, float x1, float y1, float x2, float y2);
    void vkvg_rectangle(vkvg_context_t* ctx, float x, float y, float w, float h);
    void vkvg_stroke (vkvg_context_t* ctx);
    void vkvg_stroke_preserve (vkvg_context_t* ctx);
    void vkvg_fill (vkvg_context_t* ctx);
    void vkvg_fill_preserve (vkvg_context_t* ctx);
    void vkvg_paint (vkvg_context_t* ctx);
    void vkvg_clear (vkvg_context_t* ctx);//use vkClearAttachment to speed up clearing surf
    void vkvg_reset_clip (vkvg_context_t* ctx);
    void vkvg_clip (vkvg_context_t* ctx);
    void vkvg_clip_preserve (vkvg_context_t* ctx);
    void vkvg_set_source_color (vkvg_context_t* ctx, uint32_t c);
    void vkvg_set_source_rgba (vkvg_context_t* ctx, float r, float g, float b, float a);
    void vkvg_set_source_rgb (vkvg_context_t* ctx, float r, float g, float b);
    void vkvg_set_line_width (vkvg_context_t* ctx, float width);
    void vkvg_set_line_cap (vkvg_context_t* ctx, LineCap cap);
    void vkvg_set_line_join (vkvg_context_t* ctx, LineJoin join);
    void vkvg_set_source_surface (vkvg_context_t* ctx, vkvg_surface_t* surf, float x, float y);
    void vkvg_set_source (vkvg_context_t* ctx, vkvg_pattern_t* pat);
    void vkvg_set_operator (vkvg_context_t* ctx, Operator op);
    void vkvg_set_fill_rule (vkvg_context_t* ctx, FillRule fr);
    void vkvg_set_dash (vkvg_context_t* ctx, const float* dashes, uint32_t num_dashes, float offset);
    void vkvg_get_dash (vkvg_context_t* ctx, const float *dashes, uint32_t* num_dashes, float* offset);
    float vkvg_get_line_width (vkvg_context_t* ctx);
    LineCap vkvg_get_line_cap (vkvg_context_t* ctx);
    LineJoin vkvg_get_line_join (vkvg_context_t* ctx);
    Operator vkvg_get_operator (vkvg_context_t* ctx);
    FillRule vkvg_get_fill_rule (vkvg_context_t* ctx);
    vkvg_pattern_t* vkvg_get_source (vkvg_context_t* ctx);
    void vkvg_save (vkvg_context_t* ctx);
    void vkvg_restore (vkvg_context_t* ctx);
    void vkvg_translate (vkvg_context_t* ctx, float dx, float dy);
    void vkvg_scale (vkvg_context_t* ctx, float sx, float sy);
    void vkvg_rotate (vkvg_context_t* ctx, float radians);
    void vkvg_transform (vkvg_context_t* ctx, const Matrix* matrix);
    void vkvg_set_matrix (vkvg_context_t* ctx, const Matrix* matrix);
    void vkvg_get_matrix (vkvg_context_t* ctx, const Matrix* matrix);
    void vkvg_identity_matrix (vkvg_context_t* ctx);
    void vkvg_select_font_face (vkvg_context_t* ctx, const char* name);
    void vkvg_select_font_path (vkvg_context_t* ctx, const char* path);
    void vkvg_set_font_size (vkvg_context_t* ctx, uint32_t size);
    void vkvg_show_text (vkvg_context_t* ctx, const char* text);
    void vkvg_text_extents (vkvg_context_t* ctx, const char* text, TextExtents* extents);
    void vkvg_font_extents (vkvg_context_t* ctx, TextExtents* extents);
    void vkvg_show_text_run (vkvg_context_t* ctx, vkvg_text_t* textRun);
    void vkvg_set_source_color_name (vkvg_context_t* ctx, const char* color);

    vkvg_text_t* vkvg_text_run_create (vkvg_context_t* ctx, const char* text);
    void vkvg_text_run_destroy (vkvg_text_t* textRun);
    void vkvg_text_run_get_extents (vkvg_text_t* textRun, TextExtents* extents);

    vkvg_pattern_t* vkvg_pattern_reference (vkvg_pattern_t* pat);
    uint32_t vkvg_pattern_get_reference_count (vkvg_pattern_t* pat);
    vkvg_pattern_t* vkvg_pattern_create_for_surface (vkvg_surface_t* surf);
    vkvg_pattern_t* vkvg_pattern_create_linear (float x0, float y0, float x1, float y1);
    void vkvg_pattern_edit_linear (vkvg_pattern_t* pat, float x0, float y0, float x1, float y1);
    void vkvg_pattern_get_linear_points (vkvg_pattern_t* pat, float* x0, float* y0, float* x1, float* y1);
    vkvg_pattern_t* vkvg_pattern_create_radial (float cx0, float cy0, float radius0,
    float cx1, float cy1, float radius1);
    void vkvg_pattern_edit_radial (vkvg_pattern_t* pat,
    float cx0, float cy0, float radius0,
    float cx1, float cy1, float radius1);
    void vkvg_pattern_destroy (vkvg_pattern_t* pat);
    void vkvg_pattern_add_color_stop (vkvg_pattern_t* pat, float offset, float r, float g, float b, float a);
    void vkvg_pattern_set_extend (vkvg_pattern_t* pat, Extend extend);
    void vkvg_pattern_set_filter (vkvg_pattern_t* pat, Filter filter);
    Extend vkvg_pattern_get_extend (vkvg_pattern_t* pat);
    Filter vkvg_pattern_get_filter (vkvg_pattern_t* pat);
    PatternType vkvg_pattern_get_type (vkvg_pattern_t* pat);

    bool loadVkvg() {
        return true;
    }
} else {
    debug {
        DebugStats function(vkvg_device_t* dev) vkvg_device_get_stats;
        DebugStats function(vkvg_device_t* dev) vkvg_device_reset_stats;
    }

    void function(Matrix *matrix) vkvg_matrix_init_identity;
    void function   (Matrix *matrix,
                    float xx, float yx,
                    float xy, float yy,
                    float x0, float y0) vkvg_matrix_init;
    void function(Matrix *matrix, float tx, float ty) vkvg_matrix_init_translate;
    void function(Matrix *matrix, float sx, float sy) vkvg_matrix_init_scale;
    void function(Matrix *matrix, float radians) vkvg_matrix_init_rotate;
    void function(Matrix *matrix, float tx, float ty) vkvg_matrix_translate;
    void function(Matrix *matrix, float sx, float sy) vkvg_matrix_scale;
    void function(Matrix *matrix, float radians) vkvg_matrix_rotate;
    void function(Matrix *result, const Matrix *a, const Matrix *b) vkvg_matrix_multiply;
    void function(const Matrix *matrix, float *dx, float *dy) vkvg_matrix_transform_distance;
    void function(const Matrix *matrix, float *x, float *y) vkvg_matrix_transform_point;
    Status function(Matrix *matrix) vkvg_matrix_invert;

    vkvg_device_t* function(VkSampleCountFlags samples, bool deferredResolve) vkvg_device_create;
    vkvg_device_t* function(VkInstance inst, VkPhysicalDevice phy, VkDevice vkdev, uint32_t qFamIdx, uint32_t qIndex) vkvg_device_create_from_vk;
    vkvg_device_t* function(VkInstance inst, VkPhysicalDevice phy, VkDevice vkdev, uint32_t qFamIdx, uint32_t qIndex, VkSampleCountFlags samples, bool deferredResolve) vkvg_device_create_from_vk_multisample;
    void function(vkvg_device_t* dev) vkvg_device_destroy;
    Status function(vkvg_device_t* dev) vkvg_device_status;
    vkvg_device_t* function(vkvg_device_t* dev) vkvg_device_reference;
    uint32_t function(vkvg_device_t* dev) vkvg_device_get_reference_count;
    void function(vkvg_device_t* dev, int hdpy, int vdpy) vkvg_device_set_dpy;
    void function(vkvg_device_t* dev, int* hdpy, int* vdpy) vkvg_device_get_dpy;
    vkvg_surface_t* function(vkvg_device_t* dev, uint32_t width, uint32_t height) vkvg_surface_create;
    vkvg_surface_t* function(vkvg_device_t* dev, const char* filePath) vkvg_surface_create_from_image;
    vkvg_surface_t* function(vkvg_device_t* dev, void* vkhImg) vkvg_surface_create_for_VkhImage;

    vkvg_surface_t* function(vkvg_surface_t* surf) vkvg_surface_reference;
    uint32_t function(vkvg_surface_t* surf) vkvg_surface_get_reference_count;
    void function(vkvg_surface_t* surf) vkvg_surface_destroy;
    void function(vkvg_surface_t* surf) vkvg_surface_clear;
    VkImage	function(vkvg_surface_t* surf) vkvg_surface_get_vk_image;
    VkFormat function(vkvg_surface_t* surf) vkvg_surface_get_vk_format;
    uint32_t function(vkvg_surface_t* surf) vkvg_surface_get_width;
    uint32_t function(vkvg_surface_t* surf) vkvg_surface_get_height;
    void function(vkvg_surface_t* surf, const char* path) vkvg_surface_write_to_png;
    void function(vkvg_surface_t* surf, const ubyte* bitmap) vkvg_surface_write_to_memory;
    void function(vkvg_surface_t* surf) vkvg_multisample_surface_resolve;
    vkvg_context_t* function(vkvg_surface_t* surf) vkvg_create;

    void function(vkvg_context_t* ctx) vkvg_destroy;
    vkvg_context_t* function(vkvg_context_t* ctx) vkvg_reference;
    vkvg_pattern_t* function(vkvg_context_t* ctx) vkvg_get_source;
    uint32_t function(vkvg_context_t* ctx) vkvg_get_reference_count;
    void function(vkvg_context_t* ctx) vkvg_flush;
    void function(vkvg_context_t* ctx) vkvg_new_path;
    void function(vkvg_context_t* ctx) vkvg_close_path;
    void function(vkvg_context_t* ctx) vkvg_new_sub_path;
    void function(vkvg_context_t* ctx, float *x1, float *y1, float *x2, float *y2) vkvg_path_extents;
    void function(vkvg_context_t* ctx, float* x, float* y) vkvg_get_current_point;
    void function(vkvg_context_t* ctx, float x, float y) vkvg_line_to;
    void function(vkvg_context_t* ctx, float dx, float dy) vkvg_rel_line_to;
    void function(vkvg_context_t* ctx, float x, float y) vkvg_move_to;
    void function(vkvg_context_t* ctx, float x, float y) vkvg_rel_move_to;
    void function(vkvg_context_t* ctx, float xc, float yc, float radius, float a1, float a2) vkvg_arc;
    void function(vkvg_context_t* ctx, float xc, float yc, float radius, float a1, float a2) vkvg_arc_negative;
    void function(vkvg_context_t* ctx, float x1, float y1, float x2, float y2, float x3, float y3) vkvg_curve_to;
    void function(vkvg_context_t* ctx, float x1, float y1, float x2, float y2, float x3, float y3) vkvg_rel_curve_to;
    void function(vkvg_context_t* ctx, float x1, float y1, float x2, float y2) vkvg_quadratic_to;
    void function(vkvg_context_t* ctx, float x, float y, float w, float h) vkvg_rectangle;
    void function(vkvg_context_t* ctx) vkvg_stroke;
    void function(vkvg_context_t* ctx) vkvg_stroke_preserve;
    void function(vkvg_context_t* ctx) vkvg_fill;
    void function(vkvg_context_t* ctx) vkvg_fill_preserve;
    void function(vkvg_context_t* ctx) vkvg_paint;
    void function(vkvg_context_t* ctx) vkvg_clear;//use vkClearAttachment to speed up clearing surf
    void function(vkvg_context_t* ctx) vkvg_reset_clip;
    void function(vkvg_context_t* ctx) vkvg_clip;
    void function(vkvg_context_t* ctx) vkvg_clip_preserve;
    void function(vkvg_context_t* ctx, uint32_t c) vkvg_set_source_color;
    void function(vkvg_context_t* ctx, float r, float g, float b, float a) vkvg_set_source_rgba;
    void function(vkvg_context_t* ctx, float r, float g, float b) vkvg_set_source_rgb;
    void function(vkvg_context_t* ctx, float width) vkvg_set_line_width;
    void function(vkvg_context_t* ctx, LineCap cap) vkvg_set_line_cap;
    void function(vkvg_context_t* ctx, LineJoin join) vkvg_set_line_join;
    void function(vkvg_context_t* ctx, vkvg_surface_t* surf, float x, float y) vkvg_set_source_surface;
    void function(vkvg_context_t* ctx, vkvg_pattern_t* pat) vkvg_set_source;
    void function(vkvg_context_t* ctx, Operator op) vkvg_set_operator;
    void function(vkvg_context_t* ctx, FillRule fr) vkvg_set_fill_rule;
    void function(vkvg_context_t* ctx, const float* dashes, uint32_t num_dashes, float offset) vkvg_set_dash;
    void function(vkvg_context_t* ctx, const float *dashes, uint32_t* num_dashes, float* offset) vkvg_get_dash;
    float function(vkvg_context_t* ctx) vkvg_get_line_width;
    LineCap function(vkvg_context_t* ctx) vkvg_get_line_cap;
    LineJoin function(vkvg_context_t* ctx) vkvg_get_line_join;
    Operator function(vkvg_context_t* ctx) vkvg_get_operator;
    FillRule function(vkvg_context_t* ctx) vkvg_get_fill_rule;
    void function(vkvg_context_t* ctx) vkvg_save;
    void function(vkvg_context_t* ctx) vkvg_restore;
    void function(vkvg_context_t* ctx, float dx, float dy) vkvg_translate;
    void function(vkvg_context_t* ctx, float sx, float sy) vkvg_scale;
    void function(vkvg_context_t* ctx, float radians) vkvg_rotate;
    void function(vkvg_context_t* ctx, const Matrix* matrix) vkvg_transform;
    void function(vkvg_context_t* ctx, const Matrix* matrix) vkvg_set_matrix;
    void function(vkvg_context_t* ctx, const Matrix* matrix) vkvg_get_matrix;
    void function(vkvg_context_t* ctx) vkvg_identity_matrix;
    void function(vkvg_context_t* ctx, const char* name) vkvg_select_font_face;
    void function(vkvg_context_t* ctx, const char* path) vkvg_select_font_path;
    void function(vkvg_context_t* ctx, uint32_t size) vkvg_set_font_size;
    void function(vkvg_context_t* ctx, const char* text) vkvg_show_text;
    void function(vkvg_context_t* ctx, const char* text, TextExtents* extents) vkvg_text_extents;
    void function(vkvg_context_t* ctx, TextExtents* extents) vkvg_font_extents;
    void function(vkvg_context_t* ctx, vkvg_text_t* textRun) vkvg_show_text_run;
    void function(vkvg_context_t* ctx, const char* color) vkvg_set_source_color_name;
    vkvg_text_t* function(vkvg_context_t* ctx, const char* text) vkvg_text_run_create;

    void function(vkvg_text_t* textRun) vkvg_text_run_destroy;
    void function(vkvg_text_t* textRun, TextExtents* extents) vkvg_text_run_get_extents;

    vkvg_pattern_t* function(vkvg_pattern_t* pat) vkvg_pattern_reference;
    uint32_t function(vkvg_pattern_t* pat) vkvg_pattern_get_reference_count;
    vkvg_pattern_t* function(vkvg_surface_t* surf) vkvg_pattern_create_for_surface;
    vkvg_pattern_t* function(float x0, float y0, float x1, float y1) vkvg_pattern_create_linear;
    void function(vkvg_pattern_t* pat, float x0, float y0, float x1, float y1) vkvg_pattern_edit_linear;
    void function(vkvg_pattern_t* pat, float* x0, float* y0, float* x1, float* y1) vkvg_pattern_get_linear_points;
    vkvg_pattern_t* function(float cx0, float cy0, float radius0, float cx1, float cy1, float radius1) vkvg_pattern_create_radial;
    void function(vkvg_pattern_t* pat, float cx0, float cy0, float radius0, float cx1, float cy1, float radius1) vkvg_pattern_edit_radial;
    void function(vkvg_pattern_t* pat) vkvg_pattern_destroy;
    void function(vkvg_pattern_t* pat, float offset, float r, float g, float b, float a) vkvg_pattern_add_color_stop;
    void function(vkvg_pattern_t* pat, Extend extend) vkvg_pattern_set_extend;
    void function(vkvg_pattern_t* pat, Filter filter) vkvg_pattern_set_filter;
    Extend function(vkvg_pattern_t* pat) vkvg_pattern_get_extend;
    Filter function(vkvg_pattern_t* pat) vkvg_pattern_get_filter;
    PatternType function(vkvg_pattern_t* pat) vkvg_pattern_get_type;

    Library vkvgLibraryHandle;
    bool loadVkvg() {
        import core.runtime;
        vkvgLibraryHandle = LibraryLoader.loadLibrary!"vkvg"();
        if (!vkvgLibraryHandle) {
            return false;
        }

        debug {
            vkvg_device_get_stats = cast(typeof(vkvg_device_get_stats)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_get_stats");
            vkvg_device_reset_stats = cast(typeof(vkvg_device_reset_stats)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_reset_stats");
        }

        vkvg_matrix_init_identity = cast(typeof(vkvg_matrix_init_identity)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_init_identity");
        vkvg_matrix_init_translate = cast(typeof(vkvg_matrix_init_translate)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_init_translate");
        vkvg_matrix_init_scale = cast(typeof(vkvg_matrix_init_scale)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_init_scale");
        vkvg_matrix_init_rotate = cast(typeof(vkvg_matrix_init_rotate)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_init_rotate");
        vkvg_matrix_translate = cast(typeof(vkvg_matrix_translate)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_translate");
        vkvg_matrix_scale = cast(typeof(vkvg_matrix_scale)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_scale");
        vkvg_matrix_rotate = cast(typeof(vkvg_matrix_rotate)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_rotate");
        vkvg_matrix_multiply = cast(typeof(vkvg_matrix_multiply)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_multiply");
        vkvg_matrix_transform_distance = cast(typeof(vkvg_matrix_transform_distance)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_transform_distance");
        vkvg_matrix_transform_point = cast(typeof(vkvg_matrix_transform_point)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_transform_point");
        vkvg_matrix_invert = cast(typeof(vkvg_matrix_invert)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_matrix_invert");

        vkvg_device_create = cast(typeof(vkvg_device_create)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_create");
        vkvg_device_create_from_vk = cast(typeof(vkvg_device_create_from_vk)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_create_from_vk");
        vkvg_device_create_from_vk_multisample = cast(typeof(vkvg_device_create_from_vk_multisample)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_create_from_vk_multisample");
        vkvg_device_destroy = cast(typeof(vkvg_device_destroy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_destroy");
        vkvg_device_status = cast(typeof(vkvg_device_status)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_status");
        vkvg_device_reference = cast(typeof(vkvg_device_reference)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_reference");
        vkvg_device_get_reference_count = cast(typeof(vkvg_device_get_reference_count)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_get_reference_count");
        vkvg_device_set_dpy = cast(typeof(vkvg_device_set_dpy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_set_dpy");
        vkvg_device_get_dpy = cast(typeof(vkvg_device_get_dpy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_device_get_dpy");

        vkvg_surface_create = cast(typeof(vkvg_surface_create)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_create");
        vkvg_surface_create_from_image = cast(typeof(vkvg_surface_create_from_image)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_create_from_image");
        vkvg_surface_create_for_VkhImage = cast(typeof(vkvg_surface_create_for_VkhImage)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_create_for_VkhImage");
        vkvg_surface_reference = cast(typeof(vkvg_surface_reference)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_reference");
        vkvg_surface_get_reference_count = cast(typeof(vkvg_surface_get_reference_count)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_get_reference_count");
        vkvg_surface_destroy = cast(typeof(vkvg_surface_destroy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_destroy");
        vkvg_surface_clear = cast(typeof(vkvg_surface_clear)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_clear");
        vkvg_surface_get_vk_image = cast(typeof(vkvg_surface_get_vk_image)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_get_vk_image");
        vkvg_surface_get_vk_format = cast(typeof(vkvg_surface_get_vk_format)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_get_vk_format");
        vkvg_surface_get_width = cast(typeof(vkvg_surface_get_width)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_get_width");
        vkvg_surface_get_height = cast(typeof(vkvg_surface_get_height)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_get_height");
        vkvg_surface_write_to_png = cast(typeof(vkvg_surface_write_to_png)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_write_to_png");
        vkvg_surface_write_to_memory = cast(typeof(vkvg_surface_write_to_memory)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_surface_write_to_memory");
        vkvg_multisample_surface_resolve = cast(typeof(vkvg_multisample_surface_resolve)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_multisample_surface_resolve");

        vkvg_create = cast(typeof(vkvg_create)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_create");
        vkvg_destroy = cast(typeof(vkvg_destroy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_destroy");
        vkvg_reference = cast(typeof(vkvg_reference)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_reference");
        vkvg_get_source = cast(typeof(vkvg_get_source)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_source");
        vkvg_get_reference_count = cast(typeof(vkvg_get_reference_count)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_reference_count");
        vkvg_flush = cast(typeof(vkvg_flush)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_flush");
        vkvg_new_path = cast(typeof(vkvg_new_path)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_new_path");
        vkvg_close_path = cast(typeof(vkvg_close_path)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_close_path");
        vkvg_new_sub_path = cast(typeof(vkvg_new_sub_path)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_new_sub_path");
        vkvg_path_extents = cast(typeof(vkvg_path_extents)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_path_extents");
        vkvg_get_current_point = cast(typeof(vkvg_get_current_point)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_current_point");
        vkvg_line_to = cast(typeof(vkvg_line_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_line_to");
        vkvg_rel_line_to = cast(typeof(vkvg_rel_line_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_rel_line_to");
        vkvg_move_to = cast(typeof(vkvg_move_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_move_to");
        vkvg_rel_move_to = cast(typeof(vkvg_rel_move_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_rel_move_to");
        vkvg_arc = cast(typeof(vkvg_arc)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_arc");
        vkvg_arc_negative = cast(typeof(vkvg_arc_negative)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_arc_negative");
        vkvg_curve_to = cast(typeof(vkvg_curve_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_curve_to");
        vkvg_rel_curve_to = cast(typeof(vkvg_rel_curve_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_rel_curve_to");
        vkvg_quadratic_to = cast(typeof(vkvg_quadratic_to)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_quadratic_to");
        vkvg_rectangle = cast(typeof(vkvg_rectangle)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_rectangle");
        vkvg_stroke = cast(typeof(vkvg_stroke)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_stroke");
        vkvg_stroke_preserve = cast(typeof(vkvg_stroke_preserve)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_stroke_preserve");
        vkvg_fill = cast(typeof(vkvg_fill)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_fill");
        vkvg_fill_preserve = cast(typeof(vkvg_fill_preserve)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_fill_preserve");
        vkvg_paint = cast(typeof(vkvg_paint)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_paint");
        vkvg_clear = cast(typeof(vkvg_clear)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_clear");
        vkvg_reset_clip = cast(typeof(vkvg_reset_clip)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_reset_clip");
        vkvg_clip = cast(typeof(vkvg_clip)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_clip");
        vkvg_clip_preserve = cast(typeof(vkvg_clip_preserve)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_clip_preserve");
        vkvg_set_source_color = cast(typeof(vkvg_set_source_color)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_source_color");
        vkvg_set_source_rgba = cast(typeof(vkvg_set_source_rgba)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_source_rgba");
        vkvg_set_source_rgb = cast(typeof(vkvg_set_source_rgb)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_source_rgb");
        vkvg_set_line_width = cast(typeof(vkvg_set_line_width)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_line_width");
        vkvg_set_line_cap = cast(typeof(vkvg_set_line_cap)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_line_cap");
        vkvg_set_line_join = cast(typeof(vkvg_set_line_join)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_line_join");
        vkvg_set_source_surface = cast(typeof(vkvg_set_source_surface)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_source_surface");
        vkvg_set_source = cast(typeof(vkvg_set_source)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_source");
        vkvg_set_operator = cast(typeof(vkvg_set_operator)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_operator");
        vkvg_set_fill_rule = cast(typeof(vkvg_set_fill_rule)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_fill_rule");
        vkvg_set_dash = cast(typeof(vkvg_set_dash)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_dash");
        vkvg_get_dash = cast(typeof(vkvg_get_dash)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_dash");
        vkvg_get_line_width = cast(typeof(vkvg_get_line_width)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_line_width");
        vkvg_get_line_cap = cast(typeof(vkvg_get_line_cap)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_line_cap");
        vkvg_get_line_join = cast(typeof(vkvg_get_line_join)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_line_join");
        vkvg_get_operator = cast(typeof(vkvg_get_operator)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_operator");
        vkvg_get_fill_rule = cast(typeof(vkvg_get_fill_rule)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_fill_rule");
        vkvg_save = cast(typeof(vkvg_save)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_save");
        vkvg_restore = cast(typeof(vkvg_restore)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_restore");
        vkvg_translate = cast(typeof(vkvg_translate)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_translate");
        vkvg_scale = cast(typeof(vkvg_scale)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_scale");
        vkvg_rotate = cast(typeof(vkvg_rotate)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_rotate");
        vkvg_transform = cast(typeof(vkvg_transform)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_transform");
        vkvg_set_matrix = cast(typeof(vkvg_set_matrix)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_matrix");
        vkvg_get_matrix = cast(typeof(vkvg_get_matrix)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_get_matrix");
        vkvg_identity_matrix = cast(typeof(vkvg_identity_matrix)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_identity_matrix");
        vkvg_select_font_face = cast(typeof(vkvg_select_font_face)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_select_font_face");
        vkvg_select_font_path = cast(typeof(vkvg_select_font_path)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_select_font_path");
        vkvg_set_font_size = cast(typeof(vkvg_set_font_size)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_font_size");
        vkvg_show_text = cast(typeof(vkvg_show_text)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_show_text");
        vkvg_text_extents = cast(typeof(vkvg_text_extents)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_text_extents");
        vkvg_font_extents = cast(typeof(vkvg_font_extents)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_font_extents");
        vkvg_show_text_run = cast(typeof(vkvg_show_text_run)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_show_text_run");
        vkvg_set_source_color_name = cast(typeof(vkvg_set_source_color_name)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_set_source_color_name");

        vkvg_text_run_create = cast(typeof(vkvg_text_run_create)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_text_run_create");
        vkvg_text_run_destroy = cast(typeof(vkvg_text_run_destroy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_text_run_destroy");
        vkvg_text_run_get_extents = cast(typeof(vkvg_text_run_get_extents)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_text_run_get_extents");

        vkvg_pattern_reference = cast(typeof(vkvg_pattern_reference)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_reference");
        vkvg_pattern_get_reference_count = cast(typeof(vkvg_pattern_get_reference_count)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_get_reference_count");
        vkvg_pattern_create_for_surface = cast(typeof(vkvg_pattern_create_for_surface)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_create_for_surface");
        vkvg_pattern_create_linear = cast(typeof(vkvg_pattern_create_linear)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_create_linear");
        vkvg_pattern_edit_linear = cast(typeof(vkvg_pattern_edit_linear)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_edit_linear");
        vkvg_pattern_get_linear_points = cast(typeof(vkvg_pattern_get_linear_points)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_get_linear_points");
        vkvg_pattern_create_radial = cast(typeof(vkvg_pattern_create_radial)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_create_radial");
        vkvg_pattern_edit_radial = cast(typeof(vkvg_pattern_edit_radial)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_edit_radial");
        vkvg_pattern_destroy = cast(typeof(vkvg_pattern_destroy)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_destroy");
        vkvg_pattern_add_color_stop = cast(typeof(vkvg_pattern_add_color_stop)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_add_color_stop");
        vkvg_pattern_set_extend = cast(typeof(vkvg_pattern_set_extend)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_set_extend");
        vkvg_pattern_set_filter = cast(typeof(vkvg_pattern_set_filter)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_set_filter");
        vkvg_pattern_get_extend = cast(typeof(vkvg_pattern_get_extend)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_get_extend");
        vkvg_pattern_get_filter = cast(typeof(vkvg_pattern_get_filter)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_get_filter");
        vkvg_pattern_get_type = cast(typeof(vkvg_pattern_get_type)) LibraryLoader.loadSymbol(vkvgLibraryHandle, "vkvg_pattern_get_type");
        return true;
    }

    void unloadVkvg() {
        LibraryLoader.unloadLibrary(vkvgLibraryHandle);
    }
}
