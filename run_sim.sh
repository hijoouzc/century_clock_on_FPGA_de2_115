#!/bin/bash
set -e

echo "[1/2] Biên dịch mô phỏng và tạo VCD trace với Verilator..."
verilator --binary --timing --trace -Wno-TIMESCALEMOD -Wno-WIDTHTRUNC --top-module tb_century_clock tb/tb_century_clock.v rtl/*.v

echo "[2/2] Chạy mô phỏng..."
./obj_dir/Vtb_century_clock

echo "=========================================================="
echo " ĐÃ TẠO XONG FILE SÓNG: tb_century_clock.vcd"
echo " Bạn chỉ cần click chuột vào file 'tb_century_clock.vcd' trong IDE để xem!"
echo "=========================================================="
