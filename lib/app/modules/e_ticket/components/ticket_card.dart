import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class TicketCard extends StatefulWidget {
  final String orderNumber;
  final String description;
  final String? roomNumber;
  final String block;
  final String status;
  final String date;
  final String department;
  final String phoneNumber;
  final String assignedTo;
  final String serviceLabel;
  final bool isQuickRequest;
  final VoidCallback onTap;
  final int index;
  final String? uuid;
  final String? orderID;
  final String source;
  const TicketCard({
    Key? key,
    required this.orderNumber,
    required this.description,
    required this.block,
    required this.status,
    required this.date,
    required this.department,
    required this.phoneNumber,
    required this.assignedTo,
    required this.serviceLabel,
    this.isQuickRequest = false,
    required this.onTap,
    required this.index,
    this.roomNumber,
    this.uuid,
    this.orderID,
    required this.source,
  }) : super(key: key);

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppColors.statusButtonColor;
      case 'Completed':
        return AppColors.whatsappIconColor;
      case 'Re-Open':
        return AppColors.dangerButtonColor;
      case 'Cancelled':
        return AppColors.dangerButtonColor;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]!
            : Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case 'Accepted':
        return AppColors.statusButtonColor.withOpacity(0.2);
      case 'Completed':
        return AppColors.statusButtonColor1.withOpacity(0.2);
      case 'Re-Open':
        return AppColors.dangerButtonColor.withOpacity(0.2);
      default:
        return isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero)
            .animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final cardPadding = width * 0.04;
    final vSpacingSmall = height * 0.008;
    final vSpacingMedium = height * 0.012;
    final vSpacingLarge = height * 0.02;
    final iconSize = width * 0.04;
    final textPaddingH = width * 0.03;
    final textPaddingV = height * 0.008;
    final statusPaddingH = width * 0.035;
    final statusPaddingV = height * 0.008;

    return Padding(
      padding: EdgeInsets.all(cardPadding),
      child: Card(
        elevation: 0, // 🔥 Removed shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDarkMode
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                widget.orderNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkTextColor
                                          : AppColors.textColor,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: statusPaddingH, vertical: statusPaddingV),
                                  decoration: BoxDecoration(
                                    color: _getStatusBgColor(widget.status),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.status,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: _getStatusColor(widget.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                SizedBox(width: cardPadding),
                                widget.source.toLowerCase() == 'qr' ? Column(
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      size: iconSize,
                                      color: AppColors.linkColor,
                                    ),
                                    Text(
                                      'QR',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: _getStatusColor(widget.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ) : widget.source.toLowerCase() == 'rem' ? Column(
                                  children: [
                                    Icon(
                                      Icons.settings_remote,
                                      size: iconSize,
                                      color: AppColors.linkColor,
                                    ),
                                    Text(
                                      'REM',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: _getStatusColor(widget.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ) : widget.source.toLowerCase() == 'web' ? Column(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      size: iconSize,
                                      color: AppColors.linkColor,
                                    ),
                                    Text(
                                      'WEB',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: _getStatusColor(widget.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ) : const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: vSpacingSmall),

                        /// Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: iconSize,
                              color: isDarkMode
                                  ? AppColors.darkSubtitleColor
                                  : AppColors.subtitleColor,
                            ),
                            SizedBox(width: cardPadding / 2),
                            Expanded(
                              child: Text(
                                widget.block,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkSubtitleColor
                                          : AppColors.subtitleColor,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: vSpacingSmall),

                        Text(
                          widget.roomNumber ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkSubtitleColor
                                    : AppColors.subtitleColor,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: vSpacingSmall),

                        /// Assigned To
                        Text(
                          'Assigned to: ${widget.assignedTo}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSubtitleColor
                                        : AppColors.subtitleColor,
                                  ),
                        ),

                        SizedBox(height: vSpacingMedium),

                        /// Description
                        Text(
                          widget.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSubtitleColor
                                        : AppColors.subtitleColor,
                                  ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: vSpacingMedium),

                        /// Date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: iconSize,
                              color: isDarkMode
                                  ? AppColors.darkSubtitleColor
                                  : AppColors.subtitleColor,
                            ),
                            SizedBox(width: cardPadding / 2),
                            Text(
                              widget.date,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSubtitleColor
                                        : AppColors.subtitleColor,
                                  ),
                            ),
                          ],
                        ),

                        SizedBox(height: vSpacingMedium),

                        /// Phone Number
                        Row(
                          children: [
                            Text(
                              'GDA Ref: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSubtitleColor
                                        : AppColors.subtitleColor,
                                  ),
                            ),
                            Expanded(
                              child: Text(
                                widget.phoneNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: AppColors.linkColor,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: cardPadding / 2),
                          ],
                        ),

                        SizedBox(height: vSpacingMedium),

                        /// Quick Request
                        if (widget.isQuickRequest)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: statusPaddingH, vertical: statusPaddingV),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.darkBorderColor
                                  : AppColors.borderColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Quick Request',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextColor
                                        : AppColors.textColor,
                                  ),
                            ),
                          ),

                        SizedBox(height: vSpacingLarge),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}