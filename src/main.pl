:- include('dynamic.pl').
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

inputName(PlayerNumber):- inputNameHelper(PlayerNumber,1).

% Base Case
inputNameHelper(0,_):- !.
% Case Sucess
inputNameHelper(X,Count):- 
    X>0,
    write('Masukkan Name pemain '), write(Count), write(': '),
    read(Name),
    urutanPemain(List),
    \+ isMember(Name, List), !,  % Cek apakah Name ada di List urutan pemain
    retract(urutanPemain(List)),
    assertz(urutanPemain([Name|List])), % Append Name ke List Urutan Pemain
    assertz(infoPemain(Name, [])), % Inisialisasi Info Pemain dgn Name valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
% Case Fail
inputNameHelper(X,Count):- 
    X>0,
    write('Name sudah digunakan. Masukkan Name lain:  '), 
    retryInput(X,Count).

% retryInput Sucess
retryInput(X, Count):-
    read(Name),
    urutanPemain(List),
    \+ isMember(Name, List), !,
    retract(urutanPemain(List)),
    assertz(urutanPemain([Name|List])), % Append Name ke List Urutan Pemain
    assertz(infoPemain(Name, [])), % Inisialisasi Info Pemain dgn Name valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
% retryInput Fail
retryInput(X, Count):-     
    write('Name sudah digunakan. Masukkan Name lain:  '), 
    retryInput(X, Count).
