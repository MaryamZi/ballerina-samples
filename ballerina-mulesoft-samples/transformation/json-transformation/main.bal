function mapData(map<json> input) returns map<json>|error => 
    let json[] books = check input.books.ensureType() in 
    {
        items: from json item in books 
                    let map<json> itemBook = check item.ensureType()
                    select {
                        book: map from [string, json] [k, v] in itemBook.entries() 
                                    select [k.toUpperAscii(), v]
                    }
    };

function mapDataWithDefaults(map<json> input) returns map<json>|error => 
    let json[] books = check input.books.ensureType() in 
    {
        items: from [int, json] [id, item] in books.enumerate() 
                    let map<json> itemBook = check item.ensureType()
                    select <map<json>> {
                        category: "book",
                        price: check float:fromString(check itemBook.price),
                        id,
                        properties: {
                            title: check itemBook.title,
                            author: check itemBook.author,
                            year: check int:fromString(check itemBook.year)
                        }
                    }
    };


