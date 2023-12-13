# tubes-sisdig-2023

#### KELOMPOK 10
- Raphael Nathaniel Hartanto (13222060)
- Muhammad Yusuf Al Azmi (13222062)
- Zulfan Andria Putranto (13222063)
- Muhammad Eiros Dante (1322064)
- Ihsan Hidayat Rafi (13222065)
- Goldwin Sonick Wijaya Thaha (13222067)

## XTEA ENCRYPTION
Sistem Enkripsi dengan Algoritma XTEA. Pada tugas besar ini, kelompok 10 ingin membuat suatu sistem yang dapat melakukan enkripsi/dekripsi terhadap suatu file/dokumen. File/dokumen yang ada di PC/Laptop dikirim secara serial ke FPGA untuk dienkripsi dan dikembalikan hasil enkrips/dekripsi secara serial ke PC/Laptop.


## FPGA Board
Dev Board: RZ-EasyFPGA A2.2

Chip: Altera Cyclone IV EP4cE6E22C8N

Spesifikasi 
[(1)](https://pdf1.alldatasheet.com/datasheet-pdf/view/508700/ALTERA/EP4CE6E22C8N.html)
[(2)](https://makerselectronics.com/product/rz-easy-fpga-a2-2-development-board):

## Cara Menjalankan Sistem

### Setup FPGA
Menggunakan Quartus Prime 22.1, buka Project "XTEA_Project.qpf" di "quartus/XTEA_Project.qpf".
Upload Kodenya dengan Tools Programmer melalui JTAG ke FPGA.

### Menggunkan App
Buka program app.py dengan menjalankan kode
```
python src/app/app.py
```
(Pastikan python3 sudah terinstall!)

Serial Port yang terhubung akan ditampilkan. Jika belum terhubung, hubungkan kabel serial dan tekan Refresh Port.

1. Masukkan port pada pilihan "Select FPGA Port:". Misal "COM4"
Update Port untuk set Port FPGA.

2. Masukkan file yang ingin di enkripsi/dekripsi pada folder "data".

3. Masukkan path menuju file tersebut pada "Path to File" dan masukkan path output pada "Output Path:".

4. Masukkan Key/Password enkripsi/dekripsi.

5. Tekan Encrypt untuk Encrypt atau Decrypt untuk Decrypt.

Jika berhasil, maka file akan muncul di Path Output yang telah ditentukan.


<div style="font-size:0.2em">Damn, this project broke me to cry at 07.00AM in the morning. 1 Hour before final presentation. No sleep at all.

Other than that, It's fun and I love this project.</div>
