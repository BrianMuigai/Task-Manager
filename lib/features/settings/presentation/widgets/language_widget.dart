import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:task/core/l10n/app_localization.dart';
import 'package:task/core/l10n/locale_provider.dart';
import 'package:task/features/settings/presentation/bloc/settings_bloc.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLocale = provider.locale;

    return BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
      if (state is ChangeLanguageSuccess) {
        provider.setLocale(Locale(state.langCode));
      }
    }, child:
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      if (state is LanguageLoading) {
        return CircularProgressIndicator.adaptive();
      }
      return state is ChangeLanguageError
          ? Column(
              children: [
                Text(state.error),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    context
                        .read<SettingsBloc>()
                        .add(ChangeLanguageEvent(langCode: state.lang));
                  },
                  child: Text(AppLocalizations.getString(context, 'retry')),
                )
              ],
            )
          : DropdownButton<Locale>(
              value: currentLocale,
              items: [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text(AppLocalizations.getString(context, 'english')),
                ),
                DropdownMenuItem(
                  value: Locale('fr'),
                  child: Text(AppLocalizations.getString(context, 'french')),
                ),
                DropdownMenuItem(
                  value: Locale('es'),
                  child: Text(AppLocalizations.getString(context, 'spanish')),
                ),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  context
                      .read<SettingsBloc>()
                      .add(ChangeLanguageEvent(langCode: locale.languageCode));
                }
              },
            );
    }));
  }
}
