%Predicados dinamicos para permitir su modificacion en tiempo de
%ejecución para poder agregar encuestas y tortas nuevas
:- dynamic encuesta/7.
:- dynamic torta/2.
% Cargo los archivos externos con tortas y encuestas previamente
% guardadas
:- [nuevas_tortas].
:- [nuevas_encuestas].

%------------------------- Agrupación de edades -------------------------%

rango_edad(Edad, '18-25') :- Edad >= 18, Edad =< 25.
rango_edad(Edad, '26-35') :- Edad >= 26, Edad =< 35.
rango_edad(Edad, '36-45') :- Edad >= 36, Edad =< 45.
rango_edad(Edad, '46-55') :- Edad >= 46, Edad =< 55.
rango_edad(Edad, '56-65') :- Edad >= 56, Edad =< 65.

%Transforma una lista de edades en una lista de rangos de edad

%Caso base
agrupar_rangos([], []).
%Caso recursivo
agrupar_rangos([(Edad, Gen)|T], [(Rango, Gen)|T2]) :-
    rango_edad(Edad, Rango),
    agrupar_rangos(T, T2).

%------------------------ Conteo de ocurrencias ------------------------%
%Cuenta cuántas veces aparece cada elemento en una lista
contar_ocurrencias(Lista, Resultado) :- contar_aux(Lista, [], Resultado).
%Caso base
contar_aux([], Acc, Acc).
%Caso recursivo
contar_aux([X|Xs], Acc, Resultado) :-
    ( select(X-N, Acc, Resto) -> N1 is N + 1,
      contar_aux(Xs, [X-N1|Resto], Resultado);
      contar_aux(Xs, [X-1|Acc], Resultado)
    ).

%Obtiene el elemento con mayor número de ocurrencias
maximo([X-N|Xs], Max) :- maximo_aux(Xs, X, N, Max).
%Caso base
maximo_aux([], Max, _, Max).
%Caso recursivo
maximo_aux([X-N|Xs], _, NMax, Max) :- N > NMax, !, maximo_aux(Xs, X, N, Max).
maximo_aux([_|Xs], MaxSoFar, NMax, Max) :- maximo_aux(Xs, MaxSoFar, NMax, Max).

%----------------------------- Consultas -----------------------------%
%
%
%Lista todas las tortas disponibles en el sistema
listar_tortas(Lista) :- findall(Nombre, torta(_, Nombre), Lista).

% Lista todas las encuestas de una torta en especifico
listar_encuestas_por_torta(NumTorta, Lista) :-
    findall(
        encuesta(Num, Edad, Gen, NumTorta, Acepta, Motivo, Precio),
        encuesta(Num, Edad, Gen, NumTorta, Acepta, Motivo, Precio),
        Lista
    ).

%Obtener todas las encuestas de aceptación de una torta
%Devuelve una lista con los numeros de encuesta que aceptan la torta
%ingresada
aceptacion_por_torta(NumTorta, Lista):-
    findall(Num, encuesta(Num,_,_,NumTorta,si,_,_),Lista).

%Obtener todas las encuestas de rechazo de una torta
%Devuelve una lista con los numeros de encuesta que rechazan la torta
%ingresada
rechazos_por_torta(NumTorta, ListaNum) :-
    findall(Num, encuesta(Num, _, _, NumTorta, no,_, _), ListaNum).

%Encuestas positivas por torta
%Devuelve una lista de pares con el formato NumTorta-Cantidad
contar_aceptaciones(Resultado):-
    findall(NumTorta, encuesta(_,_,_,NumTorta,si,_,_),Lista),
    contar_ocurrencias(Lista,Resultado).

%Encuestas negativas por torta
%Devuelve una lista de pares con el formato NumTorta-Cantidad
contar_rechazos(Resultado) :-
    findall(NumTorta, encuesta(_, _, _, NumTorta, no,_, _), Lista),
    contar_ocurrencias(Lista, Resultado).

%Torta mas aceptada
%Devuelve el nombre de la torta más aceptada
mas_aceptada(T,Cant):-
    contar_aceptaciones(Lista),
    maximo(Lista, NumTorta),
    member(NumTorta-Cant, Lista),
    torta(NumTorta, T).

%Torta menos aceptada
%Devuelve el nombre de la torta menos aceptada
menos_aceptada(T,Cant) :-
    contar_aceptaciones(Lista),
    sort(2, @=<, Lista, Ordenada),
    Ordenada = [NumTorta-Cant | _],
    torta(NumTorta, T).

%Torta mas rechazada
%Devuelve el nombre de la torta más rechazada
mas_rechazada(T,Cant) :-
    contar_rechazos(Lista),
    maximo(Lista, NumTorta),
    member(NumTorta-Cant, Lista),
    torta(NumTorta, T).

%Torta menos rechazada
%Devuelve el nombre de la torta menos rechazada
menos_rechazada(T,Cant) :-
    contar_rechazos(Lista),
    sort(2, @=<, Lista, Ordenada),
    Ordenada = [NumTorta-Cant | _],
    torta(NumTorta, T).

%Rango de edad y genero que mas acepta cada torta
%Devuelve el rango de edad y género que más acepta una torta especifica
rango_mayor_aceptacion(NumTorta, Rango, Genero) :-
    findall((Edad, Gen), encuesta(_, Edad, Gen, NumTorta, si,_, _), Lista),
    agrupar_rangos(Lista, Agrupado),
    contar_ocurrencias(Agrupado, Cont),
    maximo(Cont, (Rango, Genero)).

%Rango de edad y genero que más rechaza cada torta
%Devuelve el rango de edad y género que más rechaza una torta especifica
rango_mayor_rechazo(NumTorta, Rango, Genero) :-
    findall((Edad, Gen), encuesta(_, Edad, Gen, NumTorta, no, _,_), Lista),
    agrupar_rangos(Lista, Agrupado),
    contar_ocurrencias(Agrupado, Cont),
    maximo(Cont, (Rango, Genero)).

%Cantidad total de encuestados
cantidad_encuestados(Total) :-
    findall(Num, encuesta(Num, _, _, _, _, _, _), Lista),
    length(Lista, Total).

%Cantidad total de aceptaciones
cantidad_aceptaciones(Total) :-
    findall(Num, encuesta(Num, _, _, _, si, _,_), Lista),
    length(Lista, Total).

%Cantidad total de rechazos
cantidad_rechazos(Total) :-
    findall(Num, encuesta(Num, _, _, _, no, _, _), Lista),
    length(Lista, Total).

%Razon mas comun de aceptacion para cada torta
%Devuelve la razon de aceptacion mas frecuente para una torta especifica
razon_principal_aceptacion(NumTorta, Razon) :-
    findall(Motivo, encuesta(_, _, _, NumTorta, si,Motivo, _), Lista),
    contar_ocurrencias(Lista, Cont),
    maximo(Cont, Razon).

%Razon mas comun de rechazo para cada torta
%Devuelve la razon de rechazo mas frecuente para una torta especifica
razon_principal_rechazo(NumTorta, Razon) :-
    findall(Motivo, encuesta(_, _, _, NumTorta, no,Motivo, _), Lista),
    contar_ocurrencias(Lista, Cont),
    maximo(Cont, Razon).

%Calcular el precio promedio que los encuestados estarian dispuestos a
%pagar por torta (solo quienes aceptan)
%Devuelve el precio promedio de una torta especifica
precio_promedio_aceptacion(NumTorta, Promedio) :-
    findall(Precio, encuesta(_, _, _, NumTorta, si,_, Precio), Lista),
    Lista \= [],
    sum_list(Lista, Suma),
    length(Lista, Cant),
    Promedio is Suma / Cant.


% -------------------Agregar encuestas y tortas dinamicamente-------------------%
%
%Guarda la encuesta en el archivo y la agrega al sistema en ejecución
registrar_encuesta(Num, Edad, Genero, NumTorta, Acepta, Motivo, Precio) :-
    assertz(encuesta(Num,Edad,Genero,NumTorta,Acepta,Motivo,Precio)),
    guardar_encuesta_en_archivo(Num,Edad,Genero,NumTorta,Acepta,Motivo,Precio).
guardar_encuesta_en_archivo(Num, Edad, Genero, NumTorta, Acepta, Motivo, Precio) :-
    open('nuevas_encuestas.pl', append, Stream),
    write(Stream, 'encuesta('),
    write(Stream, Num), write(Stream, ', '),
    write(Stream, Edad), write(Stream, ', '),
    write(Stream, Genero), write(Stream, ', '),
    write(Stream, NumTorta), write(Stream, ', '),
    write(Stream, Acepta), write(Stream, ', '),
    write(Stream, '\''), write(Stream, Motivo),
    write(Stream, '\''), write(Stream, ', '),
    write(Stream, Precio),
    write(Stream, ').'), nl(Stream),
    close(Stream).

%Guarda una torta en archivo y la agrega al sistema
registrar_torta(Num, Nombre) :-
    assertz(torta(Num, Nombre)),
    guardar_torta_a_archivo(Num, Nombre).
guardar_torta_a_archivo(Num, Nombre) :-
    open('nuevas_tortas.pl', append, Stream),
    write(Stream, 'torta('),
    write(Stream, Num), write(Stream, ', '),
    write(Stream, '\''), write(Stream, Nombre), write(Stream, '\''),
    write(Stream, ').'), nl(Stream),
    close(Stream).


