import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/chat_mngmt/controllers/chat_controller.dart';
import 'package:real_time_pawn/features/chat_mngmt/services/chat_service.dart';
import 'package:real_time_pawn/models/chat_model.dart';
import 'package:real_time_pawn/widgets/custom_typography/typography.dart';

class ChatConversationsScreen extends StatefulWidget {
  const ChatConversationsScreen({super.key});

  @override
  State<ChatConversationsScreen> createState() =>
      _ChatConversationsScreenState();
}

class _ChatConversationsScreenState extends State<ChatConversationsScreen> {
  late final ChatController _ctrl;
  final _search = TextEditingController();
  var _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ChatController>();
    _ctrl.loadConversations();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('dd/MM/yy').format(dt);
  }

  Future<void> _openNewConversationSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NewConversationSheet(
        onUserSelected: (userId) async {
          Get.back();
          await _ctrl.openConversationWithUser(userId);
          Get.toNamed(RoutesHelper.chatScreen);
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildConversationList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewConversationSheet,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ).animate().scale(delay: 300.ms),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
      title: Text(
        'Messages',
        style: CustomTypography.nunitoTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
      ),
      actions: [
        Obx(() {
          final count = _ctrl.unreadTotal.value;
          if (count == 0) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v.toLowerCase()),
        style: TextStyle(color: AppColors.textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search conversations…',
          hintStyle: TextStyle(color: AppColors.subtextColor, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.subtextColor, size: 20),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                  child: const Icon(Icons.clear,
                      color: AppColors.subtextColor, size: 18),
                )
              : null,
          filled: true,
          fillColor: AppColors.cardColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      final myId = _ctrl.myUserId;
      final convs = _ctrl.conversations.where((c) {
        if (_query.isEmpty) return true;
        final other = c.getOtherParticipant(myId);
        return other?.fullName.toLowerCase().contains(_query) ?? false;
      }).toList();

      if (convs.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _ctrl.loadConversations,
        color: AppColors.primaryColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: convs.length,
          itemBuilder: (ctx, i) =>
              _ConversationTile(
                conv: convs[i],
                myUserId: myId,
                formatTime: _formatTime,
              )
                  .animate()
                  .fadeIn(delay: (i * 40).ms)
                  .slideX(begin: 0.05),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 36, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: CustomTypography.nunitoTextTheme.titleSmall?.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start a new chat',
            style: TextStyle(color: AppColors.subtextColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ── Conversation Tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conv;
  final String myUserId;
  final String Function(DateTime?) formatTime;

  const _ConversationTile({
    required this.conv,
    required this.myUserId,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    // Always show the OTHER participant — never the logged-in user themselves
    final other = conv.getOtherParticipant(myUserId);
    final name = other?.fullName ?? 'Unknown';
    final preview = conv.lastMessage ?? 'No messages yet';
    final time = formatTime(conv.lastMessageAt);
    final hasUnread = conv.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        // openConversationById fetches fresh data AND navigates to chat screen
        ctrl.openConversationById(conv.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: _Avatar(participant: other),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTypography.nunitoTextTheme.bodyMedium?.copyWith(
                    fontWeight:
                        hasUnread ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: hasUnread
                      ? AppColors.primaryColor
                      : AppColors.subtextColor,
                  fontWeight:
                      hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: hasUnread
                        ? AppColors.textColor
                        : AppColors.subtextColor,
                    fontWeight:
                        hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (hasUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      conv.unreadCount > 9 ? '9+' : '${conv.unreadCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final ChatParticipant? participant;
  const _Avatar({this.participant});

  @override
  Widget build(BuildContext context) {
    final url = participant?.profilePicUrl;
    final initials = participant?.initials ?? '?';
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primaryColor.withOpacity(0.12),
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : null,
    );
  }
}

// ── New Conversation Bottom Sheet ─────────────────────────────────────────────

class _NewConversationSheet extends StatefulWidget {
  final void Function(String userId) onUserSelected;
  const _NewConversationSheet({required this.onUserSelected});

  @override
  State<_NewConversationSheet> createState() => _NewConversationSheetState();
}

class _NewConversationSheetState extends State<_NewConversationSheet> {
  List<ChatParticipant> _users = [];
  List<ChatParticipant> _filtered = [];
  bool _loading = true;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await ChatApiService.getChatableUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _filtered = users;
        _loading = false;
      });
    }
  }

  void _filter(String q) {
    setState(() {
      _q = q.toLowerCase();
      _filtered = _users
          .where((u) => u.fullName.toLowerCase().contains(_q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Start a New Conversation',
              style: CustomTypography.nunitoTextTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search people…',
                hintStyle:
                    TextStyle(color: AppColors.subtextColor, fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.subtextColor, size: 18),
                filled: true,
                fillColor: AppColors.cardColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryColor))
                : _filtered.isEmpty
                    ? Center(
                        child: Text('No users found',
                            style: TextStyle(color: AppColors.subtextColor)),
                      )
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final u = _filtered[i];
                          return ListTile(
                            leading: _Avatar(participant: u),
                            title: Text(
                              u.fullName,
                              style: CustomTypography
                                  .nunitoTextTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            subtitle: Text(
                              u.roleLabel,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subtextColor),
                            ),
                            onTap: () => widget.onUserSelected(u.id),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
