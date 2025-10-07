.EXPORT_ALL_VARIABLES:
.PHONY: build clean source

PROJECT ?= zmk_sofle_niceview
BASE_DIR := ${PWD}
ZMK_APP_DIR ?= zmk/app
ZEPHYR_DIR ?= ${PWD}/zephyr
FIREWARE_DIR ?= firmware

DZMK_CONFIG="${PWD}/config"
DSHIELD_LEFT ?= azoteq_sofle_left
DSHIELD_RIGHT ?= azoteq_sofle_right
DSHIELD_DONGLE ?= azoteq_sofle_dongle

MAIN_BOARD ?= nice_nano_v2

# Добавляем пути к кастомным boards и shields
# BOARD_ROOT должен указывать на директорию, содержащую папку boards
export BOARD_ROOT := ${PWD}
# SHIELD_ROOT больше не нужен, так как shields находятся внутри boards
# export SHIELD_ROOT := ${PWD}/boards/shields

default: help
help: Makefile
	@echo "\n Choose a command run in "$(PROJECT)" project:"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'

## * make freeze - зафиксировать зависимости PIP в requirements.txt;
freeze:
	@echo "Freezing PIP dependencies"
	pip freeze > ${BASE_DIR}/requirements.txt

## * make build - сборка прошивки (make build BOARD=(left|right|dongle) SHIELD_FIREWARE="azoteq_sofle_left display_view_horizontal");
build:
	west build -d build/${BOARD} -s ${ZMK_APP_DIR} -b ${MAIN_BOARD} -- -DSHIELD=${SHIELD_FIREWARE} -DZMK_CONFIG=${DZMK_CONFIG}
	mkdir -p ${FIREWARE_DIR}
	cp build/${BOARD}/zephyr/zmk.uf2 ${FIREWARE_DIR}/azoteq_sofle_${BOARD}_${MAIN_BOARD}.uf2

## * make clear_build - очистка артефактов сборки;
clear_build:
	rm -rf build ${FIREWARE_DIR}

_build_l:
	west build -d build/left -s ${ZMK_APP_DIR} -b ${MAIN_BOARD} -- \
	-DSHIELD="azoteq_sofle_left nice_view_adapter nice_view_elemental" \
	-DZMK_CONFIG=${DZMK_CONFIG}
	mkdir -p ${FIREWARE_DIR}
	cp build/left/zephyr/zmk.uf2 ${FIREWARE_DIR}/azoteq_sofle_left_${MAIN_BOARD}.uf2

_build_r:
	west build -d build/right -s ${ZMK_APP_DIR} -b ${MAIN_BOARD} -- \
	-DSHIELD="azoteq_sofle_right nice_view_adapter nice_view_elemental azoteq_touchpad" \
	-DZMK_CONFIG=${DZMK_CONFIG} \
	-DEXTRA_CONF_FILE="config/prj_no_wpm.conf"
	mkdir -p ${FIREWARE_DIR}
	cp build/right/zephyr/zmk.uf2 ${FIREWARE_DIR}/azoteq_sofle_right_${MAIN_BOARD}.uf2

_build_reset:
	west build -d build/reset -s ${ZMK_APP_DIR} -b ${MAIN_BOARD} -- -DSHIELD="settings_reset" -DZMK_CONFIG=${DZMK_CONFIG}
	mkdir -p ${FIREWARE_DIR}
	cp build/reset/zephyr/zmk.uf2 ${FIREWARE_DIR}/azoteq_sofle_reset_${MAIN_BOARD}.uf2

_clear_all:
	clear
	rm -rf .west build ${FIREWARE_DIR} .cache .config ~/Library/Caches/zephyr/

_init:
	@echo "Initializing project..."
	cd zmk && \
	west init -l ./ && \
	west update && \
	pip install -r ./zephyr/scripts/requirements-extras.txt && \
	cd ..


_first_init:
	@echo "First time initialization..."
	brew install cmake ninja gperf python3 ccache qemu dtc wget libmagic && \
	python3 -m venv venv && \
 
_install_west:
	# Run command before - 'source venv/bin/activate'
	pip install west

_zephyr_check:
	west zephyr-export
	west list

_activate_env_values:
	./setup_env.sh

# ! с консоли make не работает
_init_env:
	source venv/bin/activate
	source zmk/zephyr/zephyr-env.sh
 
start:
	_first_init 
	_install_west
	_init
	_zephyr_check
	_activate_env_values
	_init_env
