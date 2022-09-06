import './chat.message.model.dart';
import 'package:flutter/material.dart';

typedef FunctionEnter = void Function(String roomId);
typedef FunctionRoomsItemBuilder = Widget Function(ChatMessageModel);
typedef FunctionRoomsBlockedItemBuilder = Widget Function(String);
typedef MessageBuilder = Widget Function(ChatMessageModel);
typedef InputBuilder = Widget Function(void Function(String));

const ERROR_CHAT_MESSAGE_ADD =
    'Failed to send message (ERROR_CHAT_MESSAGE_ADD)';
