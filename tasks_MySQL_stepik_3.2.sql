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

