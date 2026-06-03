import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/chat_mngmt/controllers/chat_controller.dart';
import 'package:real_time_pawn/models/chat_model.dart';
import 'package:real_time_pawn/widgets/custom_typography/typography.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _ctrl;
  final _input = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _myUserId = '';
  bool _typingDebounce = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ChatController>();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Scroll to bottom when new messages arrive
    ever(_ctrl.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  Future<void> _loadUserId() async {
    final id = await CacheUtils.getUserId();
    if (mounted) setState(() => _myUserId = id ?? '');
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTypingChanged(String value) {
    if (value.isNotEmpty && !_typingDebounce) {
      _ctrl.notifyTypingStart();
      _typingDebounce = true;
    }
    if (value.isEmpty && _typingDebounce) {
      _ctrl.notifyTypingStop();
      _typingDebounce = false;
    }
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _ctrl.sendMessage(text);
    _input.clear();
    _ctrl.notifyTypingStop();
    _typingDebounce = false;
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollCtrl.dispose();
    _ctrl.leaveCurrentConversation();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final other = _ctrl.currentConversation.value?.participants
        .firstWhereOrNull((p) => p.id != _myUserId);
    return AppBar(
      backgroundColor: AppColors.surfaceColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textColor),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _SmallAvatar(participant: other),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  other?.fullName ?? 'Chat',
                  style: CustomTypography.nunitoTextTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (other?.roleLabel.isNotEmpty ?? false)
                  Text(
                    other!.roleLabel,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.subtextColor),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(() => Icon(
              Icons.circle,
              size: 10,
              color: _ctrl.isConnected.value
                  ? AppColors.primaryColor
                  : AppColors.subtextColor,
            )),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (_ctrl.isLoadingMessages.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      final msgs = _ctrl.messages;

      if (msgs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 48, color: AppColors.borderColor),
              const SizedBox(height: 12),
              Text(
                'No messages yet.\nSay hello!',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.subtextColor, fontSize: 14),
              ),
            ],
          ).animate().fadeIn(),
        );
      }

      return ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: msgs.length,
        itemBuilder: (ctx, i) {
          final msg = msgs[i];
          final isMine = msg.sender.id == _myUserId;
          final showDateSep = i == 0 ||
              !_sameDay(msgs[i - 1].sentAt, msg.sentAt);
          return Column(
            children: [
              if (showDateSep) _DateSeparator(dt: msg.sentAt),
              _MessageBubble(msg: msg, isMine: isMine)
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: 0.1),
            ],
          );
        },
      );
    });
  }

  Widget _buildTypingIndicator() {
    return Obx(() {
      final info = _ctrl.typingInfo.value;
      if (info.isEmpty) return const SizedBox.shrink();
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Text(
          info,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.subtextColor,
              fontStyle: FontStyle.italic),
        ),
      ).animate().fadeIn();
    });
  }

  Widget _buildInputBar() {
    return Container(
      color: AppColors.surfaceColor,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _input,
                onChanged: _onTypingChanged,
                onSubmitted: (_) => _send(),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.textColor),
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle:
                      TextStyle(color: AppColors.subtextColor, fontSize: 14),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final sending = _ctrl.isSending.value;
            return GestureDetector(
              onTap: sending ? null : _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMine;

  const _MessageBubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMine ? 60 : 0,
          right: isMine ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  msg.sender.fullName,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.subtextColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isMine
                    ? AppColors.primaryColor
                    : AppColors.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(isMine ? 16 : 4),
                  bottomRight:
                      Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(msg.sentAt),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.subtextColor),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.readBy.length > 1
                        ? Icons.done_all_rounded
                        : Icons.check_rounded,
                    size: 14,
                    color: msg.readBy.length > 1
                        ? AppColors.primaryColor
                        : AppColors.subtextColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (msg.isDeleted) {
      return Text(
        '🗑 This message was deleted',
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: (isMine ? Colors.white : AppColors.textColor)
              .withOpacity(0.6),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (msg.hasImages) ...[
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: msg.imagesUrl
                .map((url) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 180,
                          height: 80,
                          color: AppColors.cardColor,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppColors.subtextColor),
                        ),
                      ),
                    ))
                .toList(),
          ),
          if (msg.hasText) const SizedBox(height: 6),
        ],
        if (msg.hasText)
          Text(
            msg.content,
            style: TextStyle(
              fontSize: 14,
              color: isMine ? Colors.white : AppColors.textColor,
            ),
          ),
      ],
    );
  }
}

// ── Date Separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime dt;
  const _DateSeparator({required this.dt});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      label = 'Today';
    } else if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMM yyyy').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.subtextColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ── Small Avatar ─────────────────────────────────────────────────────────────

class _SmallAvatar extends StatelessWidget {
  final ChatParticipant? participant;
  const _SmallAvatar({this.participant});

  @override
  Widget build(BuildContext context) {
    final url = participant?.profilePicUrl;
    final initials = participant?.initials ?? '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryColor.withOpacity(0.12),
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Text(
              initials,
              style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            )
          : null,
    );
  }
}
