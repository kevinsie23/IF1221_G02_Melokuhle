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


Permainan dapat dimulai melalui 2 cara utama, yaitu:
### 1. startGame
Jika memilih perintah startGame, maka permainan yang dimulai adalah permainan yang baru. Pengguna dapat memilih mode permainan dan juga jumlah permainannya.

### 2. loadGame
Jika memilih perintah loadGame, pengguna harus memastikan bahwa file yang dimuat harus ada. Permainan yang dimuat tentunya bersambung dari terakhir kali file tersebut disimpan.

Permainan akan berhenti ketika salah satu  situasi berikut terjadi, yaitu:
### 1. endGame
Situasi endGame terjadi ketika salah satu pemain berhasil menghabiskan semua kartunya. Permainan akan otomatis berhenti dan melakukan perhitungan poin untuk masing-masing pemain sekaligus penentuan pemenang permainan.

### 2. saveGame
saveGame merupakan sebuah perintah yang bertujuan untuk menyimpan informasi terkait permainan di saat itu. Apabila memilih untuk melakukan saveGame, semua data permainan akan disimpan ke file yang telah ditentukan dan permainan otomatis akan berhenti.
