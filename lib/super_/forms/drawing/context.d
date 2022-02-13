module super_.forms.drawing.context;

import std.string;
import super_.forms.drawing;

class Context/+(bool hardwareAccelerated)+/ {
    // static if (hardwareAccelerated) {
        package(super_.forms.drawing) vkvg_context_t* handle;
    //} else {
    //    package(super_.forms.drawing) cairo_t* handle;
    //}

    private bool owned = false;

    this(Surface s) {
        // static if (hardwareAccelerated) {
            handle = vkvg_create(s.handle);
        //} else {
        //    handle = cairo_create(s.handle);
        //}

        owned = true;
    }

    ~this() {
        if (owned) {
            // static if (hardwareAccelerated) {
                vkvg_destroy(handle);
            //} else {
            //    cairo_destroy(handle);
            //}
        }
    }

    void flush() {
        // static if (hardwareAccelerated) {
            vkvg_flush(handle);
        //} else {
        //    cairo_flush(handle);
        //}
    }

    void newPath() {
        // static if (hardwareAccelerated) {
            vkvg_new_path(handle);
        //} else {
        //    cairo_new_path(handle);
        //}
    }

    void closePath() {
        // static if (hardwareAccelerated) {
            vkvg_close_path(handle);
        //} else {
        //    cairo_close_path(handle);
        //}
    }

    void newSubPath() {
        // static if (hardwareAccelerated) {
            vkvg_new_sub_path(handle);
        //} else {
        //    cairo_new_sub_path(handle);
        //}
    }

    void pathExtents(out float x1, out float y1, out float x2, out float y2) {
        // static if (hardwareAccelerated) {
            vkvg_path_extents(handle, &x1, &y1, &x2, &y2);
        //} else {
        //    cairo_path_extents(handle, &x1, &y1, &x2, &y2);
        //}
    }

    @property void currentPoint(out float x, out float y) {
        // static if (hardwareAccelerated) {
            vkvg_get_current_point(handle, &x, &y);
        //} else {
        //    cairo_get_current_point(handle, &x, &y);
        //}
    }

    void lineTo(float x, float y) {
        // static if (hardwareAccelerated) {
            vkvg_line_to(handle, x, y);
        //} else {
        //    cairo_line_to(handle, x, y);
        //}
    }

    void relLineTo(float dx, float dy) {
        // static if (hardwareAccelerated) {
            vkvg_rel_line_to(handle, dx, dy);
        //} else {
        //    cairo_rel_line_to(handle, dx, dy);
        //}
    }

    void moveTo(float x, float y) {
        // static if (hardwareAccelerated) {
            vkvg_move_to(handle, x, y);
        //} else {
        //    cairo_move_to(handle, x, y);
        //}
    }

    void relMoveTo(float x, float y) {
        // static if (hardwareAccelerated) {
            vkvg_rel_move_to(handle, x, y);
        //} else {
        //    cairo_rel_move_to(handle, x, y);
        //}
    }

    void arc(float xc, float yc, float radius, float a1, float a2) {
        // static if (hardwareAccelerated) {
            vkvg_arc(handle, xc, yc, radius, a1, a2);
        //} else {
        //    cairo_arc(handle, xc, yc, radius, a1, a2);
        //}
    }

    void arcNegative(float xc, float yc, float radius, float a1, float a2) {
        // static if (hardwareAccelerated) {
            vkvg_arc_negative(handle, xc, yc, radius, a1, a2);
        //} else {
        //    cairo_arc_negative(handle, xc, yc, radius, a1, a2);
        //}
    }

    void curveTo(float x1, float y1, float x2, float y2, float x3, float y3) {
        // static if (hardwareAccelerated) {
            vkvg_curve_to(handle, x1, y1, x2, y2, x3, y3);
        //} else {
        //    cairo_curve_to(handle, x1, y1, x2, y2, x3, y3);
        //}
    }

    void relCurveTo(float x1, float y1, float x2, float y2, float x3, float y3) {
        // static if (hardwareAccelerated) {
            vkvg_rel_curve_to(handle, x1, y1, x2, y2, x3, y3);
        //} else {
        //    cairo_rel_curve_to(handle, x1, y1, x2, y2, x3, y3);
        //}
    }

    void quadraticTo(float x1, float y1, float x2, float y2) {
        // static if (hardwareAccelerated) {
            vkvg_quadratic_to(handle, x1, y1, x2, y2);
        //} else {
        //    cairo_quadratic_to(handle, x1, y1, x2, y2);
        //}
    }

    void rectangle(float x, float y, float w, float h) {
        // static if (hardwareAccelerated) {
            vkvg_rectangle(handle, x, y, w, h);
        //} else {
        //    cairo_rectangle(handle, x, y, w, h);
        //}
    }

    void stroke() {
        // static if (hardwareAccelerated) {
            vkvg_stroke(handle);
        //} else {
        //    cairo_stroke(handle);
        //}
    }

    void strokePreserve() {
        // static if (hardwareAccelerated) {
            vkvg_stroke_preserve(handle);
        //} else {
        //    cairo_stroke_preserve(handle);
        //}
    }

    void fill() {
        // static if (hardwareAccelerated) {
            vkvg_fill(handle);
        //} else {
        //    cairo_fill(handle);
        //}
    }

    void fillPreserve() {
        // static if (hardwareAccelerated) {
            vkvg_fill_preserve(handle);
        //} else {
        //    cairo_fill_preserve(handle);
        //}
    }

    void paint() {
        // static if (hardwareAccelerated) {
            vkvg_paint(handle);
        //} else {
        //    cairo_paint(handle);
        //}
    }

    void clear() {
        // static if (hardwareAccelerated) {
            vkvg_clear(handle);
        //} else {
        //    cairo_clear(handle);
        //}
    }

    void resetClip() {
        // static if (hardwareAccelerated) {
            vkvg_reset_clip(handle);
        //} else {
        //    cairo_reset_clip(handle);
        //}
    }

    void clip() {
        // static if (hardwareAccelerated) {
            vkvg_clip(handle);
        //} else {
        //    cairo_clip(handle);
        //}
    }

    void clipPreserve() {
        // static if (hardwareAccelerated) {
            vkvg_clip_preserve(handle);
        //} else {
        //    cairo_clip_preserve(handle);
        //}
    }

    void setSourceColor(uint c) {
        // static if (hardwareAccelerated) {
            vkvg_set_source_color(handle, c);
        //} else {
        //    cairo_set_source_color(handle, c);
        //}
    }

    void setSourceRgba(float r, float g, float b, float a) {
        // static if (hardwareAccelerated) {
            vkvg_set_source_rgba(handle, r, g, b, a);
        //} else {
        //    cairo_set_source_rgba(handle, r, g, b, a);
        //}
    }

    void setSourceRgb(float r, float g, float b) {
        // static if (hardwareAccelerated) {
            vkvg_set_source_rgb(handle, r, g, b);
        //} else {
        //    cairo_set_source_rgb(handle, r, g, b);
        //}
    }

    void setLineWidth(float width) {
        // static if (hardwareAccelerated) {
            vkvg_set_line_width(handle, width);
        //} else {
        //    cairo_set_line_width(handle, width);
        //}
    }

    void setLineCap(LineCap cap) {
        // static if (hardwareAccelerated) {
            vkvg_set_line_cap(handle, cap);
        //} else {
        //    cairo_set_line_cap(handle);
        //}
    }

    void setLineJoin(LineJoin join) {
        // static if (hardwareAccelerated) {
            vkvg_set_line_join(handle, join);
        //} else {
        //    cairo_set_line_join(handle, join);
        //}
    }

    void setSourceSurface(Surface surf, float x, float y) {
        // static if (hardwareAccelerated) {
            vkvg_set_source_surface(handle, surf.handle, x, y);
        //} else {
        //    cairo_set_source_surface(handle, surf.handle, x, y);
        //}
    }

    //void setSource (Pattern pat) { // todo pattern
    //    // static if (hardwareAccelerated) {
    //        vkvg_set_source(handle, pat.handle);
    //    //} else {
    //        cairo_set_source(handle, pat.handle);
    //    }
    //}

    void setOperator(Operator op) {
        // static if (hardwareAccelerated) {
            vkvg_set_operator(handle, op);
        //} else {
        //    cairo_set_operator(handle, op);
        //}
    }

    void setFillRule(FillRule fr) {
        // static if (hardwareAccelerated) {
            vkvg_set_fill_rule(handle, fr);
        //} else {
        //    cairo_set_fill_rule(handle, fr);
        //}
    }

    @property void dash(float[] dashes, float offset) {
        // static if (hardwareAccelerated) {
            vkvg_set_dash(handle, dashes.ptr, cast(uint) dashes.length, offset);
        //} else {
        //    cairo_set_dash(handle, dashes.ptr, cast(uint) dashes.length, offset);
        //}
    }

    @property void dash(out const(float)[] dashes, out float offset) {
        const(float*) dash;
        uint cnt;
        // static if (hardwareAccelerated) {
            vkvg_get_dash(handle, dash, &cnt, &offset);
        //} else {
        //    cairo_get_dash(handle, dash, &cnt, &offset);
        //}

        dashes = dash[0 .. cnt];
    }
    //
    //float getLineWidth () {
    //
    //}
    //
    //LineCap getLineCap () {
    //
    //}
    //
    //LineJoin getLineJoin () {
    //
    //}
    //
    //Operator getOperator () {
    //
    //}
    //
    //FillRule getFillRule () {
    //
    //}
    //
    //Pattern getSource () {
    //
    //}
    //
    //void save () {
    //
    //}
    //
    //void restore () {
    //
    //}
    //
    //void translate (float dx, float dy) {
    //
    //}
    //
    //void scale (float sx, float sy) {
    //
    //}
    //
    //void rotate (float radians) {
    //
    //}
    //
    //void transform (const Matrix* matrix) {
    //
    //}
    //
    //void setMatrix (const Matrix* matrix) {
    //
    //}
    //
    //void getMatrix (const Matrix* matrix) {
    //
    //}
    //
    //void identityMatrix () {
    //
    //}
    //
    //void selectFontFace (string name) {
    //
    //}
    //
    //void selectFontPath (string path) {
    //
    //}
    //
    //void setFontSize (uint32_t size) {
    //
    //}
    //
    //void showText (string text) {
    //
    //}
    //
    //void textExtents (string text, TextExtents* extents) {
    //
    //}
    //
    //void fontExtents (TextExtents* extents) {
    //
    //}
    //
    //Text textRunCreate (string text) {
    //
    //}
    //
    //void textRunDestroy () {
    //
    //}
    //
    //void showTextRun (vkvg_text_t* textRun) {
    //
    //}
    //
    //void setSourceColorName (string color) {
    //
    //}
}
