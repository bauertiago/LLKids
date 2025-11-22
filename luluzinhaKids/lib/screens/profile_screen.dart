import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/services/customer_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

import '../models/customerModels/customer_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showNotifications = false;
  bool showOrders = false;
  bool showPersonalData = false;
  bool showChangePassword = false;

  bool notificationsEnabled = false;

  bool showPasswordCurrent = false;
  bool showPasswordNew = false;
  bool showPasswordConfirm = false;

  @override
  Widget build(BuildContext context) {
    final Customer user = CustomerService().getCustomer();

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
            _buildProfileHeader(user),
            const SizedBox(height: 16),

            Expanded(child: _buildSection(context, user)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Customer user) {
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
        Text(user.name, style: context.texts.titleMedium),
        Text(user.email, style: context.texts.titleSmall),
      ],
    );
  }

  Widget _buildSection(BuildContext context, Customer user) {
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
        if (showPersonalData) _buildPersonalDataSection(user),

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

  Widget _buildPersonalDataSection(Customer user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _info("Nome", user.name),
          _info("Email", user.email.replaceRange(3, 8, "*****")),
          _info("Telefone", user.phoneNumber.replaceRange(5, 10, "*****")),
          _info("Endereço", "Rua A, nº10, Bairro, Cidade"),
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
          ),

          const SizedBox(height: 12),

          _passwordField(
            "Nova senha",
            showPasswordNew,
            () => setState(() => showPasswordNew = !showPasswordNew),
          ),

          const SizedBox(height: 12),

          _passwordField(
            "Confirme a senha",
            showPasswordConfirm,
            () => setState(() => showPasswordConfirm = !showPasswordConfirm),
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
              onPressed: () {},
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

  Widget _passwordField(String label, bool visible, VoidCallback toggle) {
    return CustomInput(
      hintText: label,
      prefixIcon: Icons.lock_outline,
      obscureText: !visible,
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
