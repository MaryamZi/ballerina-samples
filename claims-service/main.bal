import ballerina/email;
import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type DbConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port = 3306;
|};

type EmailConfig record {|
    string host = "smtp.gmail.com";
    string username;
    string password;
    email:SmtpConfiguration clientConfig;
|};

configurable DbConfig dbConfig = ?;
configurable EmailConfig emailConfig = ?;
configurable string financeEmail = "finance@example.com";

configurable decimal preAuthorizedLimit = 500;

final mysql:Client dbClient = check new (...dbConfig);

final email:SmtpClient smtpClient = check new (...emailConfig);

public enum Status {
    PENDING = "pending",
    APPROVED = "approved",
    REJECTED = "rejected"
}

public type ClaimRequest record {|
    int userId;
    decimal claimAmount;
|};

public type ClaimStatus record {|
    int claimId;
    Status status;
    string details?;
|};

service /claims on new http:Listener(8080) {
    resource function post claim(ClaimRequest req) returns ClaimStatus|http:InternalServerError {
        int userId = req.userId;

        decimal|error totalClaimAmount = dbClient->queryRow(
            `SELECT total_claim_amount FROM total_claims WHERE user_id = ${userId}`);
        if totalClaimAmount is error {
            log:printError("Failed to retrieve total claim amount", totalClaimAmount);
            return {body: "Failed to retrieve total claim amount"};
        }

        decimal newClaimAmount = req.claimAmount;

        if totalClaimAmount + newClaimAmount <= preAuthorizedLimit {
            sql:ParameterizedQuery query = `INSERT INTO claims (user_id, claim_date, claim_amount, status)
                            VALUES (${req.userId
                            }, ${time:utcToCivil(time:utcNow())
                            }, ${req.claimAmount
                            }, ${APPROVED})`;
            sql:ExecutionResult|error result = dbClient->execute(query);
            if result is error {
                log:printError("Failed to update claim", result);
                return {body: "Failed to update claim"};
            }

            return <ClaimStatus> {
                claimId: <int> result.lastInsertId,
                status: APPROVED
            };
        }

        sql:ParameterizedQuery query = `INSERT INTO claims (user_id, claim_date, claim_amount, status)
                                    VALUES (${req.userId
                                    }, ${time:utcToCivil(time:utcNow())
                                    }, ${req.claimAmount
                                    }, ${PENDING})`;
        sql:ExecutionResult|error result = dbClient->execute(query);
        if result is error {
            log:printError("Failed to update claim", result);
            return {body: "Failed to update claim"};
        }

        string|error userEmail = dbClient->queryRow(
            `SELECT email FROM users WHERE user_id = ${userId}`);
        if userEmail is error {
            log:printError("Failed to retrieve email address", userEmail);
            return {body: "Failed to retrieve email address"};
        }

        int claimId = <int> result.lastInsertId;

        email:Error? emailRes = smtpClient->sendMessage({
            to: [userEmail, financeEmail],
            subject: string `Approval Pending for New Claim - Claim ID ${claimId}`,
            body: getEmailContent(req.claimAmount)
        });

        if emailRes is error {
            log:printError("Failed to send the email informing pending claim", emailRes);
        }    

        return <ClaimStatus> {
            claimId,
            status: PENDING,
            details: "Claim amount exceeds the limit. Claim is pending approval"
        };
    }

    resource function get status/[int claimId]() returns ClaimStatus|http:NotFound|http:InternalServerError {
        string|error status = dbClient->queryRow(
            `SELECT status FROM claims WHERE claim_id = ${claimId}`);
        if status is sql:NoRowsError {
            log:printError("No claim found for ID", status, claimId = claimId);
            return <http:NotFound> {};
        }
        if status is error {
            log:printError("Failed to retrieve claim status", status, claimId = claimId);
            return <http:InternalServerError> {body: "Failed to retrieve claim status"};
        }
        return {claimId, status: <Status> status};
    }
}

function getEmailContent(decimal claimAmount) returns string =>
string `Your new claim of USD ${claimAmount} is pending approval as it exceeds the pre-authorized limit. 
The finance team will contact you shortly to discuss the next steps.`;
