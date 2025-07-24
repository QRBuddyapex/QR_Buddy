class ManagementFormModel {
    ManagementFormModel({
        required this.category,
        required this.parameters,
        required this.urlReview,
        required this.htmlTerms,
        required this.logo,
        required this.displayType,
        required this.remarks,
        required this.status,
        required this.message,
    });

    final Category? category;
    final List<Parameter> parameters;
    final String? urlReview;
    final String? htmlTerms;
    final String? logo;
    final DisplayType? displayType;
    final String? remarks;
    final int? status;
    final String? message;

    factory ManagementFormModel.fromJson(Map<String, dynamic> json){ 
        return ManagementFormModel(
            category: json["category"] == null ? null : Category.fromJson(json["category"]),
            parameters: json["parameters"] == null ? [] : List<Parameter>.from(json["parameters"]!.map((x) => Parameter.fromJson(x))),
            urlReview: json["url_review"],
            htmlTerms: json["html_terms"],
            logo: json["logo"],
            displayType: json["displayType"] == null ? null : DisplayType.fromJson(json["displayType"]),
            remarks: json["remarks"],
            status: json["status"],
            message: json["message"],
        );
    }

    Map<String, dynamic> toJson() => {
        "category": category?.toJson(),
        "parameters": parameters.map((x) => x?.toJson()).toList(),
        "url_review": urlReview,
        "html_terms": htmlTerms,
        "logo": logo,
        "displayType": displayType?.toJson(),
        "remarks": remarks,
        "status": status,
        "message": message,
    };

}

class Category {
    Category({
        required this.id,
        required this.uuid,
        required this.hcoId,
        required this.committeeId,
        required this.layout,
        required this.type,
        required this.iconUrl,
        required this.invitationTemplate,
        required this.invitationVariables,
        required this.invitationValidity,
        required this.html,
        required this.htmlTerms,
        required this.frequency,
        required this.frequencies,
        required this.frequencyData,
        required this.reminders,
        required this.validity,
        required this.roomIds,
        required this.graceDays,
        required this.categoryName,
        required this.categoryNameLang,
        required this.statusRemarks,
        required this.remarksTitle,
        required this.notifyMinutes,
        required this.statusNoScheduling,
        required this.statusPrivate,
        required this.statusNps,
        required this.statusLogin,
        required this.statusManualLock,
        required this.status,
        required this.deleted,
        required this.createdAt,
        required this.createdAtDate,
        required this.createdBy,
        required this.updatedAt,
        required this.updatedBy,
    });

    final String? id;
    final String? uuid;
    final String? hcoId;
    final String? committeeId;
    final String? layout;
    final String? type;
    final String? iconUrl;
    final String? invitationTemplate;
    final String? invitationVariables;
    final String? invitationValidity;
    final String? html;
    final String? htmlTerms;
    final String? frequency;
    final String? frequencies;
    final String? frequencyData;
    final String? reminders;
    final String? validity;
    final String? roomIds;
    final String? graceDays;
    final String? categoryName;
    final String? categoryNameLang;
    final String? statusRemarks;
    final String? remarksTitle;
    final String? notifyMinutes;
    final String? statusNoScheduling;
    final String? statusPrivate;
    final String? statusNps;
    final String? statusLogin;
    final String? statusManualLock;
    final String? status;
    final String? deleted;
    final DateTime? createdAt;
    final DateTime? createdAtDate;
    final String? createdBy;
    final dynamic updatedAt;
    final String? updatedBy;

    factory Category.fromJson(Map<String, dynamic> json){ 
        return Category(
            id: json["id"],
            uuid: json["uuid"],
            hcoId: json["hco_id"],
            committeeId: json["committee_id"],
            layout: json["layout"],
            type: json["type"],
            iconUrl: json["icon_url"],
            invitationTemplate: json["invitation_template"],
            invitationVariables: json["invitation_variables"],
            invitationValidity: json["invitation_validity"],
            html: json["html"],
            htmlTerms: json["html_terms"],
            frequency: json["frequency"],
            frequencies: json["frequencies"],
            frequencyData: json["frequency_data"],
            reminders: json["reminders"],
            validity: json["validity"],
            roomIds: json["room_ids"],
            graceDays: json["grace_days"],
            categoryName: json["category_name"],
            categoryNameLang: json["category_name_lang"],
            statusRemarks: json["status_remarks"],
            remarksTitle: json["remarks_title"],
            notifyMinutes: json["notify_minutes"],
            statusNoScheduling: json["status_no_scheduling"],
            statusPrivate: json["status_private"],
            statusNps: json["status_nps"],
            statusLogin: json["status_login"],
            statusManualLock: json["status_manual_lock"],
            status: json["status"],
            deleted: json["deleted"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            createdAtDate: DateTime.tryParse(json["created_at_date"] ?? ""),
            createdBy: json["created_by"],
            updatedAt: json["updated_at"],
            updatedBy: json["updated_by"],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "hco_id": hcoId,
        "committee_id": committeeId,
        "layout": layout,
        "type": type,
        "icon_url": iconUrl,
        "invitation_template": invitationTemplate,
        "invitation_variables": invitationVariables,
        "invitation_validity": invitationValidity,
        "html": html,
        "html_terms": htmlTerms,
        "frequency": frequency,
        "frequencies": frequencies,
        "frequency_data": frequencyData,
        "reminders": reminders,
        "validity": validity,
        "room_ids": roomIds,
        "grace_days": graceDays,
        "category_name": categoryName,
        "category_name_lang": categoryNameLang,
        "status_remarks": statusRemarks,
        "remarks_title": remarksTitle,
        "notify_minutes": notifyMinutes,
        "status_no_scheduling": statusNoScheduling,
        "status_private": statusPrivate,
        "status_nps": statusNps,
        "status_login": statusLogin,
        "status_manual_lock": statusManualLock,
        "status": status,
        "deleted": deleted,
        "created_at": createdAt?.toIso8601String(),
        "created_at_date": "${createdAtDate?.year.toString().padLeft(4,'0')}-${createdAtDate?.month.toString().padLeft(2,'0')}-${createdAtDate?.day.toString().padLeft(2,'0')}",
        "created_by": createdBy,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
    };

}

class DisplayType {
    DisplayType({
        required this.num,
        required this.slt,
        required this.mlt,
        required this.sel,
        required this.chk,
        required this.mchk,
        required this.rad,
        required this.str,
        required this.yn,
        required this.emj,
    });

    final String? num;
    final String? slt;
    final String? mlt;
    final String? sel;
    final String? chk;
    final String? mchk;
    final String? rad;
    final String? str;
    final String? yn;
    final String? emj;

    factory DisplayType.fromJson(Map<String, dynamic> json){ 
        return DisplayType(
            num: json["NUM"],
            slt: json["SLT"],
            mlt: json["MLT"],
            sel: json["SEL"],
            chk: json["CHK"],
            mchk: json["MCHK"],
            rad: json["RAD"],
            str: json["STR"],
            yn: json["YN"],
            emj: json["EMJ"],
        );
    }

    Map<String, dynamic> toJson() => {
        "NUM": num,
        "SLT": slt,
        "MLT": mlt,
        "SEL": sel,
        "CHK": chk,
        "MCHK": mchk,
        "RAD": rad,
        "STR": str,
        "YN": yn,
        "EMJ": emj,
    };

}

class Parameter {
    Parameter({
        required this.id,
        required this.uuid,
        required this.categoryId,
        required this.tag,
        required this.parameterName,
        required this.dataEntryType,
        required this.valueMin,
        required this.valueMax,
        required this.valueUnit,
        required this.valueDefault,
        required this.specifyStatus,
        required this.specifyTitle,
        required this.statusAskDate,
        required this.statusImage,
        required this.statusAskProgress,
        required this.complaintConditions,
        required this.valueInt,
        required this.valueString,
        required this.question,
        required this.choices,
    });

    final String? id;
    final String? uuid;
    final String? categoryId;
    final String? tag;
    final String? parameterName;
    final String? dataEntryType;
    final String? valueMin;
    final String? valueMax;
    final String? valueUnit;
    final String? valueDefault;
    final String? specifyStatus;
    final String? specifyTitle;
    final String? statusAskDate;
    final String? statusImage;
    final String? statusAskProgress;
    final dynamic complaintConditions;
    final String? valueInt;
    final String? valueString;
    final String? question;
    final List<dynamic> choices;

    factory Parameter.fromJson(Map<String, dynamic> json){ 
        return Parameter(
            id: json["id"],
            uuid: json["uuid"],
            categoryId: json["category_id"],
            tag: json["tag"],
            parameterName: json["parameter_name"],
            dataEntryType: json["data_entry_type"],
            valueMin: json["value_min"],
            valueMax: json["value_max"],
            valueUnit: json["value_unit"],
            valueDefault: json["value_default"],
            specifyStatus: json["specify_status"],
            specifyTitle: json["specify_title"],
            statusAskDate: json["status_ask_date"],
            statusImage: json["status_image"],
            statusAskProgress: json["status_ask_progress"],
            complaintConditions: json["complaint_conditions"],
            valueInt: json["value_int"],
            valueString: json["value_string"],
            question: json["question"],
            choices: json["choices"] == null ? [] : List<dynamic>.from(json["choices"]!.map((x) => x)),
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "category_id": categoryId,
        "tag": tag,
        "parameter_name": parameterName,
        "data_entry_type": dataEntryType,
        "value_min": valueMin,
        "value_max": valueMax,
        "value_unit": valueUnit,
        "value_default": valueDefault,
        "specify_status": specifyStatus,
        "specify_title": specifyTitle,
        "status_ask_date": statusAskDate,
        "status_image": statusImage,
        "status_ask_progress": statusAskProgress,
        "complaint_conditions": complaintConditions,
        "value_int": valueInt,
        "value_string": valueString,
        "question": question,
        "choices": choices.map((x) => x).toList(),
    };

}
