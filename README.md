## Определение cущностей

Проект содержит базу данных, которая спроектирована по схеме 'Звезда'. Были выделены ключевые сущности:

* **Транзакции** (Таблица фактов)
* **Клиенты** (Таблица измерений)
* **Продукты** (Таблица измерений)
* **Временные интервалы** годы, месяцы, дни (Таблица измерений)

## Определение таблиц фактов и измерений

Приведём описание таблиц, которые определяют эти сущности.

Таблица фактов будет содержать записи о транзакциях.

* **Transactions** (ID_transaction, ID_client, ID_product, summ, ID_time, amount)

Таблицы измерений:

* Клиенты (**Customers** (ID_client, name, address, phone)):
* Продукты (**Products** (ID_product, name_product, category, price, min_sum)):
* Временные интервалы (**Time** (ID_time, date, month, year, quarter)):

Были определены связи между таблицами:

* Таблица **Transactions** будет связана с таблицей **Customers** через ID_клиента.
* Таблица **Transactions** будет связана с таблицей **Products** через ID_продукта.
* Таблица **Transactions** будет связана с таблицей **Time** через ID_time.

Код для создания таблиц находится в файле `create_tables.sql`. Вставка данных в таблицу происходит в файле `insert_data.sql`.

## Операции с данными

Предположим, пользователь хечет получить общее количество и сумму транзакций для каждого клиента. Необходимо использовать JOIN для соединения таблиц по ID_client, а затем сгруппировать результаты по имени клиента.

```SQL
SELECT c.ID_client, c.name,
  COUNT(t.ID_transaction) AS total_count_transaction,
  SUM(t.summ) AS total_sum
FROM Customers c JOIN Transactions t ON c.ID_client = t.ID_client
GROUP BY c.ID_client, c.name
ORDER BY total_sum DESC
LIMIT 10;
```
Пример запроса с использованием оконной функции для таблицы **Customers**, который позволяет получить ранг клиентов на основе общей суммы их расходов из таблицы **Transactions**. 

```SQL
WITH Total_Spend AS (
    SELECT c.ID_client, c.name, SUM(t.summ) AS Total_sum_spend
    FROM Customers c LEFT JOIN Transactions t ON c.ID_client = t.ID_client
    GROUP BY c.ID_client, c.name
)

SELECT ID_client, name, Total_sum_spend, RANK() OVER (ORDER BY Total_sum_spend DESC) AS rang
FROM Total_Spend
ORDER BY rang
LIMIT 10;
```

Представление для получения данных о клиентах и их транзакциях.

```SQL
CREATE VIEW CustomerTransactions AS
SELECT c.name, SUM(t.summ) AS total_income
FROM Customers c JOIN Transactions t ON c.ID_client = t.ID_client
GROUP BY c.name;

SELECT * FROM CustomerTransactions LIMIT 10;
```

Реализация триггера для обновления минимальной суммы транзакции. Функция `update_min_transaction` обновляет поле min_sum в таблице **Products**. Триггер срабатывает после выполнения операции вставки (INSERT) в таблицу **Transactions**. Для каждой вставленной строки триггер вызывает функцию `update_min_transaction`.

```SQL
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
```

Для трассировки выполнения конкретного запроса можно использовать EXPLAIN ANALYZE. Команда EXPLAIN ANALYZE выдаст план выполнения запроса вместе с временем выполнения каждого шага.

```SQL
EXPLAIN ANALYZE
SELECT SUM(summ) AS common_income FROM Transactions LIMIT 10;
```








