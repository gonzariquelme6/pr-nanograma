:- module(proylcc,
	[  
		put/8,
		check_init/5
	]).

:-use_module(library(lists)).
:-use_module(library(clpfd)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ver_subcadena(+Cant, +XXs,-XRes)
%
% XRes es el resultado de sacar la subcadena de Cant "#" consecutivos de XXs.
ver_subcadena(0,[],[]).
ver_subcadena(0,[X|Xs],Xs):- X\=="#".
ver_subcadena(Cant,[X|Xs],XRes):- 
	X=="#",
	CantAux is Cant-1,
	ver_subcadena(CantAux,Xs,XRes).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check(+PPs,+XXs, -R)
%
% R es el resultado de verificar que la lista XXs de celdas satisface las pistas de la lista PPs.

%CB
%si no tengo pistas y la lista sigue con un # devuelvo 0
check([],[X|_Xs],0):-X=="#".
%si no tengo pistas y la lista sigue, y sigue habiendo # devuelvo 0
check([],[X|Xs],0):- X\=="#", memberchk("#",Xs).
%si se vacian las dos listas devuelvo 1
check([],[],1).
%si se vacian las pistas y no tengo mas # devuelvo 1
check([],[X|Xs],1):- X\=="#", not(memberchk("#",Xs)).

%CR1
%si tengo pistas y la lista no empieza con #, avanzo en la lista
check([P|Ps],[X|Xs],Res):- X\=="#", check([P|Ps],Xs,Res).

%CR2
%si tengo pistas y la lista empieza con # me fijo que la cadena de # consecutivas sea igual a la pista
check([P|Ps],[X|Xs],Res):- X=="#",
	Cant is P-1,
	ver_subcadena(Cant,Xs,XRes),
	check(Ps,XRes,Res).
%sino devuelvo 0.
check([_P|_Ps],[X|_Xs],0):- X=="#".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% satisfies(+XIndex, +Pistas, +Grilla, -Res)
%
% Res es el resultado de verificar que la lista en XIndex de Grilla satisface la pista XIndex de Pistas.
satisfies(XIndex,Pistas,Grilla,Res):-
	nth0(XIndex,Pistas,PistaX),
	nth0(XIndex,Grilla,ListaX),
	check(PistaX,ListaX,Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, FilaSat, ColSat):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.
	
	replace(Row, RowN, NewRow, Grilla, NewGrilla),
	
	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Conenido.	 
	
	(replace(Cell, ColN, _ , Row, NewRow),
	Cell == Contenido;
	replace(_Cell, ColN, Contenido, Row, NewRow)),
    
	satisfies(RowN,PistasFilas,NewGrilla,FilaSat),
    transpose(NewGrilla,Columns),
	satisfies(ColN,PistasColumnas,Columns,ColSat).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_vacio(+XXs, -R)
%
% R es el resultado de verificar si la lista XXs no tiene "#".
check_vacio([],0).
check_vacio([X|_Xs],1):- X=="#".
check_vacio([X|Xs],R):- X\=="#", check_vacio(Xs,R).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_init_aux(+XXs, +YYs, -RRs)
%
% RRs es el resultado de verificar si cada lista de YYs satisface la pista correspondiente de XXs.
check_init_aux([],[],[]).
check_init_aux([X|Xs],[Y|Ys],[R|Rs]):-
	(check_vacio(Y,R), R==0 ; check(X,Y,R)),
	check_init_aux(Xs,Ys,Rs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_init(+PistasFilas, +PistasColumnas, +Grilla, -FilasSat, -ColsSat)
%
% FilasSat es el resultado de verificar fila por fila si satisfacen su correspondiente pista.
% ColsSat es el resultado de verificar columna por columna si satisfacen su correspondiente pista.

check_init(PistasFilas, PistasColumnas, Grilla, FilasSat, ColsSat):-
	check_init_aux(PistasFilas,Grilla,FilasSat),
	transpose(Grilla,GrillaCols),
	check_init_aux(PistasColumnas,GrillaCols,ColsSat).

