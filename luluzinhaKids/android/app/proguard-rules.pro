# Arquivo: proguard-rules.pro

# Regras para preservar classes do Compose, incluindo a LocalSoftwareKeyboardController,
# que é a que está faltando.

-keep class androidx.compose.ui.platform.LocalSoftwareKeyboardController { *; }
-keep class androidx.compose.ui.platform.LocalSoftwareKeyboardControllerKt { *; }

# Regras gerais para Compose (boas práticas)
-keepnames class androidx.compose** { *; }
-keepnames class androidx.compose.runtime.** { *; }
-keepnames class androidx.compose.material.** { *; }

# Regras para preservar classes do Stripe SDK que o R8 pode remover
-keepnames class com.stripe.** { *; }
-dontwarn com.stripe.**

# Preserva todas as Activities/Fragments do Stripe
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Fragment

# Preserva as classes da Jetpack Lifecycle, que o Compose usa
-keep class androidx.lifecycle.** { *; }