# Century Clock on FPGA DE2-115

Đồ án thiết kế Đồng hồ thế kỷ trên kit Altera DE2-115 (Cyclone IV EP4CE115F29C7).

## 1. Cấu trúc thư mục
* `rtl/`: Toàn bộ mã nguồn Verilog thiết kế chuẩn đồng bộ (50 MHz):
  * `century_clock_top.v`: Module đỉnh kết nối các khối với chân phần cứng.
  * `clk_div.v`: Bộ tạo xung Enable 1Hz và xung nhấp nháy 2Hz.
  * `button_filter.v`: Lọc rung phím 20ms và tạo xung 1 chu kỳ clock (Active-low).
  * `clock_core.v`: Bộ đếm RTC (Giây, Phút, Giờ, Ngày, Tháng, Năm), thuật toán năm nhuận và FSM cài đặt.
  * `display_controller.v`: Bộ chọn nội dung hiển thị (Giờ/Ngày) và điều khiển nhấp nháy.
  * `seg7_decoder.v`: Giải mã LED 7 đoạn Active-Low.
* `tb/`: Testbench mô phỏng:
  * `tb_century_clock.v`: Testbench kiểm thử tự động, test chuyển ngày năm nhuận và bấm nút chỉnh giờ.
* `syn/`:
  * `de2_115_pins.qsf`: File gán chân chuẩn cho kit DE2-115.

## 2. Hướng dẫn sử dụng trên kit DE2-115
* **Clock & Reset:**
  * `CLOCK_50` (PIN_Y2): Xung nhịp 50 MHz.
  * `KEY[3]` (PIN_R24): Reset hệ thống về mặc định (Active-Low).
* **Công tắc chọn chế độ (Switch):**
  * `SW[0]`: `0` = RUN (Đồng hồ chạy), `1` = SET (Chế độ chỉnh giờ/ngày).
  * `SW[1]`: `0` = Hiển thị Giờ (`HH:MM:SS`), `1` = Hiển thị Ngày (`DD:MM:YYYY`).
* **Nút bấm khi cài đặt (`SW[0] = 1`):**
  * `KEY[0]`: Chuyển trường cần chỉnh (trường đang chọn sẽ nhấp nháy).
  * `KEY[1]`: Tăng giá trị (+1).
  * `KEY[2]`: Giảm giá trị (-1).
* **Hiển thị (8 LED 7 đoạn):**
  * Chế độ Giờ: `HEX7-HEX6` (Giờ) : `HEX5-HEX4` (Phút) : `HEX3-HEX2` (Giây) | `HEX1-HEX0` (Tắt).
  * Chế độ Ngày: `HEX7-HEX6` (Ngày) / `HEX5-HEX4` (Tháng) / `HEX3-HEX0` (Năm 4 số).