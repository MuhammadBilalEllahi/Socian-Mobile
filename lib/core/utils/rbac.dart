import 'package:socian/core/utils/constants.dart';

class Permissions {
  static const superAdmin = {
    'hidePost': 'super_admin:hide_post',
    'hideTeacherModal': 'super_admin:hide_teacher_modal',
    'manageUsers': 'super_admin:manage_users',
    'manageRoles': 'super_admin:manage_roles',
    'manageSettings': 'super_admin:manage_settings',
  };

  static const moderator = {
    'hidePost': 'mod:hide_post',
    'hideTeacherReview': 'mod:hide_teacher_review',
    'hideTeacherModal': 'mod:hide_teacher_modal',
    'hideFeedBackRootReply': 'mod:hide_feed_back_root_reply',
    'hideFeedBackReplyKaReply': 'mod:hide_feed_back_reply_ka_reply',
    'manageContent': 'mod:manage_content',
    'manageComments': 'mod:manage_comments',
    'viewAll': 'view:all',
  };

  static const teacher = {
    'uploadContent': 'teacher:upload_content',
    'viewTeacherContent': 'view:teacher_content',
  };

  static const student = {
    'viewReviews': 'student:view_reviews',
    'submitPapers': 'student:submit_papers',
  };

  static const alumni = {
    'viewReviews': 'alumni:view_reviews',
    'viewPapers': 'alumni:view_papers',
  };
}

enum SuperAdminPermissionsEnum {
  hidePost,
  hideTeacherModal,
  manageUsers,
  manageRoles,
  manageSettings;

  String get permission => Permissions.superAdmin[name]!;
}

enum ModeratorPermissionsEnum {
  hidePost,
  hideTeacherReview,
  hideTeacherModal,
  hideFeedBackRootReply,
  hideFeedBackReplyKaReply,
  manageContent,
  manageComments,
  viewAll;

  String get permission => Permissions.moderator[name]!;
}

enum TeacherPermissionsEnum {
  uploadContent,
  viewTeacherContent;

  String get permission => Permissions.teacher[name]!;
}

enum StudentPermissionsEnum {
  viewReviews,
  submitPapers;

  String get permission => Permissions.student[name]!;
}

enum AlumniPermissionsEnum {
  viewReviews,
  viewPapers;

  String get permission => Permissions.alumni[name]!;
}

class RBAC {
  // Maps for role and super role permissions
  static final Map<String, List<String>> rolePermissions = {
    AppRoles.teacher: [
      Permissions.teacher[TeacherPermissionsEnum.uploadContent.name]!,
      Permissions.teacher[TeacherPermissionsEnum.viewTeacherContent.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.viewAll.name]!,
    ],
    AppRoles.student: [
      Permissions.student[StudentPermissionsEnum.viewReviews.name]!,
      Permissions.student[StudentPermissionsEnum.submitPapers.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.viewAll.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.hideTeacherModal.name]!,
    ],
    AppRoles.alumni: [
      Permissions.alumni[AlumniPermissionsEnum.viewReviews.name]!,
      Permissions.alumni[AlumniPermissionsEnum.viewPapers.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.viewAll.name]!,
    ],
  };

  static final Map<String, List<String>> superRolePermissions = {
    AppSuperRoles.superAdmin: [
      ...Permissions.superAdmin.values,
      ...Permissions.moderator.values,
    ],
    AppSuperRoles.moderator: [
      Permissions.moderator[ModeratorPermissionsEnum.hidePost.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.hideTeacherModal.name]!,
      Permissions
          .moderator[ModeratorPermissionsEnum.hideFeedBackRootReply.name]!,
      Permissions
          .moderator[ModeratorPermissionsEnum.hideFeedBackReplyKaReply.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.manageContent.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.manageComments.name]!,
      Permissions.moderator[ModeratorPermissionsEnum.viewAll.name]!,
    ],
  };

  // Check if user has a specific super role
  static bool hasSuperRole(Map<String, dynamic>? user, String superRole) {
    if (user == null) return false;
    return user['super_role'] == superRole;
  }

  // Check if user has any super role
  static bool hasAnySuperRole(Map<String, dynamic>? user) {
    if (user == null) return false;
    final superRole = user['super_role'];
    return superRole == AppSuperRoles.superAdmin ||
        superRole == AppSuperRoles.moderator;
  }

  // Check if a permission matches any of the given prefixes
  static bool permissionMatches(String permission, List<String> prefixes) {
    return prefixes.any((prefix) => permission.startsWith(prefix));
  }

  // Check if user has a specific permission
  static bool hasPermission(Map<String, dynamic>? user, String permission) {
    if (user == null) return false;

    final role = user['role'];
    final superRole = user['super_role'];

    if (superRole == AppSuperRoles.superAdmin) return true;

    if (superRole == AppSuperRoles.moderator) {
      return permissionMatches(permission, ['mod:', 'view:']);
    }

    switch (role) {
      case AppRoles.teacher:
        return permissionMatches(permission, ['teacher:', 'view:']);
      case AppRoles.student:
        return permissionMatches(permission, ['student:', 'view:']);
      case AppRoles.alumni:
        return permissionMatches(permission, ['alumni:', 'view:']);
      default:
        return false;
    }
  }

  // Get all permissions of a user
  static List<String> getUserPermissions(Map<String, dynamic>? user) {
    if (user == null) return [];

    final role = user['role'];
    final superRole = user['super_role'];

    return [
      ...?superRolePermissions[superRole],
      ...?rolePermissions[role],
    ];
  }
}
