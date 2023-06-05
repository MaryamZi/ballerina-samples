import ballerina/http;
import ballerina/io;

final http:Client cl = check new ("http://baconipsum.com:80", followRedirects = {enabled: true});

configurable string outputFile = "./tmp/output";

enum Type {
    TYPE_ALL_MEAT = "all-meat",
    TYPE_MEAT_AND_FILLER = "meat-and-filler"
}

service on new http:Listener(8081) {
    resource function get . (Type 'type, string? sentences = ()) returns error? {
        http:QueryParams params = {"type": 'type};
        if sentences !is () {
            params["sentences"] = sentences;
        }

        json payload = check cl->/api(params = params);
        check io:fileWriteJson(outputFile, payload);
    }
}
