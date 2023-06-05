import ballerina/http;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/test;

final http:Client testCl = check new ("http://localhost:8081");

@test:Config
function testInvalidRequestWithoutTypeQueryParam() returns error? {
    http:Response resp = check testCl->/(params = {});
    test:assertEquals(resp.statusCode, http:STATUS_BAD_REQUEST);

    resp = check testCl->/(params = {"sentences": 2});
    test:assertEquals(resp.statusCode, http:STATUS_BAD_REQUEST);
}

@test:Config
function testInvalidRequestWithInvalidTypeQueryParam() returns error? {
    http:Response resp = check testCl->/(params = {"type": "all"});
    test:assertEquals(resp.statusCode, http:STATUS_BAD_REQUEST);
}

@test:Config
function testValidRequestWithoutSentencesParam() returns error? {
    http:Response resp = check testCl->/(params = {"type": "all-meat"});
    test:assertEquals(resp.statusCode, http:STATUS_ACCEPTED);
    json respJson = check io:fileReadJson(outputFile);
    test:assertTrue(check getSentenceCount(respJson) > 0);
}

@test:Config
function testValidRequestWithSentencesParam() returns error? {
    http:Response resp = check testCl->/(params = {"type": "all-meat", "sentences": "1"});
    test:assertEquals(resp.statusCode, http:STATUS_ACCEPTED);
    json respJson = check io:fileReadJson(outputFile);
    test:assertEquals(check getSentenceCount(respJson), 1);

    resp = check testCl->/(params = {"type": "meat-and-filler", "sentences": "5"});
    test:assertEquals(resp.statusCode, http:STATUS_ACCEPTED);
    respJson = check io:fileReadJson(outputFile);
    test:assertEquals(check getSentenceCount(respJson), 5);
}

function getSentenceCount(json respJson) returns int|error {
    json[] arr = check respJson.ensureType();
    string mem = check arr[0];
    return regexp:split(re `\.`, mem).length() - 1;
}
