import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class ReviewItemData {
  final int productId;
  final String productName;
  final String? imageUrl;
  final double price;
  final int quantity;
  int rating;
  final Set<String> selectedTags;
  final TextEditingController commentController;
  bool isSubmitted;
  bool isSubmitting;

  ReviewItemData({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.rating = 5,
    Set<String>? selectedTags,
    TextEditingController? commentController,
    this.isSubmitted = false,
    this.isSubmitting = false,
  })  : selectedTags = selectedTags ?? {},
        commentController = commentController ?? TextEditingController();
}

class WriteReviewScreen extends StatefulWidget {
  final String orderNumber;
  final List<ReviewItemData> items;

  const WriteReviewScreen({
    super.key,
    required this.orderNumber,
    required this.items,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final ApiService _apiService = ApiService();

  final List<String> _quickTags = [
    '🚀 Fast Delivery',
    '✨ High Quality',
    '📦 Great Packaging',
    '💯 Matches Description',
    '👍 Highly Recommended',
    '🔥 Best Value',
  ];

  @override
  void dispose() {
    for (var item in widget.items) {
      item.commentController.dispose();
    }
    super.dispose();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '😞 Terrible';
      case 2:
        return '😐 Poor / Fair';
      case 3:
        return '🙂 Good';
      case 4:
        return '😊 Very Good';
      case 5:
      default:
        return '🤩 Excellent!';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF10B981);
      case 5:
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Future<void> _submitSingleReview(ReviewItemData item) async {
    setState(() => item.isSubmitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String comment = item.commentController.text.trim();
    if (item.selectedTags.isNotEmpty) {
      final tagsText = item.selectedTags.join(', ');
      comment = comment.isEmpty ? tagsText : '$comment\n[Tags: $tagsText]';
    }

    final res = await _apiService.submitProductReview(
      token: authProvider.token,
      productId: item.productId,
      rating: item.rating,
      comment: comment.isNotEmpty ? comment : null,
    );

    if (!mounted) return;
    setState(() {
      item.isSubmitting = false;
      if (res.success) {
        item.isSubmitted = true;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              res.success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                res.success
                    ? 'Review for "${item.productName}" submitted!'
                    : res.message,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: res.success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitAllReviews() async {
    for (var item in widget.items) {
      if (!item.isSubmitted) {
        await _submitSingleReview(item);
      }
    }
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSubmitted = widget.items.every((i) => i.isSubmitted);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        title: Text(
          'Rate & Review Products',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Header Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF7ED), Color(0xFFFFF1EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE3D3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${widget.orderNumber}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your feedback helps other buyers make smart choices',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Product Cards List
            ...widget.items.map((item) => _buildProductReviewCard(item)),

            const SizedBox(height: 20),

            // Submit All Button
            ElevatedButton(
              onPressed: allSubmitted ? () => Navigator.pop(context) : _submitAllReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: allSubmitted ? const Color(0xFF10B981) : AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allSubmitted ? Icons.check_circle_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allSubmitted ? 'Done (All Reviews Submitted)' : 'Submit All Reviews',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProductReviewCard(ReviewItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isSubmitted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          width: item.isSubmitted ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info Row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                        )
                      : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· Qty: ${item.quantity}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        'Reviewed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Star Rating Row
          Center(
            child: Column(
              children: [
                Text(
                  'Tap stars to rate:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIdx) {
                    final starNum = starIdx + 1;
                    final isSelected = starNum <= item.rating;

                    return GestureDetector(
                      onTap: item.isSubmitted
                          ? null
                          : () {
                              setState(() => item.rating = starNum);
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedScale(
                          scale: isSelected ? 1.12 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 34,
                            color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRatingText(item.rating),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _getRatingColor(item.rating),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Feedback Chips
          Text(
            'Highlights:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickTags.map((tag) {
              final isSel = item.selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                  color: isSel ? Colors.white : const Color(0xFF334155),
                ),
                selected: isSel,
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFF8FAFC),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: item.isSubmitted
                    ? null
                    : (selected) {
                        setState(() {
                          if (selected) {
                            item.selectedTags.add(tag);
                          } else {
                            item.selectedTags.remove(tag);
                          }
                        });
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Text Field Comment
          TextField(
            controller: item.commentController,
            enabled: !item.isSubmitted,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Share your experience with this product...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: 12),

          // Submit Single Item Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: item.isSubmitted || item.isSubmitting
                  ? null
                  : () => _submitSingleReview(item),
              icon: item.isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(
                      item.isSubmitted ? Icons.check_circle_rounded : Icons.star_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
              label: Text(
                item.isSubmitted
                    ? 'Submitted'
                    : (item.isSubmitting ? 'Submitting...' : 'Submit Review'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: item.isSubmitted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
