 Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. 
 Информацию вывести по убыванию результатов тестирования.

 SELECT name_student, date_attempt, result FROM student
    JOIN attempt USING (student_id)
    JOIN subject USING (subject_id)
        WHERE name_subject = 'Основы баз данных'
            ORDER BY result DESC

---------------------------------------------------------------------------------------------------------------------------------------

Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, 
который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных ответов на вопросы теста, 
который занесен в столбец result.  В результат включить название дисциплины, а также вычисляемые столбцы Количество и Среднее. 
Информацию вывести по убыванию средних результатов.


SELECT name_subject, COUNT(date_attempt) AS Количество, ROUND(AVG(result), 2) AS Среднее FROM subject
    LEFT JOIN attempt USING (subject_id)
        GROUP BY name_subject
        ORDER BY 3 DESC

/*Second option*/

SELECT DISTINCT name_student, result FROM student 
    JOIN attempt USING(student_id)
        WHERE result >= ALL(SELECT result FROM attempt)
            ORDER BY name_student;
            
---------------------------------------------------------------------------------------------------------------------------------------

Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой 
и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. 
Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать.

SELECT name_student, name_subject, DATEDIFF(MAX(date_attempt), MIN(date_attempt)) as Интервал
    FROM student
        JOIN attempt USING (student_id)
        JOIN subject USING (subject_id)
    GROUP BY name_student, name_subject
        HAVING COUNT(date_attempt) > 1
            ORDER BY 3 

---------------------------------------------------------------------------------------------------------------------------------------

Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование.
Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины,
тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.

SELECT name_subject, COUNT(DISTINCT student_id) as Количество 
    FROM subject 
        LEFT JOIN attempt USING (subject_id)
    GROUP BY name_subject
        ORDER BY Количество DESC, name_subject

---------------------------------------------------------------------------------------------------------------------------------------

Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». 
В результат включите столбцы question_id и name_question.

SELECT question_id, name_question
    FROM subject 
        JOIN question USING (subject_id)
    ORDER BY RAND()
        LIMIT 3

-------------------------------------------------------------------------------------------------------------------------------------

Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине 
«Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7). 
Указать, какой ответ дал студент и правильный он или нет(вывести Верно или Неверно). 
В результат включить вопрос, ответ и вычисляемый столбец  Результат.

SELECT name_question, name_answer, IF(is_correct = 1, 'Верно', 'Неверно') AS Результат
    FROM testing 
        JOIN answer USING(answer_id)
        JOIN question ON testing.question_id = question.question_id
        JOIN subject USING(subject_id)
        JOIN attempt USING(attempt_id)
        JOIN student USING(student_id)
            WHERE attempt.date_attempt = DATE('2020-05-17') AND
                  student.name_student = 'Семенов Иван' AND
                  subject.name_subject = 'Основы SQL';

/*Second option with subqueries*/

SELECT name_question, name_answer, IF(is_correct, 'Верно', 'Неверно') Результат
    FROM testing 
        JOIN question USING (question_id)
        JOIN answer USING (answer_id)
    WHERE attempt_id = (SELECT attempt_id
                            FROM attempt
                                WHERE date_attempt = '2020-05-17' AND
                                    student_id = (SELECT student_id FROM student WHERE name_student = 'Семенов Иван') AND
                                    subject_id = (SELECT subject_id FROM subject WHERE name_subject = 'Основы SQL'));

-------------------------------------------------------------------------------------------------------------------------------------

Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов,
 деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. 
 Результат округлить до двух знаков после запятой. Вывести фамилию студента, название предмета,
  дату и результат. Последний столбец назвать Результат. Информацию отсортировать сначала по фамилии
   студента, потом по убыванию даты попытки.

SELECT name_student, name_subject, date_attempt, ROUND( SUM( is_correct/3*100 ), 2) AS 'Результат'
    FROM answer 
        JOIN testing USING(answer_id)
        JOIN attempt USING(attempt_id)
        JOIN subject USING(subject_id)
        JOIN student USING(student_id)
            GROUP BY name_student, name_subject, date_attempt
                ORDER BY name_student, date_attempt DESC

-------------------------------------------------------------------------------------------------------------------------------------

Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов 
к общему количеству ответов, значение округлить до 2-х знаков после запятой. Также вывести название 
предмета, к которому относится вопрос, и общее количество ответов на этот вопрос. В результат включить 
название дисциплины, вопросы по ней (столбец назвать Вопрос), а также два вычисляемых столбца Всего_ответов 
и Успешность. Информацию отсортировать сначала по названию дисциплины, потом по убыванию успешности, 
а потом по тексту вопроса в алфавитном порядке.
Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".

SELECT name_subject, CONCAT(LEFT(name_question, 30), '...') AS 'Вопрос', COUNT(answer_id) AS 'Всего_ответов',
    ROUND(SUM(is_correct) / COUNT(answer_id) * 100, 2) AS 'Успешность'
        FROM subject
            JOIN question  USING(subject_id)
            JOIN testing  USING(question_id)
            JOIN answer  USING(answer_id)
                GROUP BY name_subject, name_question
                ORDER BY 1, 4 DESC, 2 

-------------------------------------------------------------------------------------------------------------------------------------

Вывести 
- всех студентов (ФИО_Студента), если студент ничего не сдавал - вывести ФИО и в других столбцах поставить "-" 
- предметы которые они сдавали (Предмет) 
- дату тестирования (Дата_сдачи) в виде dd.mm.yyyy 
- результат тестирования (Результат) в таком виде "67 %"
Сначала отсортировать по имени студента, потом по дате тестирования

SELECT name_student AS ФИО_Студента, IF (name_subject IS NUll, '-', name_subject) AS Предмет, 
       IF (date_attempt IS NULL, '-', CONCAT (DAY(date_attempt), '.0', MONTH(date_attempt), '.',YEAR(date_attempt))) AS Дата_сдачи, 
       IF (result IS NULL, '-', CONCAT (result, ' %')) AS Результат
            FROM subject INNER JOIN attempt USING (subject_id)
                 RIGHT JOIN student USING (student_id)
                        ORDER BY name_student, date_attempt;

-------------------------------------------------------------------------------------------------------------------------------------

Каждый студент должен сдать устный экзамен по каждому предмету, 
при этом дата экзамена назначается рандомно в пределах июня 2020. 
Сортировать по по имени студентов и по дате по возрастанию 

SELECT name_student, name_subject, DATE_ADD('2020-06-01', INTERVAL FLOOR(RAND()*31) DAY) AS Дата
    FROM student 
        CROSS JOIN subject
            ORDER BY 1, 3;