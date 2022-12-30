Создать таблицу supply:

create table supply (
    supply_id INT primary key auto_increment,
    title varchar (50),
    author varchar (30), 
    price decimal (8,2),
    amount int
);

---------------------------------------------------------------------------------------------------------------------------------------

Занесите в таблицу supply четыре записи:

insert into supply (title, author, price, amount) 
values ('Лирика', 'Пастернак Б.Л.', 518.99,2),
       ('Черный человек', 'Есенин С.А.', 570.20, 6),
       ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
       ('Идиот', 'Достоевский Ф.М.', 360.80, 3);
select * from supply;

---------------------------------------------------------------------------------------------------------------------------------------

Добавить из таблицы supply в таблицу book, все книги, кроме книг, написанных Булгаковым М.А. и Достоевским Ф.М.

insert into book (title, author, price, amount)
select title, author, price, amount from supply
where author NOT IN ("Булгаков М.А.","Достоевский Ф.М.");
select * from book;

---------------------------------------------------------------------------------------------------------------------------------------

В таблице book необходимо скорректировать значение для покупателя в столбце buy таким образом, чтобы оно не превышало количество экземпляров книг, указанных в столбце amount. А цену тех книг, которые покупатель не заказывал, снизить на 10%.

update book 
set price = if(buy = 0, price * 0.9, price),
    buy = if (buy > amount, amount, buy);
select * from book;

---------------------------------------------------------------------------------------------------------------------------------------

Удалить из таблицы supply книги тех авторов, общее количество экземпляров книг которых в таблице book превышает 10.

delete from supply
where author in (select author from book
                	group by author
               		having sum(amount) >= 10);
select * from supply;

---------------------------------------------------------------------------------------------------------------------------------------

Вывести из таблицы trip информацию о командировках тех сотрудников, фамилия которых заканчивается на букву «а», в отсортированном по убыванию даты последнего дня командировки виде. В результат включить столбцы name, city, per_diem, date_first, date_last.

select name, city, per_diem, date_first, date_last from trip
	where name like '%а %'
		order by 5 desc;

---------------------------------------------------------------------------------------------------------------------------------------

Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  
необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. 
А в таблице  supply обнулить количество этих книг. Формула для пересчета цены:
price = (p_1*k_1+p_2*k_2)/(k_1+k_2)
где  p1, p2 - цена книги в таблицах book и supply;
       k1, k2 - количество книг в таблицах book и supply

UPDATE book INNER JOIN author ON book.author_id = author.author_id
            INNER JOIN supply ON supply.author = author.name_author AND book.title = supply.title
SET book.amount = book.amount + supply.amount,
    supply.amount = 0,
    book.price = ((book.price * book.amount) + (supply.price * supply.amount)) / (book.amount + supply.amount)
	WHERE book.price != supply.price;
		SELECT * FROM book;
		SELECT * FROM supply;

---------------------------------------------------------------------------------------------------------------------------------------

Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов. В запросе для отбора авторов использовать полное название жанра, а не его id.

DELETE FROM author
USING 
    author 
    INNER JOIN book ON author.author_id = book.author_id
    
WHERE book.genre_id in (SELECT book.genre_id 
                         		FROM book 
                         			INNER JOIN genre ON book.genre_id = genre.genre_id
                         				WHERE name_genre LIKE 'Поэзия'
                         					GROUP BY book.genre_id );
SELECT * FROM author;
SELECT * FROM book;

---------------------------------------------------------------------------------------------------------------------------------------

Уменьшить количество тех книг на складе, которые были включены в заказ с номером 5.

UPDATE book
    JOIN buy_book USING (book_id)
        SET book.amount = book.amount - buy_book.amount
            WHERE buy_book.buy_id = 5;            
SELECT * FROM book;

---------------------------------------------------------------------------------------------------------------------------------------

Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, 
цену, количество заказанных книг и  стоимость. Последний столбец назвать Стоимость. 
Информацию в таблицу занести в отсортированном по названиям книг виде.

CREATE TABLE buy_pay AS
    SELECT title, name_author, price, buy_book.amount, buy_book.amount*book.price AS Стоимость
        FROM buy_book
    JOIN book USING (book_id)
    JOIN author USING (author_id)
        WHERE buy_book.buy_id = 5
    ORDER BY title;
SELECT * FROM buy_pay;

---------------------------------------------------------------------------------------------------------------------------------------

Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. 
Куда включить номер заказа, количество книг в заказе (название столбца Количество) 
и его общую стоимость (название столбца Итого).  Для решения используйте ОДИН запрос.

CREATE TABLE buy_pay AS
    SELECT buy_id, SUM(buy_book.amount) AS Количество, SUM(buy_book.amount*price) as Итого
        FROM book
    JOIN buy_book USING (book_id)
        GROUP BY buy_id
            HAVING buy_book.buy_id = 5;
SELECT * FROM buy_pay;

---------------------------------------------------------------------------------------------------------------------------------------

В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. 
В столбцы date_step_beg и date_step_end всех записей занести Null.

INSERT INTO buy_step (buy_id, step_id)
    SELECT buy_id, step_id
        FROM step
    CROSS JOIN buy
        WHERE buy.buy_id = 5;
SELECT * FROM buy_step;

/* Second option*/

INSERT INTO buy_step (buy_id, step_id, date_step_beg, date_step_end)
    SELECT 5, step_id, null, null
        FROM step;
SELECT * FROM buy_step;

---------------------------------------------------------------------------------------------------------------------------------------

Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, 
и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату.

UPDATE buy_step 
SET date_step_end = IF(step_id = (SELECT step_id FROM step 
                                  WHERE name_step = "Оплата"), '2020-04-13', date_step_end), 
                                  
  date_step_beg = IF(step_id = (SELECT step_id FROM step 
                                  WHERE name_step = "Упаковка"), '2020-04-13', date_step_beg)
WHERE buy_id = 5;
  
SELECT * FROM buy_step
WHERE buy_id = 5;