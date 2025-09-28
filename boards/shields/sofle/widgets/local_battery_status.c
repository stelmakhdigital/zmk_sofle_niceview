#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
LOG_MODULE_DECLARE(zmk, CONFIG_ZMK_LOG_LEVEL);

#include <zmk/display.h>
#include <zmk/battery.h>
#include <zmk/events/battery_state_changed.h>
#include <zmk/event_manager.h>
#include <zmk/usb.h>
#if IS_ENABLED(CONFIG_USB_DEVICE_STACK)
#include <zmk/events/usb_conn_state_changed.h>
#endif

#include "local_battery_status.h"

struct local_batt_state {
    uint8_t level;
    bool usb_present;
};

static sys_slist_t widgets = SYS_SLIST_STATIC_INIT(&widgets);
static lv_color_t battery_image_buffer[5 * 8]; /* 5x8 canvas */

static void draw_battery(lv_obj_t *canvas, uint8_t level, bool usb_present) {
    lv_canvas_fill_bg(canvas, lv_color_black(), LV_OPA_COVER);

    lv_draw_rect_dsc_t rect_fill_dsc; 
    lv_draw_rect_dsc_init(&rect_fill_dsc);

    if (usb_present) {
        rect_fill_dsc.bg_opa = LV_OPA_TRANSP;
        rect_fill_dsc.border_color = lv_color_white();
        rect_fill_dsc.border_width = 1; /* рамка при USB */
    }

    /* Контуры контактов */
    lv_canvas_set_px(canvas, 0, 0, lv_color_white());
    lv_canvas_set_px(canvas, 4, 0, lv_color_white());

    /* Столбик индикатора (заполняем снизу вверх по 1 строке) */
    uint8_t segs = 0;
    if (level <= 10 || usb_present) segs = 5; /* всегда показываем рамку пустой при низком уровне или USB */
    else if (level <= 30) segs = 4;
    else if (level <= 50) segs = 3;
    else if (level <= 70) segs = 2;
    else if (level <= 90) segs = 1;
    /* >90 оставляем только крышку (полностью заряжено) */

    /* Преобразуем segs в высоту начиная с y=2 вниз */
    if (segs > 0) {
        lv_canvas_draw_rect(canvas, 1, 2, 3, segs, &rect_fill_dsc);
    } else if (usb_present) {
        /* Пустая рамка уже нарисована */
    }
}

static void apply_state(struct zmk_widget_local_battery_status *widget, struct local_batt_state st) {
    draw_battery(widget->canvas, st.level, st.usb_present);
    lv_label_set_text_fmt(widget->label, "%3u%%", st.level);
}

static void local_batt_update_cb(struct local_batt_state st) {
    struct zmk_widget_local_battery_status *w;
    SYS_SLIST_FOR_EACH_CONTAINER(&widgets, w, node) { apply_state(w, st); }
}

static struct local_batt_state local_batt_get_state(const zmk_event_t *eh) {
    const struct zmk_battery_state_changed *ev = as_zmk_battery_state_changed(eh);
    uint8_t lvl = ev ? ev->state_of_charge : zmk_battery_state_of_charge();
    struct local_batt_state st = { .level = lvl, .usb_present = false };
#if IS_ENABLED(CONFIG_USB_DEVICE_STACK)
    st.usb_present = zmk_usb_is_powered();
#endif
    return st;
}

ZMK_DISPLAY_WIDGET_LISTENER(widget_local_battery_status, struct local_batt_state,
                            local_batt_update_cb, local_batt_get_state)
ZMK_SUBSCRIPTION(widget_local_battery_status, zmk_battery_state_changed);
#if IS_ENABLED(CONFIG_USB_DEVICE_STACK)
ZMK_SUBSCRIPTION(widget_local_battery_status, zmk_usb_conn_state_changed);
#endif

int zmk_widget_local_battery_status_init(struct zmk_widget_local_battery_status *widget, lv_obj_t *parent) {
    widget->obj = lv_obj_create(parent);
    lv_obj_set_size(widget->obj, LV_SIZE_CONTENT, LV_SIZE_CONTENT);

    widget->canvas = lv_canvas_create(widget->obj);
    lv_canvas_set_buffer(widget->canvas, battery_image_buffer, 5, 8, LV_IMG_CF_TRUE_COLOR);
    lv_obj_align(widget->canvas, LV_ALIGN_TOP_RIGHT, 0, 0);

    widget->label = lv_label_create(widget->obj);
    lv_obj_align(widget->label, LV_ALIGN_TOP_RIGHT, -7, 0);

    sys_slist_append(&widgets, &widget->node);
    widget_local_battery_status_init();

    return 0;
}

lv_obj_t *zmk_widget_local_battery_status_obj(struct zmk_widget_local_battery_status *widget) {
    return widget->obj;
}
