The translation involves some professional terms related to the Mill Game, which makes machine translation difficult. 

This is a FREE App. We do not rely on advertising or in-app purchases, and do not have any income. Therefore, we hope that volunteers can help us with translation and grammar checking. Your efforts will help our App do better and benefit more people around the world. We sincerely thank you!

How to translate the UI into a different language?

The following is an example of the way of translating English text into German:

Download https://raw.githubusercontent.com/calcitem/Sanmill/master/src/ui/flutter_app/lib/l10n/intl_en.arb

File intl_en.arb describes the role of each text field and the content of the English text. You can use Notepad++/vim or any other Editors to edit it. A small number of strings are strings that are not used by the App, and may be used after future feature upgrades.

Rename `intl_en.arb` to `intl_de.arb`, and then modify `"@@locale": "en"` to `"@@locale": "de"`, Change English strings to German strings, no need to translate `description`. If part of the text is not translated, it does not affect the use of the App, you can temporarily leave it untranslated.

A Sample:

```
  "@@locale": "en",
  "appName": "Mill",
  "@appName": {
    "description": "The App name"
  },
  "yes": "Yes",
```

Translated:

```
  "@@locale": "de",
  "appName": "Mühle",
  "@appName": {
    "description": "The App name"
  },
  "yes": "Ja",
```

Reference: https://flutter.dev/docs/development/accessibility-and-localization/internationalization

If you are not familiar with making Merge Request, you can upload the translated text to Discussion.

Open https://github.com/calcitem/Sanmill/discussions/new

`Select Category` -- select `Translation`.

Title: `German Translation`

Rename `intl_de.arb` to `intl_de.arb.txt`, and then drag `intl_de.arb.txt` to the text field, and click `Start discussion`.

We will try our best to put the new translation into the App and release it within two days. If you urgently need to update the App as soon as possible, you can download it at [Github Actions](https://github.com/calcitem/Sanmill/actions/workflows/flutter.yml?query=is%3Asuccess+branch%3Amaster). Because the signing key is different from Google Play Store and F-Droid, you need to uninstall the original App and reinstall it. Thank you for your understanding!

If we do not reply this discussion within three days, you can send us an email: calcitem@outlook.com to remind us.

Thank you for your contribution!




