import 'package:flutter/material.dart';
import 'package:socian/shared/services/api_client.dart';

class RolesPage extends StatelessWidget {
  final Map<String, Color> colors;
  final List<dynamic> roles;
  final bool showEdit;
  final String societyId;
  final VoidCallback onAddRole;

  const RolesPage({
    super.key,
    required this.colors,
    required this.roles,
    required this.showEdit,
    required this.societyId,
    required this.onAddRole,
  });

  Future<void> _showAddRoleDialog(BuildContext context) async {
    final apiClient = ApiClient();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AddRoleDialog(
        colors: colors,
        societyId: societyId,
        apiClient: apiClient,
        onSave: onAddRole,
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role added successfully')),
      );
    }
  }

  Future<bool> _showDeleteRoleConfirmationDialog(
      BuildContext context, String roleTitle) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colors['bg'],
            surfaceTintColor: colors['bg'],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors['border']!, width: 1.5),
            ),
            title: Text(
              'Delete Role',
              style: TextStyle(
                color: colors['fg'],
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete the role "$roleTitle"? This action cannot be undone.',
              style: TextStyle(
                color: colors['fg'],
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colors['muted'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteRole(
      BuildContext context, String roleId, String roleTitle) async {
    final confirmed =
        await _showDeleteRoleConfirmationDialog(context, roleTitle);
    if (!confirmed || !context.mounted) return;

    try {
      final apiClient = ApiClient();
      await apiClient.post('/api/society/delete-role/$societyId', {
        'roleId': roleId,
      });
      onAddRole();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: colors['bg'],
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors['fg']),
        title: Text(
          'Roles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors['fg'],
            letterSpacing: -0.3,
          ),
        ),
        titleSpacing: 0,
        actions: [
          if (showEdit)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _showAddRoleDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors['border']!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors['border']!, width: 1.2),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colors['accent'],
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Roles',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colors['fg'],
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (showEdit)
                  GestureDetector(
                    onTap: () => _showAddRoleDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors['border']!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors['border']!, width: 1),
                      ),
                      child: Icon(
                        Icons.add,
                        color: colors['accent'],
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          roles.isNotEmpty || showEdit
              ? SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    itemCount: roles.length + (showEdit ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      if (showEdit && index == roles.length) {
                        return GestureDetector(
                          onTap: () => _showAddRoleDialog(context),
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: colors['bg'],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors['border']!,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 40,
                                color: colors['accent'],
                              ),
                            ),
                          ),
                        );
                      }

                      final role = roles[index];
                      final roleTitle = role['role'] ?? 'Unknown';
                      final roleName = role['name'] ?? 'Unknown';
                      final roleImage = role['picture'];
                      final roleId = role['_id']?.toString();

                      return RoleCard(
                        colors: colors,
                        roleImage: roleImage,
                        roleTitle: roleTitle,
                        roleName: roleName,
                        roleId: roleId ?? '',
                        showEdit: showEdit,
                        onDelete: (id, title) =>
                            _deleteRole(context, id, title),
                      );
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      'No roles assigned.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: colors['muted'],
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String? roleImage;
  final String roleTitle;
  final String roleName;
  final String roleId;
  final bool showEdit;
  final Function(String, String)? onDelete;
  final Map<String, Color> colors;

  const RoleCard({
    super.key,
    this.roleImage,
    required this.roleTitle,
    required this.roleName,
    required this.roleId,
    this.showEdit = false,
    this.onDelete,
    required this.colors,
  });

  Widget _buildImageFallback(Map<String, Color> colors) {
    return Container(
      color: colors['border']!.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: colors['muted'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 164,
          decoration: BoxDecoration(
            color: colors['bg'],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors['border']!,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: colors['accent']!.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: roleImage != null
                        ? Image.network(
                            roleImage!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: colors['border']!.withOpacity(0.1),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: colors['accent'],
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImageFallback(colors),
                          )
                        : _buildImageFallback(colors),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: colors['bg']!.withOpacity(0.98),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: colors['accent'],
                        letterSpacing: 0.8,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roleName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors['fg'],
                        letterSpacing: 0.1,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 24,
                      decoration: BoxDecoration(
                        color: colors['accent']!.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showEdit && roleId.isNotEmpty)
          Positioned(
            right: -6,
            top: -6,
            child: _EnhancedDeleteButton(
              onTap: () => onDelete?.call(roleId, roleTitle),
              colors: colors,
            ),
          ),
      ],
    );
  }
}

class _EnhancedDeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  final Map<String, Color> colors;

  const _EnhancedDeleteButton({
    required this.onTap,
    required this.colors,
  });

  @override
  State<_EnhancedDeleteButton> createState() => _EnhancedDeleteButtonState();
}

class _EnhancedDeleteButtonState extends State<_EnhancedDeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.redAccent.withOpacity(_isHovered ? 0.4 : 0.3),
                      blurRadius: _isHovered ? 8 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddRoleDialog extends StatefulWidget {
  final Map<String, Color> colors;
  final String societyId;
  final ApiClient apiClient;
  final VoidCallback onSave;

  const _AddRoleDialog({
    required this.colors,
    required this.societyId,
    required this.apiClient,
    required this.onSave,
  });

  @override
  _AddRoleDialogState createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<_AddRoleDialog> {
  final roleController = TextEditingController();
  final nameController = TextEditingController();
  final pictureController = TextEditingController();

  @override
  void dispose() {
    roleController.dispose();
    nameController.dispose();
    pictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.colors['bg'],
      surfaceTintColor: widget.colors['bg'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.colors['border']!, width: 1.5),
      ),
      title: Text(
        'Add Role',
        style: TextStyle(
          color: widget.colors['fg'],
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: roleController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Role Title (e.g., President)',
              labelStyle: TextStyle(color: widget.colors['muted']),
              filled: true,
              fillColor: widget.colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['accent']!),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: widget.colors['muted']),
              filled: true,
              fillColor: widget.colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['accent']!),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pictureController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Picture URL (optional)',
              labelStyle: TextStyle(color: widget.colors['muted']),
              filled: true,
              fillColor: widget.colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['accent']!),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: widget.colors['muted'],
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            'Save',
            style: TextStyle(
              color: widget.colors['accent'],
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final roleTitle = roleController.text.trim();
            final name = nameController.text.trim();
            final picture = pictureController.text.trim();
            if (roleTitle.isNotEmpty && name.isNotEmpty) {
              try {
                await widget.apiClient.post(
                  '/api/society/add-role/${widget.societyId}',
                  {
                    'role': roleTitle,
                    'name': name,
                    'picture': picture.isNotEmpty ? picture : null,
                  },
                );
                widget.onSave();
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            }
          },
        ),
      ],
    );
  }
}
