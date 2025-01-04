import 'package:anychat/common/config.dart';
import 'package:anychat/common/error.dart';
import 'package:anychat/model/language.dart';
import 'package:anychat/state/user_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/message.dart';

late final TranslateService translateService;

class TranslateService {
  final WidgetRef ref;

  TranslateService(this.ref);

  Future<Message> translate(Message message) async {
    if (message.lang != ref.read(userProvider)!.userInfo.lang) {
      return await Dio().post(HttpConfig.transUrl,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': '\$2b\$12\$CtvzvarRmx7oBazYOeZqGuS4iAVbHbvqf5dslSFsyFBqa3ZYF0l4.'
          }),
          data: {
            'src_lang': message.lang,
            'tgt_lang': ref.read(userProvider)!.userInfo.lang,
            'src_text': message.content
          }).run(null, (result) {
        final data = result.data;
        return message.copyWith(targetContent: data['tgt_text'], targetLang: data['tgt_lang']);
      });
    } else {
      return message.copyWith(targetContent: message.content, targetLang: message.lang);
    }
  }

  Future<String> translateLastMessage(String message, Language lang) async {
    if (lang.code != ref.read(userProvider)!.userInfo.lang) {
      return await Dio().post(HttpConfig.transUrl,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': '\$2b\$12\$CtvzvarRmx7oBazYOeZqGuS4iAVbHbvqf5dslSFsyFBqa3ZYF0l4.'
          }),
          data: {
            'src_lang': lang.code,
            'tgt_lang': ref.read(userProvider)!.userInfo.lang,
            'src_text': message
          }).run(null, (result) {
        final data = result.data;
        return data['tgt_text'];
      });
    } else {
      return message;
    }
  }
}
