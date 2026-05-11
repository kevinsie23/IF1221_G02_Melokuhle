
startGame:- 
    write('Masukkan jumlah pemain: '), read(Num), nl, 
    checkPlayerCount(Num), inputName(Num,1,ListNama,ListData), !. 

checkPlayerCount(X):- X>=2, X=<4, !.
checkPlayerCount(_):- write('Mohon masukkan angka antara 2-4.'), nl, startGame.

inputName(X, Count, ListNama, Result):- getName(X, Count, [], Result).

%Base Case saat X sudah 0 mulaih input list
getName(0, _,  _, []). 
%getName Sukses Nama Unik
getName(X,Count, Seen, [[Input|_]|Rest]) :-
    X>0,
    write('Masukkan nama pemain '), write(Count), write(': '),
    read(Input), 
    \+ member(Input, Seen), !, %Cek apakah Input ada di dalam List Seen
    NextX is X-1,
    NextCount is Count+1,
    getName(NextX, NextCount, [Input|Seen], Rest). % [Name|Seen] Masukin Name ke Dalam Seen
%Get Name gagal Nama tidak unik
getName(X, Count, Seen, Rest):- 
    X>0, 
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count, Seen, Rest).

%Retry Sukses
retryInput(X, Count, Seen, [[Input|_]|Rest]) :-
    read(Input),
    \+ member(Input, Seen), !, %Cek apakah Input ada di dalam List Seen
    NextX is X-1,
    NextCount is Count+1,
    getName(NextX, NextCount, [Input|Seen], Rest). % [Name|Seen] Masukin Name ke Dalam Seen
%Retry Fail
retryInput(X, Count, Seen, Rest):-     
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count, Seen, Rest).
