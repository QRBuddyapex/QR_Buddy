import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class TicketCard extends StatefulWidget {
  final String orderNumber;
  final String description;
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
    required this.index, this.uuid,
  }) : super(key: key);

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Card(
          color: AppColors.cardBackgroundColor,
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Stack(
              children: [
                // Large semi-transparent number
                Positioned(
                  left: width * 0.0001,
                  top: 0,
                  bottom: height * 0.01,
                  child: Opacity(
                    opacity: 0.1,
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                // Main card content
                Padding(
                  padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.orderNumber,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
                                  decoration: BoxDecoration(
                                    color: widget.status == 'Accepted' ? Colors.green[100] : Colors.yellow[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.status,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: widget.status == 'Accepted' ? Colors.green : Colors.yellow[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.block,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Assigned to ${widget.assignedTo}',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 2, // Give more priority to date
                                  child: Text(
                                    widget.date,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.department,
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: Colors.blue,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        widget.description,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2, // Limit to 2 lines
                                      ),
                                      if (widget.isQuickRequest) ...[
                                        Text(
                                          '**Quick Req**',
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 60, // Reduced from 80 to 60
                                  child: Text(
                                    widget.phoneNumber,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: Colors.blue,
                                        ),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code, color: Colors.blue),
                            onPressed: () {},
                          ),
                          Text(
                            widget.serviceLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), 
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Feedback',
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.pink,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}