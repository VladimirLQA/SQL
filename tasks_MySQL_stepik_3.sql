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

