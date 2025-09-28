/****** Sofle custom status screen (both halves) ******/
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
LOG_MODULE_DECLARE(zmk, CONFIG_ZMK_LOG_LEVEL);

#include <zmk/display.h>

#include "widgets/local_battery_status.h"
#include "widgets/modifiers.h"
#include "widgets/bongo_cat.h"
#include "widgets/layer_status.h"
#include "widgets/output_status.h"
#if IS_ENABLED(CONFIG_ZMK_HID_INDICATORS)
#include "widgets/hid_indicators.h"
#endif

static struct zmk_widget_output_status output_status_widget;
static struct zmk_widget_layer_status layer_status_widget;
static struct zmk_widget_local_battery_status local_battery_widget;
static struct zmk_widget_modifiers modifiers_widget;
static struct zmk_widget_bongo_cat bongo_cat_widget;
#if IS_ENABLED(CONFIG_ZMK_HID_INDICATORS)
static struct zmk_widget_hid_indicators hid_indicators_widget;
#endif

lv_obj_t *zmk_display_status_screen() {
    lv_obj_t *screen = lv_obj_create(NULL);

    static lv_style_t global_style; /* static to persist */
    lv_style_init(&global_style);
    lv_style_set_text_font(&global_style, &lv_font_unscii_8);
    lv_style_set_text_letter_space(&global_style, 1);
    lv_style_set_text_line_space(&global_style, 1);
    lv_obj_add_style(screen, &global_style, LV_PART_MAIN);

    zmk_widget_output_status_init(&output_status_widget, screen);
    lv_obj_align(zmk_widget_output_status_obj(&output_status_widget), LV_ALIGN_TOP_LEFT, 0, 0);

    zmk_widget_local_battery_status_init(&local_battery_widget, screen);
    lv_obj_align(zmk_widget_local_battery_status_obj(&local_battery_widget), LV_ALIGN_TOP_RIGHT, 0, 0);

    zmk_widget_bongo_cat_init(&bongo_cat_widget, screen);
    lv_obj_align(zmk_widget_bongo_cat_obj(&bongo_cat_widget), LV_ALIGN_BOTTOM_RIGHT, 0, -7);

    zmk_widget_modifiers_init(&modifiers_widget, screen);
    lv_obj_align(zmk_widget_modifiers_obj(&modifiers_widget), LV_ALIGN_BOTTOM_LEFT, 0, 0);

#if IS_ENABLED(CONFIG_ZMK_HID_INDICATORS)
    zmk_widget_hid_indicators_init(&hid_indicators_widget, screen);
    lv_obj_align_to(zmk_widget_hid_indicators_obj(&hid_indicators_widget), zmk_widget_modifiers_obj(&modifiers_widget), LV_ALIGN_OUT_TOP_LEFT, 0, -2);
#endif

    zmk_widget_layer_status_init(&layer_status_widget, screen);
    lv_obj_align_to(zmk_widget_layer_status_obj(&layer_status_widget), zmk_widget_bongo_cat_obj(&bongo_cat_widget), LV_ALIGN_BOTTOM_LEFT, 0, 5);

    return screen;
}
