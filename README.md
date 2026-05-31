# IF1221_G02_Melokuhle

## Gambaran Umum Proyek
Proyek ini merupakan praktikum akhir dari mata kuliah IF1221 Logika Komputasional bertemakan permainan kartu bernama **UNI** (sebuah modifikasi dari permainan kartu lain dengan nama serupa). Praktikum ini bertujuan untuk mengimplementasikan konsep-konsep terkait bahasa prolog yang telah diajarkan selama mata kuliah ini, termasuk melalui pra-praktikum dan eksplorasi mandiri. Pada praktikum ini, terdapat beberapa implementasi utama yang perlu dipenuhi, yakni:
- rekurens
- list
- cut
- fail
- loop
- file processing


## Alur Program
Alur program dari proyek ini diawali dengan mengubah directory ke file src pada folder IF1221_G02_Melokuhle
```
.../IF1221_G02_Melokuhle/src    
```        
    

Setelah itu, dilakukan consult pada program 'main.pl'
```
| ?- consult('C:/Things/Semester 2/IF1221 Logika Komputasional/Praktikum/IF1221_G02_Melokuhle/src/main.pl').
```


### Permainan dapat dimulai melalui 2 cara utama, yaitu:
#### 1. startGame
Jika memilih perintah startGame, maka permainan yang dimulai adalah permainan yang baru. Pengguna dapat memilih mode permainan dan juga jumlah permainannya.

#### 2. loadGame
Jika memilih perintah loadGame, pengguna harus memastikan bahwa file yang dimuat harus ada. Permainan yang dimuat tentunya bersambung dari terakhir kali file tersebut disimpan.

### Permainan akan berhenti ketika salah satu  situasi berikut terjadi, yaitu:
#### 1. endGame
Situasi endGame terjadi ketika salah satu pemain berhasil menghabiskan semua kartunya. Permainan akan otomatis berhenti dan melakukan perhitungan poin untuk masing-masing pemain sekaligus penentuan pemenang permainan.

#### 2. saveGame
saveGame merupakan sebuah perintah yang bertujuan untuk menyimpan informasi terkait permainan di saat itu. Apabila memilih untuk melakukan saveGame, semua data permainan akan disimpan ke file yang telah ditentukan dan permainan otomatis akan berhenti.

## Fitur Utama
- startGame: Memulai permainan, termasuk memilih mode permainan dan jumlah pemain
- mainkanKartu(X): Memainkan kartu di tangan sesuai urutan indeksnya
- ambilKartu: Mengambil kartu dari draw pile
- tantang: Menantang pemain sebelumnya yang memainkan kartu draw_four
- uni(X): Memanggil uni sekaligus memainkan kartu di tangan sesuai urutan indeksnya
- tangkap(X): Mengecek apabila pemain yang ditangkap telah menyerukan UNI
- lihatCommand: Menunjukkan semua perintah yang dapat dilakukan pada saat itu
- lihatKartu: Menunjukkan semua kartu yang dimiliki di tangan pemain giliran itu
- cekInfo: Menunjukkan gambaran permainan saat itu, termasuk urutan, jumlah kartu tiap pemain, dan kartu discard paling atas
- saveGame: Menyimpan data permainan saat itu ke sebuah file txt
- loadGame: Memuat data permainan dari file txt agar dapat dilanjutkan
- sembunyikanKartu(X): Menyembunyikan kartu di tangan sesuai urutan indeksnya agar jumlah kartunya terlihat berkurang
- tampilkanKartu: Menampilkan kartu yang disembunyikan


## Anggota Kelompok
| Nama | NIM |
| :---: | :---: |
| Muhammad Hanif Yusran Putra | 13525005 |
| Wimar Wdiarto | 13525009 |
| Kevin Sie | 13525053 |
| Nazhif Hilmi Kistijantoro | 13525115 |
