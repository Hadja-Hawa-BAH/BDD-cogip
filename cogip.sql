-- Modèle pour implementer une fonction
-- 1. Analysez le code de la fonction et essayez de comprendre chacun de ses
-- éléments.

-- CREATE OR REPLACE FUNCTION <nom-fonction>(<paramètres>)
-- RETURNS <type-de-retour>
-- LANGUAGE plpgsql -- langage procédural utilisé, ici plpgsql
-- AS $$ -- "AS" indique le début de la définiton de la fonction
-- declare -- la partie "declare" permet de déclarer toutes les variables utilisées
-- dans le block délimité par "BEGIN-END"
-- <nom-variable> <type-variable>;
-- begin
-- -- ici le code de la fonction
-- -- ce code doit retourner une valeur en accord avec le type de retour de la
-- fonction
-- END;
-- $$

-- 2. Utilisez la nouvelle fonction dans une requête permettant d’afficher toutes les
-- commandes avec un tiret (‘-‘) utilisé en tant que séparateur
select format_date('2023/02/01', '-'); 
select format_date('2023-02-01', '-');

-- 3. Analysez et testez le code, comment est effectuée l’affectation de la variable
-- « items_count » ?
select get_items_count();

-- 4. Implémentez une fonction qui répond au besoin.
CREATE OR REPLACE FUNCTION count_items_to_order()
RETURNS integer
LANGUAGE plpgsql
AS $$
declare
count_alert_items integer;
time_now time = now();
begin
select count(*)
into count_alert_items
from item
where stock < stock_alert;
raise notice '% articles à %', count_alert_items, time_now;
return count_alert_items;
END;
$$

-- requête pour tester le fonction
select count_items_to_order();

-- 5. Implémentez une fonction qui répond au besoin.
CREATE OR REPLACE FUNCTION best_supplier()
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
declare
best_supplier_id varchar(50);
best_supplier_name varchar(50);
begin
select s.name, o.supplier_id
into best_supplier_id, best_supplier_name
from "order" o
join supplier s on o.supplier_id = s.id
order by s.name desc
limit 1;
raise notice '% articles à %', best_supplier_id, best_supplier_name;
return best_supplier_id;
END;
$$

-- requête de test
select best_supplier();

-- 2.7 FONCTION « SATISFACTION_STRING »
CREATE OR REPLACE function satisfaction_string(satisfaction_index int)
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
declare
	result_string varchar(50);
begin
result_string = case
when satisfaction_index is null then 'Sans commentaires'
when satisfaction_index = 1 or satisfaction_index = 2 then 'Mauvais'
when satisfaction_index = 3 or satisfaction_index = 4 then 'Passable'
when satisfaction_index = 5 or satisfaction_index = 6 then 'Moyen'
when satisfaction_index = 7 or satisfaction_index = 8 then 'Bon'
else 
 'Excellent'
end;

return result_string;
END;
$$

-- requête de test
select satisfaction_string(9);
