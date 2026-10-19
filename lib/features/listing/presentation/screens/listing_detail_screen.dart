import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/core/theme/app_theme.dart';
import 'package:hamyar/features/listing/data/listing_repository.dart';
import 'package:hamyar/features/chat/data/chat_repository.dart';
import 'package:hamyar/features/chat/presentation/screens/chat_screen.dart';
import 'package:hamyar/shared/models/listing_model.dart';
import 'package:hamyar/features/report/presentation/widgets/report_dialog.dart';

final listingDetailProvider =
    FutureProvider.autoDispose.family<ListingModel, int>((ref, id) async {
  return ref.read(listingRepositoryProvider).getListing(id);
});

class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  bool _startingChat = false;

  Future<void> _startChat(ListingModel listing) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('شروع گفتگو'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'پیام اول خود را بنویسید...'),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('ارسال'),
          ),
        ],
      ),
    );
    if (message == null || message.isEmpty) return;

    setState(() => _startingChat = true);
    try {
      final conv = await ref.read(chatRepositoryProvider).startConversation(
            listingId: listing.id,
            message: message,
          );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conv.id,
              title: listing.user?.displayName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _startingChat = false);
    }
  }

  Future<void> _reportListing(ListingModel listing) async {
    await showReportDialog(
      context,
      reportableType: 'listing',
      reportableId: listing.id,
      title: 'گزارش آگهی',
    );
  }

  Future<void> _reportUser(ListingModel listing) async {
    if (listing.user == null) return;
    await showReportDialog(
      context,
      reportableType: 'user',
      reportableId: listing.user!.id,
      title: 'گزارش کاربر',
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جزئیات آگهی'),
        actions: [
          listingAsync.maybeWhen(
            data: (listing) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'report_listing') _reportListing(listing);
                if (value == 'report_user') _reportUser(listing);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'report_listing',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 20, color: AppColors.error),
                      SizedBox(width: 10),
                      Text('گزارش این آگهی'),
                    ],
                  ),
                ),
                if (listing.user != null)
                  const PopupMenuItem(
                    value: 'report_user',
                    child: Row(
                      children: [
                        Icon(Icons.person_off_outlined, size: 20, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('گزارش این کاربر'),
                      ],
                    ),
                  ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: listingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(listingDetailProvider(widget.listingId)),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
        data: (listing) {
          final isOffer = listing.isOffer;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isOffer ? AppColors.offer : AppColors.request).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOffer ? 'پیشنهاد' : 'درخواست',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isOffer ? AppColors.offer : AppColors.request,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (listing.category != null)
                  Text(listing.category!.name, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                if (listing.description != null && listing.description!.isNotEmpty) ...[
                  Text('توضیحات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(listing.description!, style: const TextStyle(height: 1.6, fontSize: 15)),
                  const SizedBox(height: 24),
                ],
                if (listing.user != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(
                            listing.user!.displayName[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.user!.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              if (listing.user!.rating > 0)
                                Text(
                                  '${listing.user!.rating.toStringAsFixed(1)} (${listing.user!.ratingCount} نظر)',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: listingAsync.maybeWhen(
        data: (listing) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _startingChat ? null : () => _startChat(listing),
              icon: _startingChat
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.chat_rounded),
              label: Text(_startingChat ? 'در حال اتصال...' : 'شروع گفتگو'),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}
