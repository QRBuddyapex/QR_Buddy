import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class HistoryListWidget extends StatefulWidget {
  final List<dynamic> history;
  const HistoryListWidget({required this.history, super.key});

  @override
  State<HistoryListWidget> createState() => _HistoryListWidgetState();
}

class _HistoryListWidgetState extends State<HistoryListWidget> with TickerProviderStateMixin {
  bool _expanded = false;
  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _animations = [];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setupAnimations(int count) {
    _controllers.forEach((controller) => controller.dispose());
    _controllers.clear();
    _animations.clear();

    for (int i = 0; i < count; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + i * 50),
      );

      final animation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      _controllers.add(controller);
      _animations.add(animation);

      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.045;
    final containerWidth = width * 0.12;
    final lineHeight = height * 0.09;
    final iconSizeLarge = width * 0.06;
    final iconSizeSmall = width * 0.05;
    final vSpacingSmall = height * 0.008;
    final vSpacingMedium = height * 0.03;
    final hSpacingSmall = width * 0.02;
    final borderWidth = 1.0;
    final lineOpacity = 0.3;
    final marginBottom = height * 0.03;
    final paddingLeft = width * 0.02;
    final animationDuration = const Duration(milliseconds: 400);
    final animationCurve = Curves.easeInOut;
    final buttonIconSize = width * 0.055;
    final buttonPaddingH = width * 0.02;
    final buttonPaddingV = height * 0.008;

    final Map<String, ({IconData icon, Color color})> historyIconMap = {
      'ESC': (icon: IconlyBold.danger, color: AppColors.escalationIconColor),
      'ASI': (icon: IconlyBold.user_3, color: AppColors.assignmentIconColor),
      'ACC': (icon: IconlyBold.tick_square, color: AppColors.primaryColor),
      'COMP': (icon: IconlyBold.shield_done, color: AppColors.statusButtonColor),
      'HOLD': (icon: IconlyBold.time_circle, color: AppColors.holdButtonColor),
      'CAN': (icon: IconlyBold.close_square, color: AppColors.dangerButtonColor),
      'REO': (icon: IconlyBold.arrow_right, color: AppColors.statusButtonColor1),
      'VER': (icon: IconlyBold.shield_done, color: Colors.purple),
    };

    final historyToShow = _expanded ? widget.history : widget.history.take(5).toList();


    _setupAnimations(historyToShow.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: animationDuration,
          curve: animationCurve,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyToShow.length,
            itemBuilder: (context, index) {
              final history = historyToShow[index];
              final iconData = historyIconMap[history.type] ??
                  (icon: IconlyBold.info_square, color: AppColors.hintTextColor);

              return SlideTransition(
                position: _animations[index],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
             
                    Container(
                      width: containerWidth,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: iconData.color.withOpacity(0.15),
                            child: Icon(iconData.icon, color: iconData.color, size: iconSizeLarge),
                          ),
                          if (index != historyToShow.length - 1)
                            Container(
                              height: lineHeight,
                              width: borderWidth,
                              color: Colors.grey.withOpacity(lineOpacity),
                            ),
                        ],
                      ),
                    ),

               
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: marginBottom),
                        padding: EdgeInsets.only(left: paddingLeft),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(width: borderWidth * 0.75, color: Colors.grey.withOpacity(0.2)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${history.createdAtDate} ${history.createdAt}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: vSpacingSmall),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    history.caption +
                                        (history.remarks.isNotEmpty ? ' ${history.remarks}' : ''),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                if (history.statusWhatsapp == '1')
                                  Padding(
                                    padding: EdgeInsets.only(left: hSpacingSmall),
                                    child: Icon(IconlyBold.tick_square,
                                        color: AppColors.whatsappIconColor, size: iconSizeSmall),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.history.length > 5)
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? IconlyBold.arrow_up_2 : IconlyBold.arrow_down_2, size: buttonIconSize),
              label: Text(_expanded ? 'Show Less' : 'Show More' ,
              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: buttonPaddingH, vertical: buttonPaddingV),
              ),
            ),
          ),
      ],
    );
  }
}