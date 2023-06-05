type Book record {|
    string \-category;
    string title;
    (string|string[]) author;
    string year;
    string price;
    string \-cover?;
|};

type Input record {|
    Book[] books;
|};

type TransformedBook record {|
    string \-CATEGORY;
    string TITLE;
    (string|string[]) AUTHOR;
    string YEAR;
    string PRICE;
    string \-COVER?;
|};

type TransformedBookItem record {|
    TransformedBook book;
|};

type Output record {|
    TransformedBookItem[] items;
|};

function mapDataViaRecords(Input input) returns Output => 
    let Book[] books = input.books in 
    {
        items: from Book item in books 
                    select {
                        book: {
                            \-CATEGORY: item.\-category,
                            TITLE: item.title,
                            AUTHOR: item.author,
                            YEAR: item.year,
                            PRICE: item.price,
                            \-COVER: item.\-cover
                        }
                    }
    };

type Title record {|
    string \-lang;
    string \#text;
|};

type BookWithStructuredTitle record {|
    string \-category;
    Title title;
    (string|string[]) author;
    string year;
    string price;
    string \-cover?;
|};

type InputWithStructuredTitle record {|
    BookWithStructuredTitle[] books;
|};

type Properties record {|
    Title title;
    (string|string[]) author;
    int year;
|};

type TransformedBookWithProperties record {|
    string category;
    float price;
    int id;
    Properties properties;
|};

type OutputWithProperties record {|
    TransformedBookWithProperties[] items;
|};

function mapDataWithDefaultsViaRecords(InputWithStructuredTitle input) returns OutputWithProperties|error => 
    let BookWithStructuredTitle[] books = input.books in 
    {
        items: from [int, BookWithStructuredTitle] [id, item] in books.enumerate() 
                    select {
                        category: "book",
                        price: check float:fromString(item.price),
                        id,
                        properties: check transformProperties(item)
                    }
    };

function transformProperties(BookWithStructuredTitle item) returns Properties|error => {
    title: item.title,
    author: item.author,
    year: check int:fromString(item.year)
};
