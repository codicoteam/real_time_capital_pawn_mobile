import 'dart:convert';

class NotificationsModel {
    String? id;
    String? title;
    String? message;
    String? type;
    String? priority;
    Audience? audience;
    List<Channel>? channels;
    String? entityType;
    String? entityId;
    DateTime? sendAt;
    DateTime? sentAt;
    dynamic expiresAt;
    String? status;
    bool? isActive;
    String? actionText;
    String? actionUrl;
    Data? data;
    CreatedBy? createdBy;
    List<Acknowledgement>? acknowledgements;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;
    bool? isRead;
    DateTime? readAt;
    bool? isActed;
    DateTime? actedAt;
    String? actionTaken;

    NotificationsModel({
        this.id,
        this.title,
        this.message,
        this.type,
        this.priority,
        this.audience,
        this.channels,
        this.entityType,
        this.entityId,
        this.sendAt,
        this.sentAt,
        this.expiresAt,
        this.status,
        this.isActive,
        this.actionText,
        this.actionUrl,
        this.data,
        this.createdBy,
        this.acknowledgements,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.isRead,
        this.readAt,
        this.isActed,
        this.actedAt,
        this.actionTaken,
    });

    factory NotificationsModel.fromJson(String str) => NotificationsModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NotificationsModel.fromMap(Map<String, dynamic> json) => NotificationsModel(
        id: json["_id"],
        title: json["title"],
        message: json["message"],
        type: json["type"],
        priority: json["priority"],
        audience: json["audience"] == null ? null : Audience.fromMap(json["audience"]),
        channels: json["channels"] == null ? [] : List<Channel>.from(json["channels"]!.map((x) => channelValues.map[x]!)),
        entityType: json["entity_type"],
        entityId: json["entity_id"],
        sendAt: json["send_at"] == null ? null : DateTime.parse(json["send_at"]),
        sentAt: json["sent_at"] == null ? null : DateTime.parse(json["sent_at"]),
        expiresAt: json["expires_at"],
        status: json["status"],
        isActive: json["is_active"],
        actionText: json["action_text"],
        actionUrl: json["action_url"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
        createdBy: json["created_by"] == null ? null : CreatedBy.fromMap(json["created_by"]),
        acknowledgements: json["acknowledgements"] == null ? [] : List<Acknowledgement>.from(json["acknowledgements"]!.map((x) => Acknowledgement.fromMap(x))),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        v: json["__v"],
        isRead: json["is_read"],
        readAt: json["read_at"] == null ? null : DateTime.parse(json["read_at"]),
        isActed: json["is_acted"],
        actedAt: json["acted_at"] == null ? null : DateTime.parse(json["acted_at"]),
        actionTaken: json["action_taken"],
    );

    Map<String, dynamic> toMap() => {
        "_id": id,
        "title": title,
        "message": message,
        "type": type,
        "priority": priority,
        "audience": audience?.toMap(),
        "channels": channels == null ? [] : List<dynamic>.from(channels!.map((x) => channelValues.reverse[x])),
        "entity_type": entityType,
        "entity_id": entityId,
        "send_at": sendAt?.toIso8601String(),
        "sent_at": sentAt?.toIso8601String(),
        "expires_at": expiresAt,
        "status": status,
        "is_active": isActive,
        "action_text": actionText,
        "action_url": actionUrl,
        "data": data?.toMap(),
        "created_by": createdBy?.toMap(),
        "acknowledgements": acknowledgements == null ? [] : List<dynamic>.from(acknowledgements!.map((x) => x.toMap())),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "__v": v,
        "is_read": isRead,
        "read_at": readAt?.toIso8601String(),
        "is_acted": isActed,
        "acted_at": actedAt?.toIso8601String(),
        "action_taken": actionTaken,
    };
}

class Acknowledgement {
    String? userId;
    DateTime? readAt;
    DateTime? actedAt;
    String? action;

    Acknowledgement({
        this.userId,
        this.readAt,
        this.actedAt,
        this.action,
    });

    factory Acknowledgement.fromJson(String str) => Acknowledgement.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Acknowledgement.fromMap(Map<String, dynamic> json) => Acknowledgement(
        userId: json["user_id"],
        readAt: json["read_at"] == null ? null : DateTime.parse(json["read_at"]),
        actedAt: json["acted_at"] == null ? null : DateTime.parse(json["acted_at"]),
        action: json["action"],
    );

    Map<String, dynamic> toMap() => {
        "user_id": userId,
        "read_at": readAt?.toIso8601String(),
        "acted_at": actedAt?.toIso8601String(),
        "action": action,
    };
}

class Audience {
    String? scope;
    String? userId;
    dynamic userIds;
    List<String>? roles;

    Audience({
        this.scope,
        this.userId,
        this.userIds,
        this.roles,
    });

    factory Audience.fromJson(String str) => Audience.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Audience.fromMap(Map<String, dynamic> json) => Audience(
        scope: json["scope"],
        userId: json["user_id"],
        userIds: json["user_ids"],
        roles: json["roles"] == null ? [] : List<String>.from(json["roles"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "scope": scope,
        "user_id": userId,
        "user_ids": userIds,
        "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    };
}

enum Channel {
    EMAIL,
    IN_APP,
    PUSH,
    SMS
}

final channelValues = EnumValues({
    "email": Channel.EMAIL,
    "in_app": Channel.IN_APP,
    "push": Channel.PUSH,
    "sms": Channel.SMS
});

class CreatedBy {
    String? id;
    String? email;
    String? firstName;
    String? lastName;

    CreatedBy({
        this.id,
        this.email,
        this.firstName,
        this.lastName,
    });

    factory CreatedBy.fromJson(String str) => CreatedBy.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CreatedBy.fromMap(Map<String, dynamic> json) => CreatedBy(
        id: json["_id"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toMap() => {
        "_id": id,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
    };
}

class Data {
    DateTime? dueDate;
    double? amountDue;
    double? remainingBalance;
    int? lateFeeIfMissed;
    int? pendingCount;
    int? totalAmount;
    List<Application>? applications;
    int? loanAmount;
    int? interestRate;
    int? loanTermMonths;
    double? monthlyPayment;

    Data({
        this.dueDate,
        this.amountDue,
        this.remainingBalance,
        this.lateFeeIfMissed,
        this.pendingCount,
        this.totalAmount,
        this.applications,
        this.loanAmount,
        this.interestRate,
        this.loanTermMonths,
        this.monthlyPayment,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
        dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
        amountDue: json["amount_due"]?.toDouble(),
        remainingBalance: json["remaining_balance"]?.toDouble(),
        lateFeeIfMissed: json["late_fee_if_missed"],
        pendingCount: json["pending_count"],
        totalAmount: json["total_amount"],
        applications: json["applications"] == null ? [] : List<Application>.from(json["applications"]!.map((x) => Application.fromMap(x))),
        loanAmount: json["loan_amount"],
        interestRate: json["interest_rate"],
        loanTermMonths: json["loan_term_months"],
        monthlyPayment: json["monthly_payment"]?.toDouble(),
    );

    Map<String, dynamic> toMap() => {
        "due_date": "${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}",
        "amount_due": amountDue,
        "remaining_balance": remainingBalance,
        "late_fee_if_missed": lateFeeIfMissed,
        "pending_count": pendingCount,
        "total_amount": totalAmount,
        "applications": applications == null ? [] : List<dynamic>.from(applications!.map((x) => x.toMap())),
        "loan_amount": loanAmount,
        "interest_rate": interestRate,
        "loan_term_months": loanTermMonths,
        "monthly_payment": monthlyPayment,
    };
}

class Application {
    String? id;
    int? amount;
    String? customer;
    String? customerId;
    DateTime? submittedAt;

    Application({
        this.id,
        this.amount,
        this.customer,
        this.customerId,
        this.submittedAt,
    });

    factory Application.fromJson(String str) => Application.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Application.fromMap(Map<String, dynamic> json) => Application(
        id: json["id"],
        amount: json["amount"],
        customer: json["customer"],
        customerId: json["customer_id"],
        submittedAt: json["submitted_at"] == null ? null : DateTime.parse(json["submitted_at"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "amount": amount,
        "customer": customer,
        "customer_id": customerId,
        "submitted_at": submittedAt?.toIso8601String(),
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
