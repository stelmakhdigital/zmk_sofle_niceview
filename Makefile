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

## * make build - сборка прошивки (make build BOARD=left | right | dongle);
build:
	west build -d build/${BOARD} -s ${ZMK_APP_DIR} -b ${MAIN_BOARD} -- -DSHIELD="azoteq_sofle_${BOARD}${ADDITION_BOARD}" -DZMK_CONFIG=${DZMK_CONFIG}
	mkdir -p ${FIREWARE_DIR}
	cp build/${BOARD}/zephyr/zmk.uf2 ${FIREWARE_DIR}/azoteq_sofle_${BOARD}_${MAIN_BOARD}.uf2


## * make build - сборка прошивки с уникальным названием платы (make build BOARD=left | right | dongle ADDITION_BOARD=zmk_niceview zmk_niceview_bl);
custom_build:
	west build -d build/${BOARD} -s ${ZMK_APP_DIR} -b ${MAIN_BOARD} -- -DSHIELD="${ADDITION_BOARD}" -DZMK_CONFIG=${DZMK_CONFIG}
	mkdir -p ${FIREWARE_DIR}
	cp build/${BOARD}/zephyr/zmk.uf2 ${FIREWARE_DIR}/azoteq_sofle_${BOARD}_${MAIN_BOARD}.uf2


zephyr_check:
	west zephyr-export
	west list

## * make clear_build - очистка артефактов сборки;
clear_build:
	rm -rf build ${FIREWARE_DIR}

_clear_all:
	clear
	rm -rf .west build ${FIREWARE_DIR} .cache .config ~/Library/Caches/zephyr/

_init:
	@echo "Initializing project..."
	west init -l ./
	west update
	west zephyr-export
	pip install -r ./zephyr/scripts/requirements-extras.txt

_first_init:
	@echo "First time initialization..."
	brew install cmake ninja gperf python3 ccache qemu dtc wget libmagic
	python3 -m venv venv

_install_west:
	# Run command before - 'source venv/bin/activate'
	pip install west

activate_env:
	./setup_env.sh



# ./module.yml
# name: zmk-config
# build:
#   settings:
#     board_root: boards
#     shield_root: boards/shields