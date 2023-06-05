import ballerina/test;

@test:Config
function testRepeatedKeysToRepeatedXmlElementsTransformation() returns error? {
    json inputJson = {
        "friends": [
            {"name": "Mariano"},
            {"name": "Shoki"},
            {"name": "Tomo"},
            {"name": "Ana"}
        ]
    };

    xml result = check transformRepeatedKeysToRepeatedXmlElements(inputJson);

    xml expectedXml = 
        xml `<?xml version='1.0' encoding='UTF-8'?><friends><name>Mariano</name><name>Shoki</name><name>Tomo</name><name>Ana</name></friends>`;

    test:assertEquals(result, expectedXml);
}
