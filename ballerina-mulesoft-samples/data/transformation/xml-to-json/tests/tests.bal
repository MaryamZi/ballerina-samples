import ballerina/test;

@test:Config {
    dataProvider: buyerDetailsTransformationFunctions
}
function testTransformBuyerDetails(function (xml) returns map<json>|error transformationFn) returns error? {
    xml orderXml =
        xml `
            <?xml version='1.0' encoding='UTF-8'?>
            <order>
                <product>
                    <price>5</price>
                    <model>MuleSoft Connect 2016</model>
                </product>
                <item_amount>3</item_amount>
                <payment>
                    <payment-type>credit-card</payment-type>
                    <currency>USD</currency>
                    <installments>1</installments>
                </payment>
                <buyer>
                    <email>mike@hotmail.com</email>
                    <name>Michael</name>
                    <address>Koala Boulevard 314</address>
                    <city>San Diego</city>
                    <state>CA</state>
                    <postCode>1345</postCode>
                    <nationality>USA</nationality>
                </buyer>
                <shop>main branch</shop>
                <salesperson>Mathew Chow</salesperson>
            </order>`;
    map<json> result = check transformationFn(orderXml);
    map<json> expectedJson = {
        "address1": "Koala Boulevard 314",
        "city": "San Diego",
        "country": "USA",
        "email": "mike@hotmail.com",
        "name": "Michael",
        "postalCode": "1345",
        "stateOrProvince": "CA"
    };
    test:assertEquals(result, expectedJson);
}

function buyerDetailsTransformationFunctions() returns (function (xml) returns map<json>|error)[][] => [
    [transformBuyerDetailsViaXmlAccess],
    [transformBuyerDetailsViaConversionToJson],
    [transformBuyerDetailsViaConversionToRecord]
];

@test:Config
function testTransformProductLineItems() returns error? {
    xml orderXml = xml `<order>
        <product-lineitems>
            <product-lineitem>
                <net-price>100.0</net-price>
            </product-lineitem>
            <product-lineitem>
                <net-price>498.00</net-price>
            </product-lineitem>
        </product-lineitems>
    </order>`;

    json result = check transformProductLineItems(orderXml);
    map<json> expectedJson = {
        "order": {
            "product-lineitems": {
                "product-lineitem": [
                    {
                        "net-price": "100.0"
                    },
                    {
                        "net-price": "498.00"
                    }
                ]
            }
        }
    };
    test:assertEquals(result, expectedJson);
}
