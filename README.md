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
