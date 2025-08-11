class OrderDetailResponse {
  final Order? order;
  final List<dynamic> roundId;
  final List<History> history;
  final List<Map<String, String>> activeUsers;
  final List<Feedback> feedback;
  final Users? serviceUsers;
  final Users? users;
  final Department? department;
  final List<RoundAnswer> roundAnswers;
  final List<dynamic> pageTitle;
  final int? status;
  final String? message;

  OrderDetailResponse({
    required this.order,
    required this.roundId,
    required this.history,
    required this.activeUsers,
    required this.feedback,
    required this.serviceUsers,
    required this.users,
    required this.department,
    required this.roundAnswers,
    required this.pageTitle,
    required this.status,
    required this.message,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      order: json["order"] != null ? Order.fromJson(json["order"]) : null,
      roundId: json["round_id"] != null
          ? List<dynamic>.from(json["round_id"].map((x) => x))
          : [],
      history: json["history"] != null
          ? List<History>.from(json["history"].map((x) => History.fromJson(x)))
          : [],
      activeUsers: json["active_users"] != null
          ? List<Map<String, String>>.from(json["active_users"].map((x) =>
              Map<String, String>.from(x.map((k, v) => MapEntry(k, v.toString())))))
          : [],
      feedback: json["feedback"] != null
          ? List<Feedback>.from(json["feedback"].map((x) => Feedback.fromJson(x)))
          : [],
      serviceUsers: json["service_users"] != null
          ? Users.fromJson(json["service_users"])
          : null,
      users: json["users"] != null ? Users.fromJson(json["users"]) : null,
      department: json["department"] != null
          ? Department.fromJson(json["department"])
          : null,
      roundAnswers: json["roundAnswers"] != null
          ? List<RoundAnswer>.from(
              json["roundAnswers"].map((x) => RoundAnswer.fromJson(x)))
          : [],
      pageTitle: json["pageTitle"] != null
          ? List<dynamic>.from(json["pageTitle"].map((x) => x))
          : [],
      status: json["status"] as int?,
      message: json["message"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "order": order?.toJson(),
        "round_id": roundId,
        "history": history.map((x) => x.toJson()).toList(),
        "active_users": activeUsers,
        "feedback": feedback.map((x) => x.toJson()).toList(),
        "service_users": serviceUsers?.toJson(),
        "users": users?.toJson(),
        "department": department?.toJson(),
        "roundAnswers": roundAnswers.map((x) => x.toJson()).toList(),
        "pageTitle": pageTitle,
        "status": status,
        "message": message,
      };
}

class Department {
  final String? id;
  final String? uuid;
  final String? hcoId;
  final String? orgId;
  final String? alarm;
  final String? departmentName;
  final String? departmentNameLang;
  final String? departmentName2;
  final String? departmentName3;
  final String? description;
  final String? description2;
  final String? description3;
  final String? users;
  final String? url;
  final String? icon;
  final String? sortOrder;
  final String? statusInformSupervisor;
  final String? statusAuto;
  final String? statusAutoSupervisor;
  final String? statusAssignUnAvailable;
  final String? notifyGcm;
  final String? notifySms;
  final String? notifyWhatsapp;
  final String? notifyEmail;
  final String? slaAssignType;
  final String? slaAcceptType;
  final String? slaCompleteType;
  final String? slaAssign;
  final String? slaAccept;
  final String? slaComplete;
  final String? slaAssignSec;
  final String? slaAcceptSec;
  final String? slaCompleteSec;
  final String? status;
  final String? deleted;
  final DateTime? createdAt;
  final DateTime? createdAtDate;
  final String? createdBy;
  final dynamic updatedAt;
  final String? updatedBy;

  Department({
    required this.id,
    required this.uuid,
    required this.hcoId,
    required this.orgId,
    required this.alarm,
    required this.departmentName,
    required this.departmentNameLang,
    required this.departmentName2,
    required this.departmentName3,
    required this.description,
    required this.description2,
    required this.description3,
    required this.users,
    required this.url,
    required this.icon,
    required this.sortOrder,
    required this.statusInformSupervisor,
    required this.statusAuto,
    required this.statusAutoSupervisor,
    required this.statusAssignUnAvailable,
    required this.notifyGcm,
    required this.notifySms,
    required this.notifyWhatsapp,
    required this.notifyEmail,
    required this.slaAssignType,
    required this.slaAcceptType,
    required this.slaCompleteType,
    required this.slaAssign,
    required this.slaAccept,
    required this.slaComplete,
    required this.slaAssignSec,
    required this.slaAcceptSec,
    required this.slaCompleteSec,
    required this.status,
    required this.deleted,
    required this.createdAt,
    required this.createdAtDate,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json["id"] as String?,
      uuid: json["uuid"] as String?,
      hcoId: json["hco_id"] as String?,
      orgId: json["org_id"] as String?,
      alarm: json["alarm"] as String?,
      departmentName: json["department_name"] as String?,
      departmentNameLang: json["department_name_lang"] as String?,
      departmentName2: json["department_name_2"] as String?,
      departmentName3: json["department_name_3"] as String?,
      description: json["description"] as String?,
      description2: json["description_2"] as String?,
      description3: json["description_3"] as String?,
      users: json["users"] as String?,
      url: json["url"] as String?,
      icon: json["icon"] as String?,
      sortOrder: json["sort_order"] as String?,
      statusInformSupervisor: json["status_inform_supervisor"] as String?,
      statusAuto: json["status_auto"] as String?,
      statusAutoSupervisor: json["status_auto_supervisor"] as String?,
      statusAssignUnAvailable: json["status_assign_un_available"] as String?,
      notifyGcm: json["notify_gcm"] as String?,
      notifySms: json["notify_sms"] as String?,
      notifyWhatsapp: json["notify_whatsapp"] as String?,
      notifyEmail: json["notify_email"] as String?,
      slaAssignType: json["sla_assign_type"] as String?,
      slaAcceptType: json["sla_accept_type"] as String?,
      slaCompleteType: json["sla_complete_type"] as String?,
      slaAssign: json["sla_assign"] as String?,
      slaAccept: json["sla_accept"] as String?,
      slaComplete: json["sla_complete"] as String?,
      slaAssignSec: json["sla_assign_sec"] as String?,
      slaAcceptSec: json["sla_accept_sec"] as String?,
      slaCompleteSec: json["sla_complete_sec"] as String?,
      status: json["status"] as String?,
      deleted: json["deleted"] as String?,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"] as String)
          : null,
      createdAtDate: json["created_at_date"] != null
          ? DateTime.tryParse(json["created_at_date"] as String)
          : null,
      createdBy: json["created_by"] as String?,
      updatedAt: json["updated_at"],
      updatedBy: json["updated_by"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "hco_id": hcoId,
        "org_id": orgId,
        "alarm": alarm,
        "department_name": departmentName,
        "department_name_lang": departmentNameLang,
        "department_name_2": departmentName2,
        "department_name_3": departmentName3,
        "description": description,
        "description_2": description2,
        "description_3": description3,
        "users": users,
        "url": url,
        "icon": icon,
        "sort_order": sortOrder,
        "status_inform_supervisor": statusInformSupervisor,
        "status_auto": statusAuto,
        "status_auto_supervisor": statusAutoSupervisor,
        "status_assign_un_available": statusAssignUnAvailable,
        "notify_gcm": notifyGcm,
        "notify_sms": notifySms,
        "notify_whatsapp": notifyWhatsapp,
        "notify_email": notifyEmail,
        "sla_assign_type": slaAssignType,
        "sla_accept_type": slaAcceptType,
        "sla_complete_type": slaCompleteType,
        "sla_assign": slaAssign,
        "sla_accept": slaAccept,
        "sla_complete": slaComplete,
        "sla_assign_sec": slaAssignSec,
        "sla_accept_sec": slaAcceptSec,
        "sla_complete_sec": slaCompleteSec,
        "status": status,
        "deleted": deleted,
        "created_at": createdAt?.toIso8601String(),
        "created_at_date": createdAtDate?.toIso8601String(),
        "created_by": createdBy,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
      };
}

class Feedback {
  final String? id;
  final String? title;
  final String? subtitle;
  final String? valueInt;

  Feedback({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.valueInt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json["id"] as String?,
      title: json["title"] as String?,
      subtitle: json["subtitle"] as String?,
      valueInt: json["value_int"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "subtitle": subtitle,
        "value_int": valueInt,
      };
}

class History {
  final String? id;
  final String? uuid;
  final String? orderId;
  final String? userId;
  final String? type;
  final String? caption;
  final String? remarks;
  final String? messageType;
  final String? phoneNumber;
  final String? message;
  final dynamic fileUrl;
  final String? statusMessage;
  final String? statusGcm;
  final String? statusSms;
  final String? statusWhatsapp;
  final String? statusWhatsappClient;
  final String? statusEmail;
  final String? fcmResponse;
  final String? smsResponse;
  final String? whatsappResponse;
  final String? whatsappResponseClient;
  final String? whatsappId;
  final String? whatsappIdClient;
  final String? emailResponse;
  final String? status;
  final String? deleted;
  final String? createdAt;
  final String? createdAtDate;
  final String? createdBy;
  final dynamic updatedAt;
  final String? updatedBy;

  History({
    required this.id,
    required this.uuid,
    required this.orderId,
    required this.userId,
    required this.type,
    required this.caption,
    required this.remarks,
    required this.messageType,
    required this.phoneNumber,
    required this.message,
    required this.fileUrl,
    required this.statusMessage,
    required this.statusGcm,
    required this.statusSms,
    required this.statusWhatsapp,
    required this.statusWhatsappClient,
    required this.statusEmail,
    required this.fcmResponse,
    required this.smsResponse,
    required this.whatsappResponse,
    required this.whatsappResponseClient,
    required this.whatsappId,
    required this.whatsappIdClient,
    required this.emailResponse,
    required this.status,
    required this.deleted,
    required this.createdAt,
    required this.createdAtDate,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json["id"] as String?,
      uuid: json["uuid"] as String?,
      orderId: json["order_id"] as String?,
      userId: json["user_id"] as String?,
      type: json["type"] as String?,
      caption: json["caption"] as String?,
      remarks: json["remarks"] as String?,
      messageType: json["message_type"] as String?,
      phoneNumber: json["phone_number"] as String?,
      message: json["message"] as String?,
      fileUrl: json["file_url"],
      statusMessage: json["status_message"] as String?,
      statusGcm: json["status_gcm"] as String?,
      statusSms: json["status_sms"] as String?,
      statusWhatsapp: json["status_whatsapp"] as String?,
      statusWhatsappClient: json["status_whatsapp_client"] as String?,
      statusEmail: json["status_email"] as String?,
      fcmResponse: json["fcm_response"] as String?,
      smsResponse: json["sms_response"] as String?,
      whatsappResponse: json["whatsapp_response"] as String?,
      whatsappResponseClient: json["whatsapp_response_client"] as String?,
      whatsappId: json["whatsapp_id"] as String?,
      whatsappIdClient: json["whatsapp_id_client"] as String?,
      emailResponse: json["email_response"] as String?,
      status: json["status"] as String?,
      deleted: json["deleted"] as String?,
      createdAt: json["created_at"] as String?,
      createdAtDate: json["created_at_date"] as String?,
      createdBy: json["created_by"] as String?,
      updatedAt: json["updated_at"],
      updatedBy: json["updated_by"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "order_id": orderId,
        "user_id": userId,
        "type": type,
        "caption": caption,
        "remarks": remarks,
        "message_type": messageType,
        "phone_number": phoneNumber,
        "message": message,
        "file_url": fileUrl,
        "status_message": statusMessage,
        "status_gcm": statusGcm,
        "status_sms": statusSms,
        "status_whatsapp": statusWhatsapp,
        "status_whatsapp_client": statusWhatsappClient,
        "status_email": statusEmail,
        "fcm_response": fcmResponse,
        "sms_response": smsResponse,
        "whatsapp_response": whatsappResponse,
        "whatsapp_response_client": whatsappResponseClient,
        "whatsapp_id": whatsappId,
        "whatsapp_id_client": whatsappIdClient,
        "email_response": emailResponse,
        "status": status,
        "deleted": deleted,
        "created_at": createdAt,
        "created_at_date": createdAtDate,
        "created_by": createdBy,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
      };
}

class Order {
  final String? id;
  final String? uuid;
  final String? requestNumber;
  final String? qrCode;
  final String? hcoId;
  final String? orgId;
  final String? roundId;
  final String? stockId;
  final String? stockDetails;
  final String? phoneNumber;
  final String? uhid;
  final String? patientName;
  final String? fullName;
  final String? departmentUuid;
  final String? roomUuid;
  final String? serviceUuid;
  final String? qrCodeUuid;
  final String? assignedToUuid;
  final String? departmentId;
  final String? departmentName;
  final String? roomId;
  final String? roomNumber;
  final String? blockName;
  final String? floorName;
  final String? parentId;
  final String? serviceId;
  final String? assignedTo;
  final String? assignedToUsername;
  final String? serviceName;
  final String? notes;
  final List<dynamic> checklist;
  final List<dynamic> addons;
  final String? escalation;
  final String? escalationCount;
  final String? fileName;
  final String? requestStatus;
  final String? requestType;
  final String? priority;
  final String? rating;
  final String? source;
  final String? mapLong;
  final String? mapLat;
  final String? mapDistance;
  final String? completedBy;
  final List<dynamic> jsonChildren;
  final String? rca;
  final String? capa;
  final String? rcaUserId;
  final String? capaUserId;
  final String? status;
  final String? statusInformed;
  final String? statusInformedSup;
  final DateTime? timeStart;
  final String? timeAssigned;
  final String? timeAccepted;
  final String? timeOnHold;
  final String? timeCompleted;
  final String? timeCanceled;
  final String? dateCompleted;
  final String? timeHoldTill;
  final String? dateHoldTill;
  final String? secNewAsi;
  final String? secAsiAcc;
  final String? secNewComp;
  final String? secAsiComp;
  final String? secAccComp;
  final String? slaAssignType;
  final String? slaAcceptType;
  final String? slaCompleteType;
  final String? slaAssign;
  final String? slaAccept;
  final String? slaComplete;
  final String? slaAssignSec;
  final String? slaAcceptSec;
  final String? slaCompleteSec;
  final String? slaCount;
  final String? deleted;
  final String? createdAt;
  final String? createdAtDate;
  final String? createdBy;
  final dynamic updatedAt;
  final String? updatedBy;

  Order({
    required this.id,
    required this.uuid,
    required this.requestNumber,
    required this.qrCode,
    required this.hcoId,
    required this.orgId,
    required this.roundId,
    required this.stockId,
    required this.stockDetails,
    required this.phoneNumber,
    required this.uhid,
    required this.patientName,
    required this.fullName,
    required this.departmentUuid,
    required this.roomUuid,
    required this.serviceUuid,
    required this.qrCodeUuid,
    required this.assignedToUuid,
    required this.departmentId,
    required this.departmentName,
    required this.roomId,
    required this.roomNumber,
    required this.blockName,
    required this.floorName,
    required this.parentId,
    required this.serviceId,
    required this.assignedTo,
    required this.assignedToUsername,
    required this.serviceName,
    required this.notes,
    required this.checklist,
    required this.addons,
    required this.escalation,
    required this.escalationCount,
    required this.fileName,
    required this.requestStatus,
    required this.requestType,
    required this.priority,
    required this.rating,
    required this.source,
    required this.mapLong,
    required this.mapLat,
    required this.mapDistance,
    required this.completedBy,
    required this.jsonChildren,
    required this.rca,
    required this.capa,
    required this.rcaUserId,
    required this.capaUserId,
    required this.status,
    required this.statusInformed,
    required this.statusInformedSup,
    required this.timeStart,
    required this.timeAssigned,
    required this.timeAccepted,
    required this.timeOnHold,
    required this.timeCompleted,
    required this.timeCanceled,
    required this.dateCompleted,
    required this.timeHoldTill,
    required this.dateHoldTill,
    required this.secNewAsi,
    required this.secAsiAcc,
    required this.secNewComp,
    required this.secAsiComp,
    required this.secAccComp,
    required this.slaAssignType,
    required this.slaAcceptType,
    required this.slaCompleteType,
    required this.slaAssign,
    required this.slaAccept,
    required this.slaComplete,
    required this.slaAssignSec,
    required this.slaAcceptSec,
    required this.slaCompleteSec,
    required this.slaCount,
    required this.deleted,
    required this.createdAt,
    required this.createdAtDate,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"] as String?,
      uuid: json["uuid"] as String?,
      requestNumber: json["request_number"] as String?,
      qrCode: json["qr_code"] as String?,
      hcoId: json["hco_id"] as String?,
      orgId: json["org_id"] as String?,
      roundId: json["round_id"] as String?,
      stockId: json["stock_id"] as String?,
      stockDetails: json["stock_details"] as String?,
      phoneNumber: json["phone_number"] as String?,
      uhid: json["uhid"] as String?,
      patientName: json["patient_name"] as String?,
      fullName: json["full_name"] as String?,
      departmentUuid: json["department_uuid"] as String?,
      roomUuid: json["room_uuid"] as String?,
      serviceUuid: json["service_uuid"] as String?,
      qrCodeUuid: json["qr_code_uuid"] as String?,
      assignedToUuid: json["assigned_to_uuid"] as String?,
      departmentId: json["department_id"] as String?,
      departmentName: json["department_name"] as String?,
      roomId: json["room_id"] as String?,
      roomNumber: json["room_number"] as String?,
      blockName: json["block_name"] as String?,
      floorName: json["floor_name"] as String?,
      parentId: json["parent_id"] as String?,
      serviceId: json["service_id"] as String?,
      assignedTo: json["assigned_to"] as String?,
      assignedToUsername: json["assigned_to_username"] as String?,
      serviceName: json["service_name"] as String?,
      notes: json["notes"] as String?,
      checklist: json["checklist"] != null
          ? List<dynamic>.from(json["checklist"].map((x) => x))
          : [],
      addons: json["addons"] != null
          ? List<dynamic>.from(json["addons"].map((x) => x))
          : [],
      escalation: json["escalation"] as String?,
      escalationCount: json["escalation_count"] as String?,
      fileName: json["file_name"] as String?,
      requestStatus: json["request_status"] as String?,
      requestType: json["request_type"] as String?,
      priority: json["priority"] as String?,
      rating: json["rating"] as String?,
      source: json["source"] as String?,
      mapLong: json["map_long"] as String?,
      mapLat: json["map_lat"] as String?,
      mapDistance: json["map_distance"] as String?,
      completedBy: json["completed_by"] as String?,
      jsonChildren: json["json_children"] != null
          ? List<dynamic>.from(json["json_children"].map((x) => x))
          : [],
      rca: json["rca"] as String?,
      capa: json["capa"] as String?,
      rcaUserId: json["rca_user_id"] as String?,
      capaUserId: json["capa_user_id"] as String?,
      status: json["status"] as String?,
      statusInformed: json["status_informed"] as String?,
      statusInformedSup: json["status_informed_sup"] as String?,
      timeStart: json["time_start"] != null
          ? DateTime.tryParse(json["time_start"] as String)
          : null,
      timeAssigned: json["time_assigned"] as String?,
      timeAccepted: json["time_accepted"] as String?,
      timeOnHold: json["time_on_hold"] as String?,
      timeCompleted: json["time_completed"] as String?,
      timeCanceled: json["time_canceled"] as String?,
      dateCompleted: json["date_completed"] as String?,
      timeHoldTill: json["time_hold_till"] as String?,
      dateHoldTill: json["date_hold_till"] as String?,
      secNewAsi: json["sec_new_asi"] as String?,
      secAsiAcc: json["sec_asi_acc"] as String?,
      secNewComp: json["sec_new_comp"] as String?,
      secAsiComp: json["sec_asi_comp"] as String?,
      secAccComp: json["sec_acc_comp"] as String?,
      slaAssignType: json["sla_assign_type"] as String?,
      slaAcceptType: json["sla_accept_type"] as String?,
      slaCompleteType: json["sla_complete_type"] as String?,
      slaAssign: json["sla_assign"] as String?,
      slaAccept: json["sla_accept"] as String?,
      slaComplete: json["sla_complete"] as String?,
      slaAssignSec: json["sla_assign_sec"] as String?,
      slaAcceptSec: json["sla_accept_sec"] as String?,
      slaCompleteSec: json["sla_complete_sec"] as String?,
      slaCount: json["sla_count"] as String?,
      deleted: json["deleted"] as String?,
      createdAt: json["created_at"] as String?,
      createdAtDate: json["created_at_date"] as String?,
      createdBy: json["created_by"] as String?,
      updatedAt: json["updated_at"],
      updatedBy: json["updated_by"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "request_number": requestNumber,
        "qr_code": qrCode,
        "hco_id": hcoId,
        "org_id": orgId,
        "round_id": roundId,
        "stock_id": stockId,
        "stock_details": stockDetails,
        "phone_number": phoneNumber,
        "uhid": uhid,
        "patient_name": patientName,
        "full_name": fullName,
        "department_uuid": departmentUuid,
        "room_uuid": roomUuid,
        "service_uuid": serviceUuid,
        "qr_code_uuid": qrCodeUuid,
        "assigned_to_uuid": assignedToUuid,
        "department_id": departmentId,
        "department_name": departmentName,
        "room_id": roomId,
        "room_number": roomNumber,
        "block_name": blockName,
        "floor_name": floorName,
        "parent_id": parentId,
        "service_id": serviceId,
        "assigned_to": assignedTo,
        "assigned_to_username": assignedToUsername,
        "service_name": serviceName,
        "notes": notes,
        "checklist": checklist,
        "addons": addons,
        "escalation": escalation,
        "escalation_count": escalationCount,
        "file_name": fileName,
        "request_status": requestStatus,
        "request_type": requestType,
        "priority": priority,
        "rating": rating,
        "source": source,
        "map_long": mapLong,
        "map_lat": mapLat,
        "map_distance": mapDistance,
        "completed_by": completedBy,
        "json_children": jsonChildren,
        "rca": rca,
        "capa": capa,
        "rca_user_id": rcaUserId,
        "capa_user_id": capaUserId,
        "status": status,
        "status_informed": statusInformed,
        "status_informed_sup": statusInformedSup,
        "time_start": timeStart?.toIso8601String(),
        "time_assigned": timeAssigned,
        "time_accepted": timeAccepted,
        "time_on_hold": timeOnHold,
        "time_completed": timeCompleted,
        "time_canceled": timeCanceled,
        "date_completed": dateCompleted,
        "time_hold_till": timeHoldTill,
        "date_hold_till": dateHoldTill,
        "sec_new_asi": secNewAsi,
        "sec_asi_acc": secAsiAcc,
        "sec_new_comp": secNewComp,
        "sec_asi_comp": secAsiComp,
        "sec_acc_comp": secAccComp,
        "sla_assign_type": slaAssignType,
        "sla_accept_type": slaAcceptType,
        "sla_complete_type": slaCompleteType,
        "sla_assign": slaAssign,
        "sla_accept": slaAccept,
        "sla_complete": slaComplete,
        "sla_assign_sec": slaAssignSec,
        "sla_accept_sec": slaAcceptSec,
        "sla_complete_sec": slaCompleteSec,
        "sla_count": slaCount,
        "deleted": deleted,
        "created_at": createdAt,
        "created_at_date": createdAtDate,
        "created_by": createdBy,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
      };
}

class RoundAnswer {
  final String? departmentId;
  final String? roundId;
  final String? valueInt;
  final String? valueString;

  RoundAnswer({
    required this.departmentId,
    required this.roundId,
    required this.valueInt,
    required this.valueString,
  });

  factory RoundAnswer.fromJson(Map<String, dynamic> json) {
    return RoundAnswer(
      departmentId: json["department_id"] as String?,
      roundId: json["round_id"] as String?,
      valueInt: json["value_int"] as String?,
      valueString: json["value_string"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "department_id": departmentId,
        "round_id": roundId,
        "value_int": valueInt,
        "value_string": valueString,
      };
}

class Users {
  final List<Map<String, String>> result;
  final int? count;
  final int? total;
  final String? caption;
  final String? pagination;

  Users({
    required this.result,
    required this.count,
    required this.total,
    required this.caption,
    required this.pagination,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      result: json["RESULT"] != null
          ? List<Map<String, String>>.from(json["RESULT"].map((x) =>
              Map<String, String>.from(x.map((k, v) => MapEntry(k, v.toString())))))
          : [],
      count: json["COUNT"] as int?,
      total: json["TOTAL"] as int?,
      caption: json["CAPTION"] as String?,
      pagination: json["PAGINATION"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "RESULT": result,
        "COUNT": count,
        "TOTAL": total,
        "CAPTION": caption,
        "PAGINATION": pagination,
      };
}