/*
Получим общее количество и сумму транзакций для каждого клиента.
*/

SELECT c.ID_client, c.name, COUNT(t.ID_transaction) AS total_count_transaction, SUM(t.summ) AS total_sum
FROM Customers c JOIN Transactions t ON c.ID_client = t.ID_client
GROUP BY c.ID_client, c.name
ORDER BY total_sum DESC
LIMIT 10;

/*
Рассчитаем общую сумму расходов для каждого клиента с его рангом.
*/

WITH Total_Spend AS (
    SELECT c.ID_client, c.name, SUM(t.summ) AS Total_sum_spend
    FROM Customers c LEFT JOIN Transactions t ON c.ID_client = t.ID_client
    GROUP BY c.ID_client, c.name
)

SELECT ID_client, name, Total_sum_spend, RANK() OVER (ORDER BY Total_sum_spend DESC) AS rang
FROM Total_Spend
ORDER BY rang
LIMIT 10;

/*
Представление для получения данных о клиентах и их транзакциях
*/

CREATE VIEW CustomerTransactions AS
SELECT c.name, SUM(t.summ) AS total_income
FROM Customers c JOIN Transactions t ON c.ID_client = t.ID_client
GROUP BY c.name;

SELECT * FROM CustomerTransactions LIMIT 10;

/*
Триггер для обновления минимальной суммы транзакции
*/

CREATE OR REPLACE FUNCTION update_min_transaction()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET min_sum = LEAST(COALESCE(min_sum, NEW.summ), NEW.summ)
    WHERE ID_product = NEW.ID_product;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateMinTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION update_min_transaction();

/*
Трассировка запросов
*/

EXPLAIN ANALYZE
SELECT SUM(summ) AS common_income FROM Transactions LIMIT 10;
