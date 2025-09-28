#pragma once
#include <lvgl.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/slist.h>

struct zmk_widget_local_battery_status {
    sys_snode_t node;
    lv_obj_t *obj;        /* контейнер */
    lv_obj_t *canvas;     /* иконка батареи */
    lv_obj_t *label;      /* текст процента */
};

int zmk_widget_local_battery_status_init(struct zmk_widget_local_battery_status *widget, lv_obj_t *parent);
lv_obj_t *zmk_widget_local_battery_status_obj(struct zmk_widget_local_battery_status *widget);
