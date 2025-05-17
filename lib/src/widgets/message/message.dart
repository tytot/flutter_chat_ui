import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:visibility_detector/visibility_detector.dart';

import '../../conditional/conditional.dart';
import '../../models/bubble_rtl_alignment.dart';
import '../../models/emoji_enlargement_behavior.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';
import '../state/inherited_user.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'message_status.dart';
import 'text_message.dart';
import 'user_avatar.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type.
  const Message({
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment,
    this.customMessageBuilder,
    this.customStatusBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageHeaders,
    this.imageMessageBuilder,
    this.imageProviderBuilder,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    this.onRepliedMessageTap,
    this.repliedMessageLabelBuilder,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.isLeftStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.textMessageOptions,
    required this.usePreviewData,
    this.userAgent,
    this.videoMessageBuilder,
  });

  /// Build an audio message inside predefined bubble.
  final Widget Function(
    types.AudioMessage, {
    required int messageWidth,
    required bool isRepliedMessage,
  })? audioMessageBuilder;

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id.
  final Widget Function(types.User author)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author).
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Determine the alignment of the bubble for RTL languages. Has no effect
  /// for the LTR languages.
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Build a custom message inside predefined bubble.
  final Widget Function(
    types.CustomMessage, {
    required int messageWidth,
    required bool isRepliedMessage,
  })? customMessageBuilder;

  /// Build a custom status widgets.
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble.
  final Widget Function(
    types.FileMessage, {
    required int messageWidth,
    required bool isRepliedMessage,
  })? fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// Build an image message inside predefined bubble.
  final Widget Function(
    types.ImageMessage, {
    required int messageWidth,
    required bool isRepliedMessage,
  })? imageMessageBuilder;

  /// See [Chat.imageProviderBuilder].
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// Any message type.
  final types.Message message;

  /// Maximum message width.
  final int messageWidth;

  /// See [TextMessage.nameBuilder].
  final Widget Function(types.User)? nameBuilder;

  /// See [UserAvatar.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message.
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on status icon in any message.
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message.
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when the message's visibility changes.
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Called when user taps on a replied message.
  final void Function(BuildContext context, types.Message)? onRepliedMessageTap;

  /// Build a label shown above the replied message.
  final Widget Function(types.Message, bool currentUserIsAuthorOfReply)?
      repliedMessageLabelBuilder;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName].
  final bool showName;

  /// Show message's status.
  final bool showStatus;

  /// This is used to determine if the status icon should be on the left or
  /// right side of the message.
  /// This is only used when [showStatus] is true.
  /// Defaults to false.
  final bool isLeftStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
    required bool isRepliedMessage,
  })? textMessageBuilder;

  /// See [TextMessage.options].
  final TextMessageOptions textMessageOptions;

  /// See [TextMessage.usePreviewData].
  final bool usePreviewData;

  /// See [TextMessage.userAgent].
  final String? userAgent;

  /// Build an audio message inside predefined bubble.
  final Widget Function(
    types.VideoMessage, {
    required int messageWidth,
    required bool isRepliedMessage,
  })? videoMessageBuilder;

  Widget _avatarBuilder(types.Message message) => showAvatar
      ? avatarBuilder?.call(message.author) ??
          UserAvatar(
            author: message.author,
            bubbleRtlAlignment: bubbleRtlAlignment,
            imageHeaders: imageHeaders,
            onAvatarTap: onAvatarTap,
          )
      : const SizedBox(width: 40);

  Widget _bubbleBuilder(
    BuildContext context,
    types.Message message,
    BorderRadius borderRadius, {
    bool isRepliedMessage = false,
  }) {
    final user = InheritedUser.of(context).user;
    final currentUserIsAuthor = user.id == message.author.id;
    final enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
              emojiEnlargementBehavior,
              message,
            );

    final defaultMessage = (enlargeEmojis && hideBackgroundOnEmojiMessages)
        ? _messageBuilder(message, isRepliedMessage: isRepliedMessage)
        : Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: !currentUserIsAuthor ||
                      message.type == types.MessageType.image
                  ? InheritedChatTheme.of(context).theme.secondaryColor
                  : InheritedChatTheme.of(context).theme.primaryColor,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child:
                  _messageBuilder(message, isRepliedMessage: isRepliedMessage),
            ),
          );
    return bubbleBuilder != null
        ? bubbleBuilder!(
            _messageBuilder(message, isRepliedMessage: isRepliedMessage),
            message: message,
            nextMessageInGroup: roundBorder,
          )
        : defaultMessage;
  }

  Widget _messageBuilder(
    types.Message message, {
    required bool isRepliedMessage,
  }) {
    switch (message.type) {
      case types.MessageType.audio:
        final audioMessage = message as types.AudioMessage;
        return audioMessageBuilder != null
            ? audioMessageBuilder!(
                audioMessage,
                messageWidth: messageWidth,
                isRepliedMessage: isRepliedMessage,
              )
            : const SizedBox();
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(
                customMessage,
                messageWidth: messageWidth,
                isRepliedMessage: isRepliedMessage,
              )
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(
                fileMessage,
                messageWidth: messageWidth,
                isRepliedMessage: isRepliedMessage,
              )
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(
                imageMessage,
                messageWidth: messageWidth,
                isRepliedMessage: isRepliedMessage,
              )
            : ImageMessage(
                imageHeaders: imageHeaders,
                imageProviderBuilder: imageProviderBuilder,
                message: imageMessage,
                messageWidth: messageWidth,
              );
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: isRepliedMessage ? false : showName,
                isRepliedMessage: isRepliedMessage,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                options: textMessageOptions,
                showName: isRepliedMessage ? false : showName,
                usePreviewData: usePreviewData,
                userAgent: userAgent,
              );
      case types.MessageType.video:
        final videoMessage = message as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(
                videoMessage,
                messageWidth: messageWidth,
                isRepliedMessage: isRepliedMessage,
              )
            : const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget _repliedBubbleBuilder(
    BuildContext context,
    types.Message repliedMessage,
    BorderRadius borderRadius,
    bool currentUserIsAuthorOfReply,
  ) {
    final theme = InheritedChatTheme.of(context).theme;
    final bubble = _bubbleBuilder(
      context,
      repliedMessage,
      borderRadius,
      isRepliedMessage: true,
    );
    final indicator = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: theme.repliedMessageIndicatorColor,
      ),
    );
    final replyBubble = Stack(children: [
      Padding(
        padding: EdgeInsets.only(
          left: currentUserIsAuthorOfReply ? 0 : 12,
          right: currentUserIsAuthorOfReply ? 12 : 0,
        ),
        child: Opacity(
          opacity: 0.69,
          child: FittedScale(
            scale: theme.repliedMessageScaleFactor,
            child: bubble,
          ),
        ),
      ),
      if (!currentUserIsAuthorOfReply)
        Positioned(left: 0, top: 0, bottom: 0, width: 4, child: indicator),
      if (currentUserIsAuthorOfReply)
        Positioned(right: 0, top: 0, bottom: 0, width: 4, child: indicator),
    ]);
    return Column(
      crossAxisAlignment: currentUserIsAuthorOfReply
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (repliedMessageLabelBuilder != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: repliedMessageLabelBuilder!(
              repliedMessage,
              currentUserIsAuthorOfReply,
            ),
          ),
        replyBubble,
      ],
    );
  }

  Widget _statusIcon(
    BuildContext context,
    types.Message message,
  ) {
    if (!showStatus) return const SizedBox.shrink();

    return Padding(
      padding: InheritedChatTheme.of(context).theme.statusIconPadding,
      child: GestureDetector(
        onLongPress: () => onMessageStatusLongPress?.call(context, message),
        onTap: () => onMessageStatusTap?.call(context, message),
        child: customStatusBuilder != null
            ? customStatusBuilder!(message, context: context)
            : MessageStatus(status: message.status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final user = InheritedUser.of(context).user;
    final currentUserIsAuthor = user.id == message.author.id;
    final messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final borderRadius = bubbleRtlAlignment == BubbleRtlAlignment.left
        ? BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              !currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            ),
            bottomStart: Radius.circular(
              currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            ),
            topEnd: Radius.circular(messageBorderRadius),
            topStart: Radius.circular(messageBorderRadius),
          )
        : BorderRadius.only(
            bottomLeft: Radius.circular(
              currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            ),
            bottomRight: Radius.circular(
              !currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            ),
            topLeft: Radius.circular(messageBorderRadius),
            topRight: Radius.circular(messageBorderRadius),
          );

    final bubbleMargin = InheritedChatTheme.of(context).theme.bubbleMargin ??
        (bubbleRtlAlignment == BubbleRtlAlignment.left
            ? EdgeInsetsDirectional.only(
                bottom: 4,
                end: isMobile ? query.padding.right : 0,
                start: 20 + (isMobile ? query.padding.left : 0),
              )
            : EdgeInsets.only(
                bottom: 4,
                left: 20 + (isMobile ? query.padding.left : 0),
                right: isMobile ? query.padding.right : 0,
              ));

    return Container(
      alignment: bubbleRtlAlignment == BubbleRtlAlignment.left
          ? currentUserIsAuthor
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart
          : currentUserIsAuthor
              ? Alignment.centerRight
              : Alignment.centerLeft,
      margin: bubbleMargin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        textDirection: bubbleRtlAlignment == BubbleRtlAlignment.left
            ? null
            : TextDirection.ltr,
        children: [
          if (!currentUserIsAuthor && showUserAvatars) _avatarBuilder(message),
          if (currentUserIsAuthor && isLeftStatus)
            _statusIcon(context, message),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: currentUserIsAuthor
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.repliedMessage != null)
                  GestureDetector(
                    onTap: () => onRepliedMessageTap?.call(
                      context,
                      message.repliedMessage!,
                    ),
                    child: _repliedBubbleBuilder(
                      context,
                      message.repliedMessage!,
                      BorderRadius.circular(messageBorderRadius),
                      currentUserIsAuthor,
                    ),
                  ),
                if (message.repliedMessage != null) const SizedBox(height: 6),
                GestureDetector(
                  onDoubleTap: () => onMessageDoubleTap?.call(context, message),
                  onLongPress: () => onMessageLongPress?.call(context, message),
                  onTap: () => onMessageTap?.call(context, message),
                  child: onMessageVisibilityChanged != null
                      ? VisibilityDetector(
                          key: Key(message.id),
                          onVisibilityChanged: (visibilityInfo) =>
                              onMessageVisibilityChanged!(
                            message,
                            visibilityInfo.visibleFraction > 0.1,
                          ),
                          child: _bubbleBuilder(
                            context,
                            message,
                            borderRadius.resolve(Directionality.of(context)),
                          ),
                        )
                      : _bubbleBuilder(
                          context,
                          message,
                          borderRadius.resolve(Directionality.of(context)),
                        ),
                ),
              ],
            ),
          ),
          if (currentUserIsAuthor && !isLeftStatus)
            _statusIcon(context, message),
        ],
      ),
    );
  }
}
