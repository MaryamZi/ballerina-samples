// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/persist;
import ballerina/jballerina.java;
import ballerinax/mysql;

const BOOK = "books";

public client class Client {
    *persist:AbstractPersistClient;

    private final mysql:Client dbClient;

    private final map<persist:SQLClient> persistClients;

    private final record {|persist:Metadata...;|} metadata = {
        [BOOK] : {
            entityName: "Book",
            tableName: `Book`,
            fieldMetadata: {
                id: {columnName: "id"},
                title: {columnName: "title"},
                author: {columnName: "author"},
                bookshopName: {columnName: "bookshopName"},
                isbn: {columnName: "isbn"},
                price: {columnName: "price"}
            },
            keyFields: ["id"]
        }
    };

    public function init() returns persist:Error? {
        mysql:Client|error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {[BOOK] : check new (self.dbClient, self.metadata.get(BOOK))};
    }

    isolated resource function get books(BookTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get books/[int id](BookTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post books(BookInsert[] data) returns int[]|persist:Error {
        _ = check self.persistClients.get(BOOK).runBatchInsertQuery(data);
        return from BookInsert inserted in data
            select inserted.id;
    }

    isolated resource function put books/[int id](BookUpdate value) returns Book|persist:Error {
        _ = check self.persistClients.get(BOOK).runUpdateQuery(id, value);
        return self->/books/[id].get();
    }

    isolated resource function delete books/[int id]() returns Book|persist:Error {
        Book result = check self->/books/[id].get();
        _ = check self.persistClients.get(BOOK).runDeleteQuery(id);
        return result;
    }

    public function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

