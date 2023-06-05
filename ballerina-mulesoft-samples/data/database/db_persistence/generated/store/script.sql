-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS `Book`;

CREATE TABLE `Book` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`title` VARCHAR(191) NOT NULL,
	`author` VARCHAR(191) NOT NULL,
	`bookshopName` VARCHAR(191) NOT NULL,
	`isbn` VARCHAR(191) NOT NULL,
	`price` INT NOT NULL,
	PRIMARY KEY(`id`)
);

-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('Good Omens', 'Terry Pratchett and Neil Gaiman', 'A.Z. Fell and Co.', '9780060853983', 50);
-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('A Wizard of Earthsea', 'Ursula K. Le Guin', 'A.Z. Fell and Co.', '9780547773742', 20);
-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('IT', 'Stephen King', 'A.Z. Fell and Co.', '9781508297123', 20);
-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('The Nice and Accurate Prophecies of Agnes Nutter', 'Agnes Nutter', 'A.Z. Fell and Co.', '000000000000', 200);
-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('Cujo', 'Stephen King', 'A.Z. Fell and Co.', '9781501192241', 20);
-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('Nation', 'Terry Pratchett', 'A.Z. Fell and Co.', '9780552557795', 30);
-- INSERT INTO Book(title, author, bookshopName, isbn, price) VALUES('The Ocean at the End of the Lane', 'Neil Gaiman', 'A.Z. Fell and Co.', '9780062459367', 30);
