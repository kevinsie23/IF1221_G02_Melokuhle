:- include('dynamic.pl').
:- include('util.pl').
:- include('save.pl').
:- include('load.pl').
:- include('state.pl').
:- include('kartu.pl').
:- include('util.pl').

urutanPemain([]). % Inisialisasi List Urutan Pemain
startGame:- 
    write('Masukkan jumlah pemain: '), read(Num), nl,
    checkPlayerCount(Num),
    inputName(Num).

checkPlayerCount(X):- X>=2, X=< 4, !.
checkPlayerCount(_):- write('Mohon masukkan angka antara 2-4.'), nl, startGame.

inputName(PlayerNumber):- inputNameHelper(PlayerNumber,1, SeenList).

% Base Case
inputNameHelper(0,_):- !.
% Case Sucess
inputNameHelper(X,Count):- 
    X>0,
    retract(urutanPemain(List)),
    write('Masukkan nama pemain '), write(Count), write(': '),
    read(Name),
    \+ isMember(Name, List), !,  % Cek apakah Name ada di List urutan pemain
    assertz(urutanPemain([Name|List])), % Append Nama ke List Urutan Pemain
    assertz(infoPemain(Nama, [])), % Inisialisasi Info Pemain dgn nama valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputName(NextX, NextCount).
% Case Fail
inputNameHelper(X,Count):- 
    X>0,
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X,Count).
% retryInput
retryInput(X, Count):-
    retract(urutanPemain(List)),
    read(Name),
    \+ isMember(Name, List), !,
    assertz(urutanPemain([Name|List])), % Append Nama ke List Urutan Pemain
    assertz(infoPemain(Nama, [])), % Inisialisasi Info Pemain dgn nama valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
%Retry Fail
retryInput(X, Count):-     
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count).
