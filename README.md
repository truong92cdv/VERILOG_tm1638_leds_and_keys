# VERILOG_tm1638_leds_and_keys

Giao tiếp với module Led&Key qua ic TM1638

## I. Tác giả

- **Name:** Võ Nhật Trường
- **Email:** truong92cdv@gmail.com
- **GitHub:** [truong92cdv](https://github.com/truong92cdv)

## II. Kết quả demo

https://github.com/user-attachments/assets/b7c5aba8-a250-43e0-b88c-ab4844460aa1

## III. Thiết bị

- ZUBoard 1CG mã XCZU1CG-1SBVA484E
- Module điều khiển Led&Key MDU1093 tích hợp ic **TM1638**.
- 3 đường dây tín hiệu STB, CLK, DIO, dây VCC +5V, dây GND.

![module Led&Key TM1638](./images/module_tm1638_ledandkey.jpg)

## IV. TM1638

Tham khảo [TM1638 Datasheet](./refs/TM1638.PDF).

ic TM1638 giúp điều khiển led và quét phím hiệu quả với chỉ 3 dây tín hiệu: STB, CLK, DIO. Bên trong TM1638 có sẵn 16 thanh ghi 8 bit đánh địa chỉ từ 00h -> 0Fh.

Có 3 chế độ giao tiếp với TM1638:
1. Truyền dữ liệu với địa chỉ tăng tự động.
2. Truyền dữ liệu với địa chỉ cố định.
3. Đọc dữ liệu quét phím.

Các khung truyền dữ liệu tương ứng cần đạt được như sau:

![TM1638 3 transmission modes](./images/tm1638_3modes)

Dữ liệu được ghi vào TM1638 ở chân DIO tại mỗi cạnh lên xung CLK, dữ liệu từ TM1638 sẽ ghi vào DIO tại cạnh xuống xung CLK.

## V. Source code

Waveform tm1638_tb

![waveform_tm1638_tb](./images/tm1638_tb.png)

Waveform top_tb

![waveform_top_tb](./images/top_tb.png)

## VI. Tham khảo

1. [TM1638 Datasheet](./refs/TM1638.PDF)
2. [TM1638 module schematic](./refs/TM1638_shcematic.pdf)
3. [TM1638 project - alangarf](https://github.com/alangarf/tm1638-verilog)
