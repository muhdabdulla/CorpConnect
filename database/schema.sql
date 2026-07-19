-- ==========================================
-- CorpConnect Database Schema
-- ==========================================

-- Drop tables if they already exist
DROP TABLE IF EXISTS message_recipient CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS announcement CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS company CASCADE;

-- ==========================================
-- COMPANY TABLE
-- ==========================================

CREATE TABLE company (
    company_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ==========================================
-- DEPARTMENT TABLE
-- ==========================================

CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,

    CONSTRAINT fk_department_company
        FOREIGN KEY (company_id)
        REFERENCES company(company_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_department_name
        UNIQUE (company_id, department_name)
);


-- ==========================================
-- USERS TABLE
-- ==========================================

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,

    company_id INT NOT NULL,
    department_id INT,

    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),

    role VARCHAR(20) NOT NULL
        CHECK (role IN ('OWNER', 'MANAGER', 'EMPLOYEE')),

    designation VARCHAR(100),

    joined_date DATE DEFAULT CURRENT_DATE,

    status VARCHAR(15) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    CONSTRAINT fk_user_company
        FOREIGN KEY (company_id)
        REFERENCES company(company_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_user_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ==========================================
-- ADD MANAGER FOREIGN KEY TO DEPARTMENT
-- ==========================================

ALTER TABLE department
ADD COLUMN manager_id INT;

ALTER TABLE department
ADD CONSTRAINT fk_department_manager
FOREIGN KEY (manager_id)
REFERENCES users(user_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- ==========================================
-- MESSAGE TABLE
-- ==========================================

CREATE TABLE message (
    message_id SERIAL PRIMARY KEY,

    sender_id INT NOT NULL,

    subject VARCHAR(150) NOT NULL,
    message_body TEXT NOT NULL,

    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_message_sender
        FOREIGN KEY (sender_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ==========================================
-- MESSAGE RECIPIENT TABLE
-- ==========================================

CREATE TABLE message_recipient (
    recipient_id SERIAL PRIMARY KEY,

    message_id INT NOT NULL,
    receiver_id INT NOT NULL,

    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,

    CONSTRAINT fk_message
        FOREIGN KEY (message_id)
        REFERENCES message(message_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_receiver
        FOREIGN KEY (receiver_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_message_receiver
        UNIQUE (message_id, receiver_id)
);

-- ==========================================
-- ANNOUNCEMENT TABLE
-- ==========================================

CREATE TABLE announcement (
    announcement_id SERIAL PRIMARY KEY,

    company_id INT NOT NULL,
    created_by INT,

    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_announcement_company
        FOREIGN KEY (company_id)
        REFERENCES company(company_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_announcement_creator
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);