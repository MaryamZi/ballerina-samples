function transformRepeatedKeysToRepeatedXmlElements(json inputJson) returns xml|error =>
    let json[] friends = check (check inputJson.friends).ensureType() in 
    <xml> xml `<?xml version='1.0' encoding='UTF-8'?><friends>${
                from json friend in friends
                    let string name = check friend.name
                    select xml `<name>${name}</name>`
            }</friends>`;

