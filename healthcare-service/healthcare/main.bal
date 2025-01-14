import ballerina/http;
import ballerina/log;

type Doctor record {|
    string name;
    string hospital;
    string category;
    string availability;
    decimal fee;
|};

type Patient record {|
    string name;
    string dob;
    string ssn;
    string address;
    string phone;
    string email;
|};

enum AppointmentStatus {
    ACTIVE,
    COMPLETED,
    CANCELLED
};

type Appointment record {|
    int appointmentNumber;
    Doctor doctor;
    Patient patient;
    boolean confirmed;
    string hospital;
    string appointmentDate;
    AppointmentStatus status;
|};

type PatientWithCardNo record {|
    *Patient;
    string cardNo;
|};

type ReservationRequest record {|
    PatientWithCardNo patient;
    string doctor;
    string hospital_id;
    string hospital;
    string appointment_date;
|};

type Fee record {|
    string doctorName;
    string actualFee;
|};

type ReservationStatus record {|
    int appointmentNo;
    string doctorName;
    string patient;
    decimal actualFee;
    int discount;
    decimal discounted;
    string paymentID;
    string status;
|};

configurable string hospitalServicesBackend = "http://localhost:9090/healthcare";
configurable string paymentBackend = "http://localhost:9090/payments";

configurable decimal refundFee = 500;

final http:Client hospitalServicesEP = check new (hospitalServicesBackend);
final http:Client paymentEP = check new (paymentBackend);

service /healthcare on new http:Listener(8290) {
    resource function post categories/[string category]/reserve(ReservationRequest payload) 
            returns ReservationStatus|http:NotFound|http:InternalServerError {
        PatientWithCardNo patient = payload.patient;
        string doctor = payload.doctor;

        Appointment|http:ClientError appointment =
                hospitalServicesEP->/[payload.hospital_id]/categories/[category]/reserve.post({
            patient: {
                name: patient.name,
                dob: patient.dob,
                ssn: patient.ssn,
                address: patient.address,
                phone: patient.phone,
                email: patient.email
            },
            doctor,
            hospital: payload.hospital,
            appointment_date: payload.appointment_date
        });

        if appointment !is Appointment {
            log:printError("Appointment reservation failed", appointment);
            if appointment is http:ClientRequestError {
                return <http:NotFound> {body: string `unknown hospital, doctor, or category`};
            }
            return <http:InternalServerError> {body: appointment.message()};
        }

        Fee|http:ClientError fee = 
                hospitalServicesEP->/[payload.hospital_id]/categories/[category]/doctors/[doctor]/fee;

        if fee !is Fee {
            log:printError("Retrieving fee failed", fee);
            if fee is http:ClientRequestError {
                return <http:NotFound> {body: string `unknown appointment ID`};
            }
            return <http:InternalServerError> {body: fee.message()};
        }

        decimal|error actualFee = decimal:fromString(fee.actualFee);
        if actualFee is error {
            return <http:InternalServerError> {body: "fee retrieval failed"};
        }

        int appointmentNumber = appointment.appointmentNumber;

        ReservationStatus|http:ClientError status = paymentEP->/.post({
            appointmentNumber,
            doctor: appointment.doctor,
            patient: appointment.patient,
            fee: actualFee,
            confirmed: false,
            card_number: patient.cardNo
        });

        if status !is ReservationStatus {
            log:printError("Payment failed", status);
            if status is http:ClientRequestError {
                return <http:NotFound> {body: string `unknown appointment ID`};
            }
            string|http:ClientError cancellationStatus = 
                hospitalServicesEP->/appointments/[appointmentNumber].delete();
            if cancellationStatus is http:ClientError {
                log:printError("Failed to mark appointment as cancelled", cancellationStatus);
            }
            return <http:InternalServerError> {body: status.message()};
        }

        return status;
    }

    resource function delete appointment(int appointmentNumber) returns http:Ok|http:BadRequest|http:InternalServerError {
        string|http:ClientError cancellationStatus = 
                hospitalServicesEP->/appointments/[appointmentNumber].delete();
        if cancellationStatus !is http:ClientError {
            string|http:ClientError refStatus = paymentEP->/refund.post({appointmentNumber, refundFee});

            if refStatus is http:ClientError {
                log:printError("Failed to refund", refStatus);
                return <http:InternalServerError> {body: "refund failed"};
            }
            return <http:Ok> {body: "cancellation and refund successful"};
        }
        log:printError("Failed to mark appointment as cancelled", cancellationStatus);
        if cancellationStatus is http:ApplicationResponseError {
            int statusCode = cancellationStatus.detail().statusCode;
            if statusCode == http:STATUS_NOT_FOUND {
                return <http:BadRequest> {body: string `unknown appointment ID`};
            }
            return <http:BadRequest> {body: string `appointment already completed`};
        }
        return  <http:InternalServerError> {body: "failed to cancel appointment"};
    }
}
