import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/app_user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _authService = AuthService();

  void _showEditUserDialog(AppUserModel user) {
    final nameController = TextEditingController(text: user.name);
    bool canSeeWholesale = user.canSeeWholesalePrice;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('تعديل بيانات الموظف'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الموظف'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('يستطيع رؤية سعر الجملة؟'),
                value: canSeeWholesale,
                onChanged: (v) => setStateDialog(() => canSeeWholesale = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            TextButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setStateDialog(() => isSaving = true);
                      try {
                        if (nameController.text.trim().isNotEmpty &&
                            nameController.text.trim() != user.name) {
                          await _authService.updateEmployeeName(
                            uid: user.uid,
                            name: nameController.text.trim(),
                          );
                        }
                        await _authService.updateEmployeePermissions(
                          uid: user.uid,
                          canSeeWholesalePrice: canSeeWholesale,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          Fluttertoast.showToast(msg: 'تم حفظ التعديلات');
                        }
                      } catch (e) {
                        setStateDialog(() => isSaving = false);
                        Fluttertoast.showToast(msg: 'حدث خطأ: ${e.toString()}');
                      }
                    },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool canSeeWholesale = false;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('إضافة موظف جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الموظف'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  textDirection: TextDirection.ltr,
                  decoration:
                      const InputDecoration(labelText: 'البريد الإلكتروني'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                      labelText: 'كلمة المرور (6 أحرف على الأقل)'),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('يستطيع رؤية سعر الجملة؟'),
                  value: canSeeWholesale,
                  onChanged: (v) => setStateDialog(() => canSeeWholesale = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            TextButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty ||
                          passwordController.text.trim().length < 6) {
                        Fluttertoast.showToast(
                            msg: 'برجاء إدخال بيانات صحيحة (كلمة المرور 6 أحرف على الأقل)');
                        return;
                      }
                      setStateDialog(() => isSaving = true);
                      try {
                        await _authService.createEmployeeAccount(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          canSeeWholesalePrice: canSeeWholesale,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          Fluttertoast.showToast(msg: 'تم إضافة الموظف بنجاح');
                        }
                      } catch (e) {
                        setStateDialog(() => isSaving = false);
                        Fluttertoast.showToast(msg: 'حدث خطأ: ${e.toString()}');
                      }
                    },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة المستخدمين')),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.accentOrange,
          onPressed: _showAddUserDialog,
          child: const Icon(Icons.person_add_alt_1),
        ),
        body: StreamBuilder<List<AppUserModel>>(
          stream: _authService.getAllUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isAdmin
                          ? AppColors.accentOrange.withOpacity(0.2)
                          : AppColors.primaryNavy.withOpacity(0.1),
                      child: Icon(
                        user.isAdmin
                            ? Icons.admin_panel_settings_outlined
                            : Icons.person_outline,
                        color: user.isAdmin
                            ? AppColors.accentOrange
                            : AppColors.primaryNavy,
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                        '${user.email}\n${user.isAdmin ? "مدير" : "موظف"} ${user.isActive ? "" : "- موقوف"}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!user.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primaryNavy),
                            onPressed: () => _showEditUserDialog(user),
                          ),
                        if (!user.isAdmin)
                          Switch(
                            value: user.isActive,
                            onChanged: (v) async {
                              if (v) {
                                await _authService.activateUser(user.uid);
                              } else {
                                await _authService.deactivateUser(user.uid);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
