#!/bin/bash

EXPORT_FILE=/sys/class/gpio/export

CSN_ADC=/sys/class/gpio/gpio1023
CSN_CLK=/sys/class/gpio/gpio1022
SCK=/sys/class/gpio/gpio1021
SDIO=/sys/class/gpio/gpio1020

# 1020 sdio
# 1021 sck
# 1022 csn_clk
# 1023 csn_adc

echo 1020 | sudo tee $EXPORT_FILE
echo 1021 | sudo tee $EXPORT_FILE
echo 1022 | sudo tee $EXPORT_FILE
echo 1023 | sudo tee $EXPORT_FILE

echo 'out' | sudo tee $CSN_CLK/direction
echo 'out' | sudo tee $CSN_ADC/direction
echo 'out' | sudo tee $SCK/direction
echo 'out' | sudo tee $SDIO/direction

echo '1' | sudo tee $CSN_CLK/value
echo '1' | sudo tee $CSN_ADC/value
echo '0' | sudo tee $SCK/value
echo '0' | sudo tee $SDIO/value

function readreg {
    sudo bash -c "echo 'out' > $SDIO/direction"
    sudo bash -c "echo '0' > $CSN_ADC/value"

    INSTR=$(($1 | 0x8000))
    printf 'read: %04x\n' $INSTR

    for ((i = 0; i < 16; i++)); do
        if [[ $(($INSTR & 0x8000)) == 0 ]]; then 
            sudo bash -c "echo '0' > $SDIO/value"
        else
            sudo bash -c "echo '1' > $SDIO/value"
        fi
        sudo bash -c "echo '1' > $SCK/value"
        INSTR=$(($INSTR << 1))
        sudo bash -c "echo '0' > $SCK/value"
    done

    sudo bash -c "echo 'in' > $SDIO/direction"

    echo "output:"

    for ((i = 0; i < 8; ++i)); do
        sudo bash -c "echo '1' > $SCK/value"
        cat $SDIO/value
        sudo bash -c "echo '0' > $SCK/value"
    done

    sudo bash -c "echo '1' > $CSN_ADC/value"
}

function writereg {
    sudo bash -c "echo 'out' > $SDIO/direction"
    sudo bash -c "echo '0' > $CSN_ADC/value"

    INSTR=$(($1 & 0x7fff))
    DATA=$(($2))

    printf 'write: %04x|%02x\n' $INSTR $DATA

    for ((i = 0; i < 16; i++)); do
        if [[ $(($INSTR & 0x8000)) == 0 ]]; then 
            sudo bash -c "echo '0' > $SDIO/value"
            echo 0
        else
            sudo bash -c "echo '1' > $SDIO/value"
            echo 1
        fi
        sudo bash -c "echo '1' > $SCK/value"
        INSTR=$(($INSTR << 1))
        sudo bash -c "echo '0' > $SCK/value"
    done

    for ((i = 0; i < 8; i++)); do
        if [[ $(($DATA & 0x80)) == 0 ]]; then 
            sudo bash -c "echo '0' > $SDIO/value"
            echo 0
        else
            sudo bash -c "echo '1' > $SDIO/value"
            echo 1
        fi
        sudo bash -c "echo '1' > $SCK/value"
        DATA=$(($DATA << 1))
        sudo bash -c "echo '0' > $SCK/value"
    done

    sudo bash -c "echo '1' > $CSN_ADC/value"
}

writereg 0x10 0x17 #0x14
writereg 0x14 0x09 #0x08
writereg 0xff 0x01
# readreg 0xff
# readreg 0x10

# readreg 0x16
# writereg 0x16 0x00 # 0x80
# writereg 0xff 0x01
# readreg 0xff
# readreg 0x16

# writereg 0x18 0x0a # 0x0a
# writereg 0xff 0x01
# readreg 0xff
# readreg 0x18

# readreg 0x14
# writereg 0x14 0x09 # 0x08
# writereg 0xff 0x01
# readreg 0xff
# readreg 0x14

# writereg 0x0d 0x00 # 0x00
# writereg 0xff 0x01
# readreg 0xff
# readreg 0x0d
