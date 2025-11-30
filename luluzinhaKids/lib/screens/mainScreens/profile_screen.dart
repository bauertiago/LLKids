import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

import '../accessScreens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  bool loading = true;

  bool showNotifications = false;
  bool showOrders = false;
  bool showPersonalData = false;
  bool showChangePassword = false;

  bool notificationsEnabled = false;

  bool showPasswordCurrent = false;
  bool showPasswordNew = false;
  bool showPasswordConfirm = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    setState(() {
      userData = doc.data();
      loading = false;
    });
  }

  Future<void> _changePassword() async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showMsg("Preencha todos os campos.");
      return;
    }

    if (newPass.length < 8) {
      _showMsg("A nova senha deve ter ao menos 8 caracteres.");
      return;
    }

    if (newPass != confirm) {
      _showMsg("As senhas não coincidem.");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );

      // Reautenticar antes de alterar senha
      await user.reauthenticateWithCredential(cred);

      // Trocar senha
      await user.updatePassword(newPass);

      _showMsg("Senha alterada com sucesso! 🔒");

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      _showMsg("Senha atual incorreta ou sessão expirada.");
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.secondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (userData == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Erro ao carregar dados do usuário.",
            style: context.texts.bodyLarge,
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(showBackButton: true, showLogo: true),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Perfil", style: context.texts.titleLarge),
              ),
            ),

            const SizedBox(height: 16),
            _buildProfileHeader(),
            const SizedBox(height: 16),

            Expanded(child: _buildSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 90,
                height: 90,
                color: context.colors.secondary.withValues(alpha: 0.5),
                child: Icon(
                  Icons.account_circle,
                  size: 90,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: context.colors.secondary.withValues(
                  alpha: 0.9,
                ),
                child: Icon(Icons.camera_alt, size: 24, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(userData!["name"], style: context.texts.titleMedium),
        Text(userData!["email"], style: context.texts.titleSmall),
      ],
    );
  }

  Widget _buildSection(BuildContext context) {
    return ListView(
      children: [
        _buildOption(
          icon: Icons.notifications_none,
          title: "Notificações",
          expanded: showNotifications,
          onTap: () => setState(() => showNotifications = !showNotifications),
        ),

        if (showNotifications) _buildNotificationsSection(),

        _divider(),

        _buildOption(
          icon: Icons.local_shipping_outlined,
          title: "Meus Pedidos",
          expanded: showOrders,
          onTap: () => setState(() => showOrders = !showOrders),
        ),
        if (showOrders) _buildOrdersSection(),

        _divider(),

        _buildOption(
          icon: Icons.person_outline,
          title: "Dados Pessoais",
          expanded: showPersonalData,
          onTap: () => setState(() => showPersonalData = !showPersonalData),
        ),
        if (showPersonalData) _buildPersonalDataSection(),

        _divider(),

        _buildOption(
          icon: Icons.lock_outline,
          title: "Alterar Senha",
          expanded: showChangePassword,
          onTap: () => setState(() => showChangePassword = !showChangePassword),
        ),
        if (showChangePassword) _buildChangePasswordSection(),

        const SizedBox(height: 12),
        _buildExitOption(),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colors.secondary),
      title: Text(title, style: context.texts.titleMedium),
      trailing: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        size: 24,
        color: context.colors.secondary,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quer ficar por dentro das novidades e promoções imperdíveis?\nAtive as notificações e não perca nenhuma oferta!",
            style: context.texts.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                notificationsEnabled ? "ON" : "OFF",
                style: context.texts.bodyMedium!.copyWith(
                  color:
                      notificationsEnabled
                          ? const Color(0xFFFF2BA9)
                          : const Color(0xFF8A9BD9),
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: notificationsEnabled,
                onChanged: (v) => setState(() => notificationsEnabled = v),
                activeColor: const Color(0xFFFF2BA9),
                inactiveThumbColor: const Color(0xFF8A9BD9),
                inactiveTrackColor: const Color(
                  0xFF8A9BD9,
                ).withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pedido 00000001", style: context.texts.titleSmall),
          const SizedBox(height: 8),

          _buildOrderStatus(
            label: "Pedido Realizado",
            date: "15/10/2025",
            completed: true,
          ),
          _buildOrderStatus(
            label: "Pedido Enviado",
            date: "16/10/2025",
            completed: true,
          ),
          _buildOrderStatus(
            label: "Pedido Entregue",
            date: "",
            completed: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus({
    required String label,
    required String date,
    required bool completed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? context.colors.primary : Colors.grey,
          size: 22,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.texts.bodyMedium),
            if (date.isNotEmpty) Text(date, style: context.texts.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalDataSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _info("Nome", userData!["name"]),
          _info("Email", userData!["email"].replaceRange(3, 8, "*****")),
          _info("Telefone", userData!["phone"].replaceRange(5, 10, "*****")),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: context.texts.bodyMedium,
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sua senha deve conter no mínimo 8 caracteres.",
            style: context.texts.bodySmall,
          ),

          const SizedBox(height: 12),

          _passwordField(
            "Digite a senha atual",
            showPasswordCurrent,
            () => setState(() => showPasswordCurrent = !showPasswordCurrent),
            controller: currentPasswordController,
          ),

          const SizedBox(height: 12),

          _passwordField(
            "Nova senha",
            showPasswordNew,
            () => setState(() => showPasswordNew = !showPasswordNew),
            controller: newPasswordController,
          ),

          const SizedBox(height: 12),

          _passwordField(
            "Confirme a senha",
            showPasswordConfirm,
            () => setState(() => showPasswordConfirm = !showPasswordConfirm),
            controller: confirmPasswordController,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2BA9),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _changePassword,
              child: const Text(
                "Confirmar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(
    String label,
    bool visible,
    VoidCallback toggle, {
    required TextEditingController controller,
  }) {
    return CustomInput(
      label: label,
      requiredField: true,
      hintText: label,
      prefixIcon: Icons.lock_outline,
      obscureText: !visible,
      controller: controller,
      suffixIcon: IconButton(
        icon: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: toggle,
      ),
    );
  }

  Widget _buildExitOption() {
    return ListTile(
      leading: Icon(Icons.exit_to_app, color: context.colors.secondary),
      title: Text("Sair", style: context.texts.bodyLarge),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }
}
