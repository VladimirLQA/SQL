В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных».
 Установить текущую дату в качестве даты выполнения попытки.

INSERT INTO attempt (student_id, subject_id, date_attempt)
    SELECT (SELECT student_id FROM student WHERE name_student = 'Баранов Павел'),
            (SELECT subject_id FROM subject WHERE name_subject = 'Основы баз данных'),
            NOW();          
    SELECT * FROM attempt;

 /*Second option with join*/

INSERT INTO attempt(student_id, subject_id, date_attempt)
    SELECT student_id, subject_id, NOW()
        FROM  student, subject
            WHERE name_student = 'Баранов Павел' and name_subject = 'Основы баз данных';
    SELECT * FROM attempt;

---------------------------------------------------------------------------------------------------------------------------------------

Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается 
проходить студент, занесенный в таблицу attempt последним, и добавить их в таблицу testing.id
последней попытки получить как максимальное значение id из таблицы attempt.

INSERT INTO testing (attempt_id, question_id)
    SELECT attempt_id, question_id
        FROM question
            JOIN attempt USING (subject_id)
                WHERE attempt_id = (SELECT MAX(attempt_id) FROM attempt) 
                    ORDER BY RAND()
                        LIMIT 3;
    SELECT * FROM testing;

---------------------------------------------------------------------------------------------------------------------------------------

Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо
вычислить результат(запрос) и занести его в таблицу attempt для соответствующей попытки.
Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов
в каждой попытке) и умноженное на 100. Результат округлить до целого.
Будем считать, что мы знаем id попытки,  для которой вычисляется результат, в нашем случае это 8.

UPDATE attempt
    SET result = (SELECT ROUND(SUM(is_correct)/3 * 100, 0) 
                  FROM answer
                     JOIN testing USING (answer_id)
                         WHERE attempt_id = 8)
        WHERE attempt_id = 8;
SELECT * FROM attempt;

/*Not my solution, but interesting one*/

SET @last_attempt = (SELECT MAX(attempt_id) FROM attempt);
SET @last_result = (
        SELECT ROUND(AVG(is_correct)*100, 0) AS result
        FROM testing
        JOIN answer USING(answer_id)
        WHERE attempt_id = @last_attempt);

UPDATE attempt
    SET result = @last_result
        WHERE attempt_id = @last_attempt

---------------------------------------------------------------------------------------------------------------------------------------
