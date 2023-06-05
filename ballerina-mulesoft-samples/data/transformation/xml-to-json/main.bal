import ballerina/xmldata;

//////////////////////////// Transform by mapping fields ////////////////////////////

// Option 1
function transformBuyerDetailsViaXmlAccess(xml orderXml) returns map<json>|error =>
    let xml<xml:Element> buyer = orderXml/<buyer>,
        xml:Element buyerElement = check buyer[0].ensureType() in
    {
        address1: (buyerElement/<address>).data(),
        city: (buyerElement/<city>).data(),
        country: (buyerElement/<nationality>).data(),
        email: (buyerElement/<email>).data(),
        name: (buyerElement/<name>).data(),
        postalCode: (buyerElement/<postCode>).data(),
        stateOrProvince: (buyerElement/<state>).data()
    };

// Option 2
function transformBuyerDetailsViaConversionToJson(xml orderXml) returns map<json>|error =>
    let xml<xml:Element> buyer = orderXml/<buyer>,
        json buyerJson = check (check xmldata:toJson(buyer)).buyer in
    {
        address1: check buyerJson.address,
        city: check buyerJson.city,
        country: check buyerJson.nationality,
        email: check buyerJson.email,
        name: check buyerJson.name,
        postalCode: check buyerJson.postCode,
        stateOrProvince: check buyerJson.state
    };

// Option 3
type Buyer record {
    string email;
    string name;
    string address;
    string city;
    string state;
    string postCode;
    string nationality;
};

function transformBuyerDetailsViaConversionToRecord(xml orderXml) returns map<json>|error =>
    let xml<xml:Element> buyer = orderXml/<buyer>,
        record {| Buyer buyer; |} buyerFromXml = check xmldata:fromXml(buyer),
        Buyer buyerRec = buyerFromXml.buyer in
    {
        address1: buyerRec.address,
        city: buyerRec.city,
        country: buyerRec.nationality,
        email: buyerRec.email,
        name: buyerRec.name,
        postalCode: buyerRec.postCode,
        stateOrProvince: buyerRec.state
    };

//////////////////////////// Transform XML with multiple nodes with the same name ////////////////////////////

function transformProductLineItems(xml orderXml) returns json|error => xmldata:toJson(orderXml);

