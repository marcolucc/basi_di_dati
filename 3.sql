/*
Esercizio 1 Trovare nome, cognome dei docenti che nell’anno accademico 2010/2011 hanno tenuto lezioni in almeno due corsi di studio (vale a dire hanno 
tenuto almeno due insegnamenti o moduli A e B dove A è del corso C1 e B è del corso C2 dove C1 6= C2). 
*/
select distinct p.id,p.nome,p.cognome
from persona p join docenza d1 on d1.id_persona= p.id
				join docenza d2 on d2.id_persona=p.id
				join inserogato ie1 on ie1.id=d1.id_inserogato
				join inserogato ie2 on ie2.id=d2.id_inserogato
where ie1.annoaccademico='2010/2011' and
	ie2.annoaccademico='2010/2011' and
	ie2.id_corsostudi<>ie1.id_corsostudi
order by p.id
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
select p.id, p.nome, p.cognome
from persona p
where p.id in(
    select p.id
    from InsErogato ie join Docenza d on ie.id = d.id_inserogato 
        join Persona p on d.id_persona = p.id
        join CorsoStudi cs on ie.id_corsostudi = cs.id
    where ie.annoaccademico = '2010/2011'
    group by p.id
    having count(distinct cs.id) >= 2
)
order by p.id;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CREATE TEMP VIEW ES1 AS 
	SELECT P.id AS idPersona, P.nome, P.cognome, CS.id AS idCorso
		FROM Persona P 
		JOIN Docenza D ON(P.id = D.id_persona)
		JOIN InsErogato I ON(D.id_inserogato = I.id)
		JOIN CorsoStudi CS ON(I.id_corsostudi = CS.id)
	WHERE I.annoaccademico = '2010/2011'
	GROUP BY (P.id, P.nome, P.cognome, CS.id);

SELECT idPersona, nome, cognome
FROM ES1
GROUP BY (idPersona, nome, cognome)
HAVING COUNT(idPersona)>= 2
ORDER BY idPersona
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 2 Trovare nome, cognome e telefono dei docenti che hanno tenuto nel 2009/2010 un’occorrenza di insegnamento che non sia un’unità logistica
del corso di studi con id=4 ma che non hanno mai tenuto un modulo dell’insegnamento di ’Programmazione’ del medesimo corso di studi. 
*/
select p.id,p.nome,p.cognome,p.telefono
from persona p 
where p.id in (
	select d.id_persona
	from docenza d join inserogato ie on ie.id=d.id_inserogato
	where ie.annoaccademico='2009/2010'  and ie.id_corsostudi=4
)
and p.id not in (select d.id_persona
	from docenza d join inserogato ie on ie.id=d.id_inserogato
				 join insegn i on ie.id_insegn=i.id
	where ie.annoaccademico='2009/2010' and ie.id_corsostudi=4 and i.nomeins = 'Programmazione'  )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SELECT DISTINCT p.id, p.nome, p.cognome, p.telefono
FROM persona p, docenza d1, inserogato ie1
WHERE p.id=d1.id_persona AND ie1.id=d1.id_inserogato AND ie1.annoaccademico='2009/2010' AND ie1.id_corsostudi=4
      AND NOT EXISTS(
        SELECT 1
        FROM docenza d2,inserogato ie2
        WHERE p.id=d2.id_persona AND ie2.id=d2.id_inserogato AND ie2.id_corsostudi=ie1.id_corsostudi AND ie2.nomemodulo ILIKE '%programmazione%'
      )
ORDER BY p.id;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 3 Trovare identiﬁcatore, nome e cognome dei docenti che, nell’anno accademico 2010/2011, hanno tenuto un insegnamento (l’attributo da 
confrontare è nomeins) che non hanno tenuto nell’anno accademico precedente. Ordinare la soluzione per nome e cognome. 
*/
select distinct p.id,p.nome,p.cognome
from persona p 
where p.id in (select d.id_persona
			  from docenza d join inserogato ie on ie.id=d.id_inserogato
			   	join insegn i on i.id=ie.id_insegn
			  where ie.annoaccademico='2010/2011'
			  	and i.nomeins not in (select i2.nomeins
										from inserogato ie2 join insegn i2 on i2.id=ie2.id_insegn
										where d.id_inserogato=ie2.id
											and ie2.annoaccademico='2009/2010'))
order by p.id
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 4
Trovare per ogni periodo di lezione del 2010/2011 la cui descrizione inizia con ’I semestre’ o ’Primo semestre’
il numero di occorrenze di insegnamento allocate in quel periodo. Si visualizzi quindi: l’abbreviazione, il
discriminante, inizio, fine e il conteggio richiesto ordinati rispetto all’inizio e fine.
La soluzione ha 3 righe:
*/
SELECT      PD.descrizione, PD.discriminante, PD.inizio, PD.fine, COUNT(*)
FROM        periododid PD
			JOIN insinperiodo IP ON PD.id = IP.id_periodolez
WHERE       PD.annoaccademico = '2010/2011'
			AND (PD.descrizione ilike 'I semestre%' OR PD.descrizione ilike 'Primo semestre%')
GROUP BY	PD.descrizione, PD.discriminante, PD.inizio, PD.fine
ORDER BY	PD.inizio, PD.fine;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 5
Trovare, per ogni facoltà, il numero di unità logistiche erogate (modulo < 0) e il numero corrispondente di
crediti totali erogati nel 2010/2011, riportando il nome della facoltà e i conteggi richiesti. Usare pure la
relazione diretta tra InsErogato e Facolta.
La soluzione ha 8 righe. La riga relativa a ’Medicina e Chirurgia’ ha valori 253 e 979,50.
*/
SELECT          F.nome, COUNT(*) AS totUnitaLogistiche, SUM(IE.crediti) as totCrediti
FROM            INSEROGATO IE
                JOIN FACOLTA F ON IE.id_facolta = F.id
WHERE           IE.annoaccademico = '2010/2011'
                AND IE.modulo < 0
GROUP BY        F.id, F.nome;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 6
Trovare i corsi di studio che non sono gestiti dalla facoltà di “Medicina e Chirurgia” e che hanno insegnamenti
erogati con moduli nel 2010/2011. Si visualizzi il nome del corso e il numero di insegnamenti erogati con
moduli nel 2010/2011.
Soluzione: ci sono 33 righe
*/
SELECT DISTINCT cs.nome, count(*)
     FROM corsostudi cs
     JOIN inserogato i ON cs.id = i.id_corsostudi
     WHERE cs.id NOT IN (
          SELECT i1.id
               FROM corsostudi i1
                    JOIN corsoinfacolta c2 ON i1.id = c2.id_corsostudi
                    JOIN facolta f ON c2.id_facolta = f.id
               WHERE f.nome ILIKE 'medicina e chirurgia'
     )
           AND i.annoaccademico = '2010/2011'
           AND i.modulo = 0
           AND i.hamoduli <> '0'
     GROUP BY cs.id, cs.nome
     ORDER BY cs.nome;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 7
Trovare gli insegnamenti del corso di studi con id=4 che non sono mai stati offerti al secondo quadrimestre.
Per selezionare il secondo quadrimestre usare la condizione "abbreviazione LIKE '2%'".
La soluzione ha 14 righe
*/
select distinct ie.id_insegn
from inserogato ie 
where ie.id_corsostudi =4 and ie.id_insegn not in (select ie.id_insegn
						  from insinperiodo l join periodolez pl on pl.id=l.id_periodolez join inserogato ie on ie.id=l.id_inserogato
						  where pl.abbreviazione like '2%' and ie.id_corsostudi=4)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 8
Trovare, per ogni facoltà, il docente che ha tenuto il numero massimo di ore di lezione nel 2009/2010, riportando
il cognome e il nome del docente e la facoltà. Per la relazione tra InsErogato e Facolta usare la relazione
diretta.
La soluzione ha 10 righe.
*/
create temp view conti as
select p.cognome,p.nome,f.nome as nomef,sum(d.orelez) as ore
from persona p join docenza d on d.id_persona =p.id
				join inserogato ie on ie.id=d.id_inserogato
				join facolta f on f.id=ie.id_facolta
where ie.annoaccademico='2009/2010'
group by p.cognome,p.nome,f.nome;

select c.cognome,c.nome,c.nomef, c.ore
from conti c
where c.ore>= (select max (c1.ore)
				 from conti c1
				 where c1.nomef=c.nomef)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 9
Trovare gli insegnamenti (esclusi i moduli e le unità logistiche) del corso di studi con id=240 erogati nel
2009/2010 e nel 2010/2011 che non hanno avuto docenti di nome ’Roberto’, ’Alberto’, ’Massimo’ o ’Luca’
in entrambi gli anni accademici, riportando il nome, il discriminante dell’insegnamento, ordinati per nome
insegnamento.
La soluzione ha 22 righe.
*/
create temp view conti as
select ie.annoaccademico,i.nomeins,di.nome
from inserogato ie join insegn i on i.id=ie.id_insegn
					join discriminante di on di.id=ie.id_discriminante
					join docenza d on d.id_inserogato=ie.id
					join persona p on d.id_persona=p.id
where p.nome not in ('Roberto','Alberto','Massimo','Luca') and ie.modulo='0' and ie.id_corsostudi=240;

select c.nomeins,c.nome
from conti c
where c.annoaccademico='2009/2010' intersect (select c.nomeins,c.nome
from conti c
where c.annoaccademico='2010/2011') 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 10
Trovare le unità logistiche del corso di studi con id=420 erogati nel 2010/2011 e che hanno lezione o il
lunedì (Lezione.giorno=2) o il martedì (Lezione.giorno=3), ma non in entrambi i giorni, riportando il nome
dell’insegnamento e il nome dell’unità ordinate per nome insegnamento.
La soluzione ha 8 righe
*/
select distinct i.nomeins, ie.nomeunita
from inserogato ie join insegn i on i.id=ie.id_insegn
					join lezione l on l.id_inserogato=ie.id
where ie.id_corsostudi=420 and 
		ie.modulo<'0' and
		ie.annoaccademico='2010/2011'
		and ((l.giorno =2 and not exists (select 1 from lezione l2 where l2.id_inserogato=ie.id and l2.giorno =3)) or
		(l.giorno =3 and not exists (select 1 from lezione l2 where l2.id_inserogato=ie.id and l2.giorno =2))
		)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 11
Trovare il nome dei corsi di studio che non hanno mai erogato insegnamenti che contengono nel nome la stringa
’matematica’ (usare ILIKE invece di LIKE per rendere il test non sensibile alle maiuscole/minuscole).
La soluzione ha 572 righe.
*/
select c.nome
from corsostudi c 
where c.id not in (select ie.id_corsostudi
				  from inserogato ie join insegn i on i.id=ie.id_insegn
				  where i.nomeins ilike '%matematica%')
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 12
Trovare gli insegnamenti (esclusi moduli e unità logistiche) dei corsi di studi della facoltà di ’Scienze Matematiche Fisiche e Naturali’ che sono stati tenuti dallo stesso docente per due anni accademici consecutivi
riportando il nome dell’insegnamento, il nome e il cognome del docente.
Per la relazione tra InsErogato e Facolta non usare la relazione diretta.
Circa la condizione sull’anno accademico, dopo aver estratto una sua opportuna parte, si può trasformare questa in un intero e, quindi, usarlo per gli opportuni controlli. Oppure si può usarla direttamente confrontandola
con un’opportuna parte dell’altro anno accademico.
La soluzione ha 535 righe. 
*/
CREATE TEMP VIEW conti AS(
	SELECT I.nomeins AS insegnname, P.nome AS nomeP, P.cognome AS cognomeP, CAST(Substring(IE.annoaccademico FROM 6 for 4)AS INTEGER)  as anno
	FROM Insegn I 
		JOIN InsErogato IE ON (I.id = IE.id_insegn)
		JOIN Facolta F ON(IE.id_facolta = F.id)
		JOIN Docenza D ON(IE.id = D.id_inserogato)
		JOIN Persona P ON(D.id_persona = P.id)
	WHERE F.nome ILIKE 'Scienze Matematiche Fisiche e Naturali'
	AND IE.modulo = 0
	ORDER BY nomeins, anno
);

SELECT DISTINCT c.insegnname, c.nomeP, c.cognomeP
FROM conti c
	JOIN conti c1 ON(c.insegnname = c1.insegnname AND c.nomeP = c1.nomeP AND c.cognomeP = c1.cognomeP)
WHERE c.anno - c1.anno = 1
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 13
Trovare per ogni segreteria che serve almeno un corso di studi il numero di corsi di studi serviti, riportando il
nome della struttura, il suo numero di fax e il conteggio richiesto.
La soluzione ha 42 righe.
*/
select s.nomestruttura,s.fax,count(c.id) as n
from strutturaservizio s join corsostudi c on s.id=c.id_segreteria
group by s.nomestruttura,s.fax
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 14
Considerando solo l’anno accademico 2010/2011, trovare i docenti che hanno insegnato per un numero totale
di crediti di lezione maggiore della media dei crediti totali insegnati (lezione) da tutti i docenti nell’anno
accademico. I crediti insegnati sono specificati nella tabella Docenza. Per calcolare la somma o la media, si
devono considerare solo le ’docenze’ che hanno creditilez significativi e diversi da 0 (per rendere la selezione
un po’ più significativa).
Come controllo intermedio, la media è ~13.509. La soluzione ha 517 righe
*/
create temp view conti as 
select p.id,p.nome,p.cognome,sum(d.creditilez) as cred
from persona p join docenza d on d.id_persona=p.id
				join inserogato ie on ie.id=d.id_inserogato
where ie.annoaccademico='2010/2011' and d.creditilez<>0
group by p.id,p.nome,p.cognome;


select p.id,p.nome,p.cognome
from conti p
where p.cred>(select avg(c.cred)
				   from conti c
				   )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Esercizio 15
Trovare per ogni docente il numero di insegnamenti o moduli o unità logistiche a lui assegnate come docente
nell’anno accademico 2005/2006, riportare anche coloro che non hanno assegnato alcun insegnamento. Nel
risultato si mostri identificatore, nome e cognome del docente insieme al conteggio richiesto (0 per il caso
nessun insegnamento/modulo/unità insegnati).
La soluzione ha 3315 righe.
*/
create temp view conti as
select p.id,p.nome,p.cognome,count(ie.id_insegn) as num
from persona p join docenza d on d.id_persona=p.id
				join inserogato ie on ie.id=d.id_inserogato
where ie.annoaccademico='2005/2006'
group by p.id,p.nome,p.cognome;

select p.id,p.nome,p.cognome,0 as num
from persona p join docenza d on d.id_persona =p.id
except 
select c1.id,c1.nome,c1.cognome,0 as num
from conti c1
union 
select c2.id,c2.nome,c2.cognome,c2.num
from conti c2 