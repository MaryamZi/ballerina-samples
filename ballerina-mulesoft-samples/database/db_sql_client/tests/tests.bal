import ballerina/sql;
import ballerina/test;

@test:BeforeSuite
function addToTable() returns error? {
    // Can alternatively be done via a script.
    _ = check cl->execute(`DROP TABLE Book`);

    _ = check cl->execute(`CREATE TABLE Book (
        id INT NOT NULL AUTO_INCREMENT,
        title VARCHAR(191) NOT NULL,
        author VARCHAR(191) NOT NULL,
        bookshopName VARCHAR(191) NOT NULL,
        isbn VARCHAR(191) NOT NULL,
        price INT NOT NULL,
        PRIMARY KEY(id)
    )`);

    BookInsert[] books = [
        {title: "Good Omens", author: "Terry Pratchett and Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780060853983", price: 50},
        {title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", bookshopName: "A.Z. Fell and Co.", isbn: "9780547773742", price: 20},
        {title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20},
        {title: "The Nice and Accurate Prophecies of Agnes Nutter", author: "Agnes Nutter", bookshopName: "A.Z. Fell and Co.", isbn: "000000000000", price: 200},
        {title: "Cujo", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 20},
        {title: "Nation", author: "Terry Pratchett", bookshopName: "A.Z. Fell and Co.", isbn: "9780552557795", price: 30},
        {title: "The Ocean at the End of the Lane", author: "Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780062459367", price: 30}
    ];
    
    sql:ParameterizedQuery[] insertQueries = from BookInsert {title, author, bookshopName, isbn, price} in books
        select `INSERT INTO Book (title, author, bookshopName, isbn, price)
                VALUES (${title}, ${author}, ${bookshopName}, ${isbn}, ${price})`;
    _ = check cl->batchExecute(insertQueries);
}

@test:Config
function testSelectAll() returns error? {
    Book[] allBooks = check selectAll();
    Book[] expectedBooks = [
        {id: 1, title: "Good Omens", author: "Terry Pratchett and Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780060853983", price: 50},
        {id: 2, title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", bookshopName: "A.Z. Fell and Co.", isbn: "9780547773742", price: 20},
        {id: 3, title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20},
        {id: 4, title: "The Nice and Accurate Prophecies of Agnes Nutter", author: "Agnes Nutter", bookshopName: "A.Z. Fell and Co.", isbn: "000000000000", price: 200},
        {id: 5, title: "Cujo", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 20},
        {id: 6, title: "Nation", author: "Terry Pratchett", bookshopName: "A.Z. Fell and Co.", isbn: "9780552557795", price: 30},
        {id: 7, title: "The Ocean at the End of the Lane", author: "Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780062459367", price: 30}
    ];
    test:assertEquals(allBooks, expectedBooks);
}

@test:Config
function testSelectFilteringByKeyId() returns error? {
    Book book3 = check selectFilteringByKeyId(3);
    test:assertEquals(book3, {id: 3, title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20});

    Book|sql:Error book10 = selectFilteringByKeyId(10);
    test:assertTrue(book10 is sql:Error);
}

@test:Config
function testSelectFilteringByAuthor() returns error? {
    Book[] stephenKingBooks = check selectFilteringByAuthor("Stephen King");
    test:assertEquals(stephenKingBooks.length(), 2);
    test:assertEquals(stephenKingBooks, [
        {id: 3, title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20},
        {id: 5, title: "Cujo", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 20}
    ]);
}

@test:Config {
    dependsOn: [testSelectAll]
}
function testInsert() returns error? {
    int id = check insert({
        id: 8,
        title: "Great Expectations",
        author: "Charles Dickens",
        price: 70,
        isbn: "9781503275188",
        bookshopName: "A.Z. Fell and Co."
    });
    test:assertEquals(id, 8);
}

@test:Config {
    dependsOn: [testInsert, testSelectFilteringByKeyId, testSelectFilteringByAuthor]
}
function testUpdate() returns error? {
    _ = check update(`UPDATE Book SET author = 'S. King' WHERE author = 'Stephen King'`);

    test:assertEquals(check selectAll(), [
        {id: 1, title: "Good Omens", author: "Terry Pratchett and Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780060853983", price: 50},
        {id: 2, title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", bookshopName: "A.Z. Fell and Co.", isbn: "9780547773742", price: 20},
        {id: 3, title: "IT", author: "S. King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20},
        {id: 4, title: "The Nice and Accurate Prophecies of Agnes Nutter", author: "Agnes Nutter", bookshopName: "A.Z. Fell and Co.", isbn: "000000000000", price: 200},
        {id: 5, title: "Cujo", author: "S. King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 20},
        {id: 6, title: "Nation", author: "Terry Pratchett", bookshopName: "A.Z. Fell and Co.", isbn: "9780552557795", price: 30},
        {id: 7, title: "The Ocean at the End of the Lane", author: "Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780062459367", price: 30},
        {id: 8, title: "Great Expectations", author: "Charles Dickens", bookshopName: "A.Z. Fell and Co.", isbn: "9781503275188", price: 70}
    ]);
}

@test:Config {
    dependsOn: [testUpdate]
}
function testUpdateAuthorName() returns error? {
    _ = check updateAuthorName("S. King", "Stephen E. King");

    test:assertEquals(check selectAll(), [
        {id: 1, title: "Good Omens", author: "Terry Pratchett and Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780060853983", price: 50},
        {id: 2, title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", bookshopName: "A.Z. Fell and Co.", isbn: "9780547773742", price: 20},
        {id: 3, title: "IT", author: "Stephen E. King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20},
        {id: 4, title: "The Nice and Accurate Prophecies of Agnes Nutter", author: "Agnes Nutter", bookshopName: "A.Z. Fell and Co.", isbn: "000000000000", price: 200},
        {id: 5, title: "Cujo", author: "Stephen E. King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 20},
        {id: 6, title: "Nation", author: "Terry Pratchett", bookshopName: "A.Z. Fell and Co.", isbn: "9780552557795", price: 30},
        {id: 7, title: "The Ocean at the End of the Lane", author: "Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780062459367", price: 30},
        {id: 8, title: "Great Expectations", author: "Charles Dickens", bookshopName: "A.Z. Fell and Co.", isbn: "9781503275188", price: 70}
    ]);
}

@test:Config {
    dependsOn: [testUpdate]
}
function testDelete() returns error? {
    int? res = check delete(2);
    test:assertEquals(res, 1);
    
    res = check delete(12);
    test:assertEquals(res, 0);
}
