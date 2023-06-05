import ballerina/persist;
import ballerina/test;
import db_persistence.store;

@test:BeforeSuite
function addToTable() returns error? {
    // Can alternatively be added via the script.
    // Auto increment support is not yet available in the persistence layer,
    // but is planned for a future release.
    store:Book[] books = [
        {id: 1, title: "Good Omens", author: "Terry Pratchett and Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780060853983", price: 50},
        {id: 2, title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", bookshopName: "A.Z. Fell and Co.", isbn: "9780547773742", price: 20},
        {id: 3, title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20},
        {id: 4, title: "The Nice and Accurate Prophecies of Agnes Nutter", author: "Agnes Nutter", bookshopName: "A.Z. Fell and Co.", isbn: "000000000000", price: 200},
        {id: 5, title: "Cujo", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 20},
        {id: 6, title: "Nation", author: "Terry Pratchett", bookshopName: "A.Z. Fell and Co.", isbn: "9780552557795", price: 30},
        {id: 7, title: "The Ocean at the End of the Lane", author: "Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780062459367", price: 30}
    ];
    
    foreach store:Book book in books {
        _ = check insert(book);
    }
}

@test:Config
function testSelectAll() returns error? {
    store:Book[] allBooks = check selectAll();
    store:Book[] expectedBooks = [
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
    store:Book book3 = check selectFilteringByKeyId(3);
    test:assertEquals(book3, {id: 3, title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 20});

    store:Book|persist:Error book10 = selectFilteringByKeyId(10);
    test:assertTrue(book10 is persist:Error);
}

@test:Config
function testSelectFilteringByAuthor() returns error? {
    store:Book[] stephenKingBooks = check selectFilteringByAuthor("Stephen King");
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
        id: 8, // auto increment will be supported in a future release
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
    _ = check update(book => book.price < 30 ? 
            let store:Book {title, author, bookshopName, isbn, price} = book in
                {title, author, bookshopName, isbn, price: price + 10} : 
            ());

    test:assertEquals(check selectAll(), [
        {id: 1, title: "Good Omens", author: "Terry Pratchett and Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780060853983", price: 50},
        {id: 2, title: "A Wizard of Earthsea", author: "Ursula K. Le Guin", bookshopName: "A.Z. Fell and Co.", isbn: "9780547773742", price: 30},
        {id: 3, title: "IT", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781508297123", price: 30},
        {id: 4, title: "The Nice and Accurate Prophecies of Agnes Nutter", author: "Agnes Nutter", bookshopName: "A.Z. Fell and Co.", isbn: "000000000000", price: 200},
        {id: 5, title: "Cujo", author: "Stephen King", bookshopName: "A.Z. Fell and Co.", isbn: "9781501192241", price: 30},
        {id: 6, title: "Nation", author: "Terry Pratchett", bookshopName: "A.Z. Fell and Co.", isbn: "9780552557795", price: 30},
        {id: 7, title: "The Ocean at the End of the Lane", author: "Neil Gaiman", bookshopName: "A.Z. Fell and Co.", isbn: "9780062459367", price: 30},
        {id: 8, title: "Great Expectations", author: "Charles Dickens", bookshopName: "A.Z. Fell and Co.", isbn: "9781503275188", price: 70}
    ]);
}

@test:Config {
    dependsOn: [testUpdate]
}
function testDelete() returns error? {
    check delete(2);
    store:Book|persist:Error book2 = selectFilteringByKeyId(2);
    test:assertTrue(book2 is persist:Error);
    persist:Error err = <persist:Error> book2;
    test:assertEquals(err.message(), "A record does not exist for 'Book' for key 2.");
    
    persist:Error? delError = delete(12);
    test:assertTrue(delError is persist:Error);
    err = <persist:Error> delError;
    test:assertEquals(err.message(), "A record does not exist for 'Book' for key 12.");
}

@test:AfterSuite
function cleanDb() returns error? {
    stream<store:Book, persist:Error?> books = cl->/books();
    check from store:Book {id} in books
    do {
        _ = check cl->/books/[id].delete;
    };
}
