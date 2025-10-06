#!/bin/bash

source venv/bin/activate
source zmk/zephyr/zephyr-env.sh

export ZEPHYR_BASE=$(pwd)/zmk/zephyr
export GNUARMEMB_TOOLCHAIN_PATH=/opt/homebrew/
export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb

# Добавление Zephyr в PYTHONPATH
export PYTHONPATH=$ZEPHYR_BASE/scripts:$PYTHONPATH

# Добавление утилит Zephyr в PATH
export PATH=$ZEPHYR_BASE/scripts:$PATH

echo "Environment setup complete."

# Проверка переменных окружения
echo "ZEPHYR_BASE: $ZEPHYR_BASE"
echo "PATH: $PATH"