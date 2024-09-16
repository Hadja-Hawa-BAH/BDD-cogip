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

-- 6. Proposez deux fonctions, une basée sur un « if » et une autre sur un « switch-case ».
-- Elles porteront les noms « satisfaction_string_if » et « satisfaction_string_case ».
create or replace
function satisfaction_string_case(satisfaction_index int)
returns varchar(50)
language plpgsql
as $$
declare
	supplier_id int;
	supplier_name varchar(50);
	result_string varchar(50);
begin
	select id, name
	into supplier_id, supplier_name
	from supplier;
result_string = case
	when satisfaction_index is null then 'Sans commentaires'
	when satisfaction_index = 1
	or satisfaction_index = 2 then 'Mauvais'
	when satisfaction_index = 3
	or satisfaction_index = 4 then 'Passable'
	when satisfaction_index = 5
	or satisfaction_index = 6 then 'Moyen'
	when satisfaction_index = 7
	or satisfaction_index = 8 then 'Bon'
	else 
 'Excellent'
end;

return result_string;
end;
$$;

-- 7. Testez vos fonctions, en affichant le niveau de satisfaction des fournisseurs en toutes
-- lettres ainsi que leur identifiant et leur nom grâce à une requête « SELECT ».
select id, name, satisfaction_string_case(satisfaction_index) from supplier s ;

-- fonction if
create or replace
function satisfaction_string_if(satisfaction_index int)
returns varchar(50)
language plpgsql
as $$
declare
supplier_id int;
supplier_name varchar(50);
supplier_note varchar(50);

begin
	select
	id,
	name
	into
	supplier_id,
	supplier_name
from
	supplier;

if satisfaction_index is null then supplier_note :='Sans commentaires';
elsif satisfaction_index = 1
or satisfaction_index = 2 then  supplier_note := 'Mauvais';
	elsif satisfaction_index = 3
or satisfaction_index = 4 then supplier_note := 'Passable';
	elsif satisfaction_index = 5
or satisfaction_index = 6 then supplier_note = 'Moyen';
	elsif satisfaction_index = 7
or satisfaction_index = 8 then supplier_note :='Bon';
else 
 supplier_note := 'Excellent';
end if;

return supplier_note;
end;

$$;
-- 7. Testez vos fonctions, en affichant le niveau de satisfaction des fournisseurs en toutes
-- lettres ainsi que leur identifiant et leur nom grâce à une requête « SELECT ».
select id, name, satisfaction_string_if(satisfaction_index) from supplier s ;

-- 8. Créez la fonction « add_days ».
create or replace
function add_days("date" date, days_to_add int)
returns date 
language plpgsql
as $$
declare
new_date date;

begin
	new_date := "date" +  days_to_add;
raise notice '%', new_date;
return new_date;
end;

$$;

-- test
select add_days('2023-10-10', 5);

-- fonction pour la BDD
create or replace
function add_days_date("date" date, days_to_add varchar)
returns date 
language plpgsql
as $$
begin
	return "date" +  cast(days_to_add as interval);

end;

$$;

-- test
select o.date + interval '5' from "order" o ;

-- Etape 1 : comptez les articles pour un fournisseur
-- Avant de vous lancer dans l’écriture de votre fonction, écrivez et testez votre requête qui compte les
-- articles.
select count(*) from sale_offer so ;

-- 2.9 FONCTION « COUNT_ITEMS_BY_SUPPLIER »
create or replace
function count_items_by_supplier(supplier_id_param int)
returns int
language plpgsql
as $$
declare
supplier_items_count int;

begin
select count(so.supplier_id)
into supplier_items_count
from sale_offer so
where supplier_id_param = so.supplier_id;

raise notice '%items', supplier_items_count;
return supplier_items_count;

end;

$$;

-- Etape 4 : testez votre fonction
create or replace
function check_supplier_exist(supplier_id_param int)
returns varchar
language plpgsql
as $$
declare
supplier_items_count boolean;

begin
supplier_items_count = exists(select * from supplier s
where s.id = supplier_id_param);

if supplier_items_count = false then
raise exception 'le fournisseur avec l''id % n''existe pas.', supplier_id_param using hint = 'verifiez l''id';

else
raise notice 'le fournisseur avec l''id % existe.', supplier_id_param;
end if;

return supplier_items_count;

end;

$$;
-- requête test
select check_supplier_exist(126);

-- 9. Créez la fonction « sales_revenue », qui en fonction d’un identifiant
-- fournisseur et d’une année entrée en paramètre, restituera le chiffre d’affaires
-- de ce fournisseur pour l’année souhaitée.
create or replace
function sales_revenue(supplier_id_param int, year int)
returns real 
language plpgsql
as $$
declare
total_revenue real := 0;
total_revenue_ttc real;
tva_rate real := 0.20;

begin
select sum(ol.delivered_quantity * ol.unit_price) 
into total_revenue
from order_line ol
join item i on i.id = ol.item_id
join sale_offer so on so.item_id = i.id
where so.supplier_id = supplier_id_param
and extract(year from ol.last_delivery_date) = year;

if total_revenue is null then
total_revenue := 0;
end if;

total_revenue_ttc := total_revenue * (1 + tva_rate); 

raise notice 'le chiffre d''affaires est %', total_revenue_ttc;

return total_revenue_ttc;

end;

$$;

-- test
select sales_revenue(120, 2021);

-- 2.11 FONCTION « GET_ITEMS_STOCK_ALERT »
create or replace
function get_items_stock_alert()
returns table(id int, item_code char(4), "name" varchar(50), stock_difference int) 
language plpgsql
as $$

begin
return query
select i.id, i.item_code, i."name", (i.stock_alert - i.stock) as stock_difference
from item i 
where i.stock < i.stock_alert;

end;

$$;

-- test
select * from get_items_stock_alert();

-- 2.12 PROCEDURE DE CREATION D’UTILISATEUR
CREATE or replace procedure insert_user(email varchar, password varchar, role varchar)
LANGUAGE plpgsql
AS $$ 

begin

if length(password) < 8 then
raise exception 'Le mot de passe doit contenir au moins 8 caractères.';
end if;

if email similar to '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
    RAISE EXCEPTION 'Le format du email n''est pas correct %', email;
        /**USING HINT = 'Vérifiez le format de votre mot de passe.';**/
  END IF ; 

if role not in ('MAIN_ADMIN', 'ADMIN', 'COMMON') then
raise exception 'le role doit être MAIN_ADMIN, ADMIN ou COMMON %', role;
end if;

 INSERT INTO public.user(email, password, role, last_login) VALUES(email, password, role, now());
  raise notice 'Utilisateur a été inséré avec succès.';
end;
$$;

-- test
call insert_user('email@exemple.com', 'motdepasse123','ADMIN');

-- Etape 2 : ajout de la date de dernière connexion
CREATE OR REPLACE function user_connection(user_email varchar, user_password varchar)
RETURNS boolean
LANGUAGE plpgsql
as $function$
declare
user_id_reference int; -- l'identifiant de l'utilisateur récupéré en base de données
user_password_reference varchar; -- le mot de passe de l'utilisateur récupéré en base de données
user_exists boolean; -- un indicateur d'existence de l'utilisateur
hashed_password varchar; -- va contenir le mot de passe haché
begin
-- vérification de l'existence de l'utilisateur
user_exists = exists(select *
from "user" u
where u.email = user_email);
-- si l'utilisateur existe, on vérifie son mot de passe
if user_exists then
-- récupération du mot de passe stocké en
select u."password"
into user_password_reference
from "user" u
where u.email = user_email;
-- calcul du hash du mot de passe passé en paramètre et vérification avec le hash en BDD
hashed_password = encode(digest(user_password, 'sha1'), 'hex');
if hashed_password = user_password_reference then

update "user" 
set last_login = now(), --ajout de la date de dernière connexion 
connexion_attempt = 0 --reinitialisation des tentatives de connexion 
where u.email = user_email;
raise notice 'connexion reussie pour l''utilisateur avec email %', user_email;
return true;

else 
--si le mot de passe est incorrect, on incremente le compteur de tentative
update "user" 
set connexion_attempt = connexion_attempt  + 1
where u.email = user_email;

raise notice 'Le mot de passe est incorrect pour l''utilisateur %', user_email;
return false;
end if;

else 
-- alert pour l'utilisateur s'il n'existe pas 
raise notice 'L''utilisateur ayant pour email % n''existe pas en base de données.',
user_email;
return false;
end if;

end
$function$;

-- test
select user_connection('email@exemple.com', 'motdepasse123');

-- Etape 3 : ajout d’une fonctionnalité de blocage du compte
CREATE OR REPLACE function user_connection(user_email varchar, user_password varchar)
RETURNS boolean
LANGUAGE plpgsql
as $function$
declare
user_id_reference int; -- l'identifiant de l'utilisateur récupéré en base de données
user_password_reference varchar; -- le mot de passe de l'utilisateur récupéré en base de données
user_exists boolean; -- un indicateur d'existence de l'utilisateur
hashed_password varchar; -- va contenir le mot de passe haché
current_attempts int; --va contenir le nombre actuel de tentatives de connexion
is_blocked boolean; --va contenir l'état de blocage de l'utilisateur
begin
-- vérification de l'existence de l'utilisateur
user_exists = exists(select *
from "user" u
where u.email = user_email);
-- si l'utilisateur existe, on vérifie son mot de passe
if user_exists then
-- récupération du mot de passe stocké en
select u."password"
into user_password_reference
from "user" u
where u.email = user_email;
-- calcul du hash du mot de passe passé en paramètre et vérification avec le hash en BDD
hashed_password = encode(digest(user_password, 'sha1'), 'hex');
if hashed_password = user_password_reference then

update "user" 
set last_login = now(), --ajout de la date de dernière connexion 
connexion_attempt = 0 --reinitialisation des tentatives de connexion 
where u.email = user_email;
raise notice 'connexion reussie pour l''utilisateur avec email %', user_email;
return true;

else 
--si le mot de passe est incorrect, on incremente le compteur de tentative
update "user" 
set connexion_attempt = connexion_attempt  + 1
where u.email = user_email;

--recuperation des nouvelles tentatives de connexions après incrémentation 
select connexion_attempt 
into current_attempts
from "user" u 
where u.email = user_email;

--Si 3 tentatives infructueuses, bloquer le compte
if current_attempts >= 3 then
update "user" 
set blocked_account = true
where u.email = user_email;
raise notice 'Le compte de l''utilisateur % a été bloqué après trois tentatives infructueuses', user_email;

else
raise notice 'Le mot de passe est incorrect pour l''utilisateur %', user_email;
end if;

return false;

end if;

else 
-- alert pour l'utilisateur s'il n'existe pas 
raise notice 'L''utilisateur ayant pour email % n''existe pas en base de données.',
user_email;
return false;
end if;

end
$function$;

-- test
select user_connection('email@exemple.com', 'motdepassemotdepasse');

-- 11.Créez un déclencheur de type « before delete » appelant cette nouvelle
-- fonction 
CREATE OR REPLACE FUNCTION public.check_user_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	if old."role" LIKE 'ADMIN' then
		raise exception 'Impossible de supprimer l''utilisateur d''identifiant : %', old.id;
	end if;
	return old;
END;
$function$
;

-- test
DELETE FROM public."user"
	WHERE id=3;

-- 12. Implémentez une fonction ainsi que son déclencheur permettant d’empêcher ce type
-- de suppression.
CREATE OR REPLACE FUNCTION public.check_orderline_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	if old.delivered_quantity < old.ordered_quantity  then
		raise exception 'Impossible de supprimer les enregistrements si les commandes livrées sont supérieures aux commandes commandées: %', old.item_id;
	end if;
	return old;
END;
$function$;

-- trigger
create trigger before_delete_orderline -- "before_insert_supplier" est le nom du déclencheur
before delete -- indication sur le type d'évènement du déclencheur
on public.order_line -- nom de la table concernée
for each row -- quand se déclencher ? ROW ou statement (explication ci-dessous)
execute function check_orderline_delete(); -- appel de la fonction lorsque le déclencheur s'active

--test
delete from order_line where item_id = 4;

-- Etape 2 : création d’une fonction qui à jour la table
CREATE OR REPLACE FUNCTION public.check_item_to_order_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
--si la quantité commandée dans order_line change, mettre à jour item_to_order
update items_to_order
set quantity = quantity + (new.ordered_quantity - old.ordered_quantity), 
date_update = now()
where item_id = new.items_id;

--si l'article n'existe pas dans item_to_order, insérer une nouvelle ligne
if not found then
insert into items_to_order (item_id, quantity, date_update)
values(new.item_id, new.ordered_quantity, now());
end if;

return new;

END;
$function$;


-- Etape 3 : création du déclencheur
create trigger after_update_item_to_order -- "before_insert_supplier" est le nom du déclencheur
after update -- indication sur le type d'évènement du déclencheur
on public.items_to_order -- nom de la table concernée
for each row -- quand se déclencher ? ROW ou statement (explication ci-dessous)
execute function check_item_to_order_update(); -- appel de la fonction lorsque le déclencheur s'active


-- test
update order_line 
set ordered_quantity = 200
where item_id = 4;

-- Etape 4 : empêcher la modification si la valeur est trop faible
-- 13. Ecrivez le code de ce nouveau déclencheur
CREATE OR REPLACE FUNCTION public.prevent_negative_stock()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin

--Verifier si la nouvelle quantité stockée est negative dasn items_to_order
if new.quantity < 0 then
raise exception 'Impossible de mettre à jour. Le stock ne peut être negatif pour l''article % ', new.item_id;
end if;

return old;

END;
$function$;

-- Déclencheurs
create trigger before_update_item_to_order -- "before_insert_supplier" est le nom du déclencheur
before update -- indication sur le type d'évènement du déclencheur
on public.items_to_order -- nom de la table concernée
for each row -- quand se déclencher ? ROW ou statement (explication ci-dessous)
execute function prevent_negative_stock(); -- appel de la fonction lorsque le déclencheur s'active

-- test
update items_to_order 
set quantity = -200
where item_id = 4;

-- 14. Inspirez-vous du code fourni pour créer votre table et développer le déclencheur
-- approprié.
create or replace function public.item_audit_insert_delete_update()
returns trigger
language plpgsql
as $$
begin
	/**Methode insert**/
	if TG_OP = 'INSERT' then
		insert into item_audit(item_id, operation_type, executed_by, operation_time)
		values (new.id, TG_OP, session_user, now());
		return new;

/**Methode delete**/
ELSIF TG_OP = 'DELETE' then
		insert into item_audit(item_id, operation_type, executed_by, operation_time )
		values (old.id, TG_OP, session_user, now());
		return old;
	
/**Methode  update **/
ELSE 
		insert into item_audit(item_id, operation_type, executed_by, operation_time)
		values(old.id, TG_OP, session_user, now());
		return new;
	end if;
end; 
$$;

-- Déclencheur
create trigger after_item_audit_changes after
insert
    or
delete
    or
update
    on
    public.item for each row execute function item_audit_insert_delete_update()

-- test
INSERT INTO public.item (item_code,"name",stock_alert,stock,yearly_consumption,unit)
	VALUES ('60','items1',57,90,34,'unite');

update item 
set "name" = 'items3'
where id = 17;

delete from item where id = 16;


