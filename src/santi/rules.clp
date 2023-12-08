;Funcio que implenta la pregunta per llegir un int
(deffunction ask-int (?question)
	(printout t ?question)
	(bind ?answer (read))
	(while (lexemep ?answer) do
		(printout t ?question)
		(bind ?answer (read))
		)
	(integer ?answer))


;Funcio que implenta la pregunta per llegir un string
(deffunction stringg-question (?question)
	(format t "%s" ?question)
	(bind ?answer (read))
	?answer
)

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer)
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer)
          then (bind ?answer (lowcase ?answer))))
   ?answer
)

;Funcio que implenta la pregunta de tipus si o no (booleana)
(deffunction pregunta-si-no (?question)
	(format t "%s [s/n] " ?question)
	(bind ?response (read))
	(while (not(or(eq ?response s)(eq ?response n))) do
		(printout t ?question)
		(bind ?response (read))
	)
	(if (eq ?response s)
		then TRUE
		else FALSE)
)

;;; Funcion para hacer una pregunta multi-respuesta con indices
(deffunction pregunta-multi (?pregunta $?valores-posibles)
    (bind ?linea (format nil "%s" ?pregunta))
    (printout t ?linea crlf)
    (progn$ (?var ?valores-posibles)
            (bind ?linea (format nil "  %d. %s" ?var-index ?var))
            (printout t ?linea crlf)
    )
    (format t "%s" "Indica los numeros separados por un espacio: ")
    (bind ?resp (readline))
    (bind ?numeros (str-explode ?resp))
    (bind $?lista (create$ ))
    (progn$ (?var ?numeros)
        (if (and (integerp ?var) (and (>= ?var 1) (<= ?var (length$ ?valores-posibles))))
            then
                (if (not (member$ ?var ?lista))
                    then (bind ?lista (insert$ ?lista (+ (length$ ?lista) 1) ?var))
                )
        )
    )
    ?lista
)


;;INICIO DEL PROGRAMA

(defglobal
   ?*allok* = TRUE
)

(defmodule MAIN (export ?ALL))

(deftemplate MAIN::preferencias
	;(multislot epocas (type INSTANCE))
	(multislot temas (type INSTANCE))
	(multislot autores (type INSTANCE))
	(multislot generos (type INSTANCE))
)


(defrule initial
    (initial-fact)
    =>
    (printout t "----BIENVENIDOS AL SISTEMA DE RECOMENDACION DE LIBROS----" crlf)
    (printout t crlf)
    (assert(newLector))
    (focus PREGUNTAS)
)

;Aqui estan las preguntas
(defmodule PREGUNTAS (export ?ALL) (import MAIN ?ALL))


(defrule PREGUNTAS::askNombre
	(newLector)
	=>
	(bind ?nombre (stringg-question "Como te llamas? "))
	(bind ?x (make-instance ?nombre of Lector))
	(send ?x put-nombre ?nombre)
)

(defrule PREGUNTAS::askEdad
	(newLector)
    ?x <- (object(is-a Lector))
	=>
	(bind ?edad (ask-int "Cuantos años tienes? "))
	;(if (> ?age 0) then (printout t crlf "Lo sentimos, no cumples con los requisitos de edad" crlf)(exit))
    (send ?x put-edad ?edad)
)

(defrule PREGUNTAS::askSexo
	(newLector)
    ?x <- (object(is-a Lector))
	=>
	(bind ?sexo (ask-int "Sexo: Mujer(0) o Hombre(1) "))
    (send ?x put-sexo ?sexo)
)



(defrule PREGUNTAS::askGenero1
    (newLector)
	?pref <- (preferencias)
	=>
	(bind ?f (pregunta-si-no "Esta interesado en algun(os) genero(os) en concreto?"))
	(if (eq ?f TRUE)
	then (bind $?obj-generos (find-all-instances ((?inst Genero)) TRUE))
	(bind $?nom-generos (create$ ))
	(loop-for-count (?i 1 (length$ $?obj-generos)) do
		(bind ?curr-obj (nth$ ?i ?obj-generos))
		(bind ?curr-nom (send ?curr-obj get-nombre))
		(bind $?nom-generos(insert$ $?nom-generos (+ (length$ $?nom-generos) 1) ?curr-nom))
	)
	(bind ?escogido (pregunta-multi "Escoja los generos en los que esta interesado: " $?nom-generos))

	(bind $?respuesta (create$ ))
	(loop-for-count (?i 1 (length$ ?escogido)) do
		(bind ?curr-index (nth$ ?i ?escogido))
		(bind ?curr-atr (nth$ ?curr-index ?obj-generos))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(modify ?pref (generos $?respuesta))
	)
)

(defrule PREGUNTAS::askGenero2
	(if (eq ?f TRUE)
    (newLector)
	?pref <- (preferencias)
	=>
	(bind ?e (pregunta-si-no "Esta interesado en un segundo genero?"))
	(if (eq ?e TRUE)
	then (bind $?obj-generos (find-all-instances ((?inst Genero)) TRUE))
	(bind $?nom-generos (create$ ))
	(loop-for-count (?i 1 (length$ $?obj-generos)) do
		(bind ?curr-obj (nth$ ?i ?obj-generos))
		(bind ?curr-nom (send ?curr-obj get-nombre))
		(bind $?nom-generos(insert$ $?nom-generos (+ (length$ $?nom-generos) 1) ?curr-nom))
	)
	(bind ?escogido (pregunta-multi "Escoja los generos en los que esta interesado: " $?nom-generos))

	(bind $?respuesta (create$ ))
	(loop-for-count (?i 1 (length$ ?escogido)) do
		(bind ?curr-index (nth$ ?i ?escogido))
		(bind ?curr-atr (nth$ ?curr-index ?obj-generos))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(modify ?pref (generos $?respuesta))
	)
	)
)

(defrule PREGUNTAS::askTema1
    (newLector)
	?pref <- (preferencias)
	=>
	(bind ?e2 (pregunta-si-no "Esta interesado en algun tema en concreto?"))
	(if (eq ?e2 TRUE)
	then (bind $?obj-temas (find-all-instances ((?inst Tema)) TRUE))
	(bind $?nom-temas (create$ ))
	(loop-for-count (?i 1 (length$ $?obj-temas)) do
		(bind ?curr-obj (nth$ ?i ?obj-temas))
		(bind ?curr-nom (send ?curr-obj get-nombre))
		(bind $?nom-temas(insert$ $?nom-temas (+ (length$ $?nom-temas) 1) ?curr-nom))
	)
	(bind ?escogido (pregunta-multi "Escoja los temas en los que esta interesado: " $?nom-temas))

	(bind $?respuesta (create$ ))
	(loop-for-count (?i 1 (length$ ?escogido)) do
		(bind ?curr-index (nth$ ?i ?escogido))
		(bind ?curr-atr (nth$ ?curr-index ?obj-temas))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(modify ?pref (temas $?respuesta))
	)
)

(defrule PREGUNTAS::askTema2
	(if (eq ?e2 TRUE)
    (newLector)
	?pref <- (preferencias)
	=>
	(bind ?e3 (pregunta-si-no "Esta interesado un segundo tema"))
	(if (eq ?e3 TRUE)
	then (bind $?obj-temas (find-all-instances ((?inst Tema)) TRUE))
	(bind $?nom-temas (create$ ))
	(loop-for-count (?i 1 (length$ $?obj-temas)) do
		(bind ?curr-obj (nth$ ?i ?obj-temas))
		(bind ?curr-nom (send ?curr-obj get-nombre))
		(bind $?nom-temas(insert$ $?nom-temas (+ (length$ $?nom-temas) 1) ?curr-nom))
	)
	(bind ?escogido (pregunta-multi "Escoja los temas en los que esta interesado: " $?nom-temas))

	(bind $?respuesta (create$ ))
	(loop-for-count (?i 1 (length$ ?escogido)) do
		(bind ?curr-index (nth$ ?i ?escogido))
		(bind ?curr-atr (nth$ ?curr-index ?obj-temas))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(modify ?pref (temas $?respuesta))
	)
	(focus RESPUESTA)
	)
)

(deffacts PREGUNTAS::hechos-iniciales "Establece hechos para poder recopilar informacion"
	(preferencias)
)


;Aqui estan las abstracciones
(defmodule ABSTRACCION (import MAIN ?ALL)(import PREGUNTAS ?ALL)(export ?ALL))

;Aqui estan las infirencias
(defmodule INFERENCIA (import MAIN ?ALL) (import PREGUNTAS ?ALL)(import ABSTRACCION ?ALL)(export ?ALL))


(defrule INFERENCIA::elecciones
	?u <- (preferencias (generos $?generos)(autores $?autores)(temas $?temas))
	?lector <- (object (is-a Lector))
	=>
	(bind $?respuesta (create$ ))
	(loop-for-count (?i 1 (length$ $?epocas)) do
		(bind ?curr-atr (nth$ ?i $?epocas))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(loop-for-count (?i 1 (length$ $?autores)) do
		(bind ?curr-atr (nth$ ?i $?autores))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(loop-for-count (?i 1 (length$ $?temas)) do
		(bind ?curr-atr (nth$ ?i $?temas))
		(bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(loop-for-count (?i 1 (length$ $?generos)) do
		(bind ?curr-atr (nth$ ?i $?generos))
		(bind $?respuesta(insert$ $?generos (+ (length$ $?respuesta) 1) ?curr-atr))
	)
	(send ?lector put-prefiere $?respuesta)
)

(defrule INFERENCIA::anadir-libro "si cumple alguna de las preferencias se anade"
	?lector <- (object (is-a Lector))
	=>
	(bind $?lector-pref (send ?lector get-prefiere))
	(bind $?libros (create$ ))
	(loop-for-count (?i 1 (length$ $?lector-pref)) do
		(bind ?curr-pref (nth$ ?i $?lector-pref))
		(bind $?curr-pref-libros (send ?curr-pref get-tiene_obra))
		(loop-for-count (?i 1 (length$ $?curr-pref-cuadros)) do
			(bind ?curr-pref-cuadros-cuadro (nth$ ?i ?curr-pref-cuadros))
			(if (not (member$ ?curr-pref-cuadros-cuadro $?cuadros))
				then (bind $?cuadros(insert$ $?cuadros (+ (length$ $?cuadros) 1) ?curr-pref-cuadros-cuadro))
			)
		)
	)
	(assert (lista-cuadros (nombre "recomendadas") (recomendaciones $?cuadros)))
)

;Aqui estan las asignaciones
(defmodule ASSIGNACIO (import MAIN ?ALL) (import PREGUNTAS ?ALL)(import INFERENCIA ?ALL)(import ABSTRACCION ?ALL)(export ?ALL))

;Aqui esta la respuesta
(defmodule RESPUESTA (import MAIN ?ALL) (import PREGUNTAS ?ALL)(import ABSTRACCION ?ALL)(import INFERENCIA ?ALL)(import ASSIGNACIO ?ALL)(export ?ALL))

(defrule RESPUESTA::printRecomendacion
	(newLector)
	=>
	(printout t crlf)
	(printout t "A partir de tus gustos y caracteriseticas te recomendamos: " crlf)
	(printout t crlf)

)