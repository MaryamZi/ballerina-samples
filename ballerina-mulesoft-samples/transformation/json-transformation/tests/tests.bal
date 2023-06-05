import ballerina/test;

final map<json> & readonly inputJson = {
    "books": [
        {
            "-category": "cooking",
            "title": "Everyday Italian",
            "author": "Giada De Laurentiis",
            "year": "2005",
            "price": "30.00"
        },
        {
            "-category": "children",
            "title": "Harry Potter",
            "author": "J K. Rowling",
            "year": "2005",
            "price": "29.99"
        },
        {
            "-category": "web",
            "title": "XQuery Kick Start",
            "author": [
                "James McGovern",
                "Per Bothner",
                "Kurt Cagle",
                "James Linn",
                "Vaidyanathan Nagarajan"
            ],
            "year": "2003",
            "price": "49.99"
        },
        {
            "-category": "web",
            "-cover": "paperback",
            "title": "Learning XML",
            "author": "Erik T. Ray",
            "year": "2003",
            "price": "39.95"
        }
    ]
};

final json & readonly expectedJson = {
    "items": [
        {
            "book": {
                "-CATEGORY": "cooking",
                "TITLE": "Everyday Italian",
                "AUTHOR": "Giada De Laurentiis",
                "YEAR": "2005",
                "PRICE": "30.00"
            }
        },
        {
            "book": {
                "-CATEGORY": "children",
                "TITLE": "Harry Potter",
                "AUTHOR": "J K. Rowling",
                "YEAR": "2005",
                "PRICE": "29.99"
            }
        },
        {
            "book": {
                "-CATEGORY": "web",
                "TITLE": "XQuery Kick Start",
                "AUTHOR": [
                    "James McGovern",
                    "Per Bothner",
                    "Kurt Cagle",
                    "James Linn",
                    "Vaidyanathan Nagarajan"
                ],
                "YEAR": "2003",
                "PRICE": "49.99"
            }
        },
        {
            "book": {
                "-CATEGORY": "web",
                "-COVER": "paperback",
                "TITLE": "Learning XML",
                "AUTHOR": "Erik T. Ray",
                "YEAR": "2003",
                "PRICE": "39.95"
            }
        }
    ]
};

final map<json> & readonly inputJsonForWithDefaults = {
    "books": [
        {
            "-category": "cooking",
            "title": {
                "-lang": "en",
                "#text": "Everyday Italian"
            },
            "author": "Giada De Laurentiis",
            "year": "2005",
            "price": "30.00"
        },
        {
            "-category": "children",
            "title": {
                "-lang": "en",
                "#text": "Harry Potter"
            },
            "author": "J K. Rowling",
            "year": "2005",
            "price": "29.99"
        },
        {
            "-category": "web",
            "title": {
                "-lang": "en",
                "#text": "XQuery Kick Start"
            },
            "author": [
                "James McGovern",
                "Per Bothner",
                "Kurt Cagle",
                "James Linn",
                "Vaidyanathan Nagarajan"
            ],
            "year": "2003",
            "price": "49.99"
        },
        {
            "-category": "web",
            "-cover": "paperback",
            "title": {
                "-lang": "en",
                "#text": "Learning XML"
            },
            "author": "Erik T. Ray",
            "year": "2003",
            "price": "39.95"
        }
    ]
};

final json & readonly expectedJsonForWithDefaults = {
    "items": [
        {
            "category": "book",
            "price": 30.00,
            "id": 0,
            "properties": {
                "title": {
                    "-lang": "en",
                    "#text": "Everyday Italian"
                },
                "author": "Giada De Laurentiis",
                "year": 2005
            }
        },
        {
            "category": "book",
            "price": 29.99,
            "id": 1,
            "properties": {
                "title": {
                    "-lang": "en",
                    "#text": "Harry Potter"
                },
                "author": "J K. Rowling",
                "year": 2005
            }
        },
        {
            "category": "book",
            "price": 49.99,
            "id": 2,
            "properties": {
                "title": {
                    "-lang": "en",
                    "#text": "XQuery Kick Start"
                },
                "author": [
                    "James McGovern",
                    "Per Bothner",
                    "Kurt Cagle",
                    "James Linn",
                    "Vaidyanathan Nagarajan"
                ],
                "year": 2003
            }
        },
        {
            "category": "book",
            "price": 39.95,
            "id": 3,
            "properties": {
                "title": {
                    "-lang": "en",
                    "#text": "Learning XML"
                },
                "author": "Erik T. Ray",
                "year": 2003
            }
        }
    ]
};

@test:Config
function testMappingData() returns error? {
    json result = check mapData(inputJson);
    test:assertEquals(result, expectedJson);
}

@test:Config
function testMappingDataWithDefaultValues() returns error? {
    json result = check mapDataWithDefaults(inputJsonForWithDefaults);
    test:assertEquals(result, expectedJsonForWithDefaults);
}


@test:Config
function testMappingDataViaRecords() returns error? {
    Output result = mapDataViaRecords(check inputJson.cloneWithType());
    test:assertEquals(result, expectedJson);
}

@test:Config
function testMappingDataWithDefaultValuesViaRecords() returns error? {
    OutputWithProperties result = check mapDataWithDefaultsViaRecords(check inputJsonForWithDefaults.cloneWithType());
    test:assertEquals(result, expectedJsonForWithDefaults);
}
