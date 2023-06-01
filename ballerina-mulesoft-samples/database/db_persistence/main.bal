import ballerina/persist;
import db_persistence.store;

final store:Client cl = check new;

function init() returns error? {
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

function selectAll() returns store:Book[]|persist:Error {
    stream<store:Book, persist:Error?> bookStr = cl->/books();
    return from store:Book book in bookStr select book;
}

function selectFilteringByKeyId(int id) returns store:Book|persist:Error {
    return cl->/books/[id]();
}

function selectFilteringByAuthor(string author) returns store:Book[]|persist:Error {
    stream<store:Book, persist:Error?> bookStr = cl->/books();
    return from store:Book book in bookStr where book.author == author select book;
}

function insert(store:Book book) returns int|persist:Error {
    int[] ids = check cl->/books.post([book]);
    return ids[0];
}

function update(function (store:Book) returns store:BookUpdate? fn) returns persist:Error? {
    stream<store:Book, persist:Error?> bookStr = cl->/books();
    [int, store:BookUpdate][] itemsToUpdate = [];

    check bookStr.forEach(function (store:Book book) {
        store:BookUpdate? update = fn(book);
        if update !is () {
            itemsToUpdate.push([book.id, update]);
        }
    });

    foreach [int, store:BookUpdate] [id, bookUpdate] in itemsToUpdate {
        _ = check cl->/books/[id].put(bookUpdate);
    }

    // Can't use query expressions on Swan Lake Update 5 due to 
    // https://github.com/ballerina-platform/ballerina-lang/issues/40412
    
    // [int, store:BookUpdate][] itemsToUpdate = check from store:Book book in bookStr
    //                                             let store:BookUpdate? update = fn(book)
    //                                             where update !is ()
    //                                             select [book.id, update];
    // foreach [int, store:BookUpdate] [id, bookUpdate] in itemsToUpdate {
    //     _ = check cl->/books/[id].put(bookUpdate);
    // }
}

function delete(int id) returns persist:Error? {
    _ = check cl->/books/[id].delete();
}
