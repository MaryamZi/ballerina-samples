CREATE DATABASE IF NOT EXISTS claimsdb;

USE claimsdb;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) AUTO_INCREMENT = 1001;

INSERT INTO users (username, email)
VALUES
    ('Alice Johnson', 'alice.johnson@example.com'),
    ('Bob Martin', 'bob.martin@example.com'),
    ('Charlie Davis', 'charlie.davis@example.com'),
    ('David Wilson', 'david.wilson@example.com'),
    ('Eva Brown', 'eva.brown@example.com'),
    ('Frank White', 'frank.white@example.com'),
    ('Grace Miller', 'grace.miller@example.com'),
    ('Hannah Moore', 'hannah.moore@example.com'),
    ('Isaac Clark', 'isaac.clark@example.com'),
    ('Jack Lewis', 'jack.lewis@example.com');

CREATE TABLE claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    claim_date DATETIME NOT NULL,
    claim_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE total_claims (
    user_id INT PRIMARY KEY,
    total_claim_amount DECIMAL(10, 2) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

DELIMITER $$

CREATE TRIGGER update_total_after_claim_insert
AFTER INSERT ON claims
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' THEN
        IF EXISTS (SELECT 1 FROM total_claims WHERE user_id = NEW.user_id) THEN
            UPDATE total_claims
            SET total_claim_amount = total_claim_amount + NEW.claim_amount,
                last_updated = NOW()
            WHERE user_id = NEW.user_id;
        ELSE

            INSERT INTO total_claims (user_id, total_claim_amount, last_updated)
            VALUES (NEW.user_id, NEW.claim_amount, NOW());
        END IF;
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER update_total_after_claim_status_change
AFTER UPDATE ON claims
FOR EACH ROW
BEGIN
    IF OLD.status = 'pending' AND NEW.status = 'approved' THEN
        IF EXISTS (SELECT 1 FROM total_claims WHERE user_id = NEW.user_id) THEN
            UPDATE total_claims
            SET total_claim_amount = total_claim_amount + NEW.claim_amount,
                last_updated = NOW()
            WHERE user_id = NEW.user_id;
        ELSE
            INSERT INTO total_claims (user_id, total_claim_amount, last_updated)
            VALUES (NEW.user_id, NEW.claim_amount, NOW());
        END IF;
    END IF;
END $$

DELIMITER ;

INSERT INTO claims (user_id, claim_date, claim_amount, status)
VALUES 
    (1001, '2025-01-01 10:00:00', 300.00, 'approved'),
    (1001, '2025-01-02 12:30:00', 200.00, 'pending'),
    (1002, '2025-01-03 14:00:00', 100.00, 'approved'),
    (1003, '2025-01-04 16:15:00', 150.00, 'approved');
