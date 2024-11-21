-- Создание таблицы Customers
CREATE TABLE Customers (
    ID_client INT PRIMARY KEY,
    name VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(20)
);

-- Создание таблицы Products
CREATE TABLE Products (
    ID_product INT PRIMARY KEY,
    name_product VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    min_sum DECIMAL(10, 2) DEFAULT NULL
);

-- Создание таблицы Time
CREATE TABLE Time (
    ID_time INT PRIMARY KEY,
    date DATE,
    month INT,
    year INT,
    quarter INT
);

-- Создание таблицы Transactions
CREATE TABLE Transactions (
    ID_transaction INT PRIMARY KEY,
    ID_client INT,
    ID_product INT,
    summ DECIMAL(10, 2),
    ID_time INT,
    amount INT,
    FOREIGN KEY (ID_client) REFERENCES Customers(ID_client),
    FOREIGN KEY (ID_product) REFERENCES Products(ID_product),
    FOREIGN KEY (ID_time) REFERENCES Time(ID_time)
);
